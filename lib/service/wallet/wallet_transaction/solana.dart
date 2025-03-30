part of 'transaction_history_service.dart';

/// 솔라나 거래 내역 서비스
class _SolanaHistoryService implements _BlockchainHistoryService {
  final config = WalletConfig.config;
  final httpClient = http.Client();
  static const int _requestTimeout = 15;

  /// 솔라나 주소의 모든 트랜잭션 조회 (SOL + 모든 SPL 토큰)
  @override
  Future<List<TransactionHistory>> getAllTransactions(String address) async {
    // 지금 안씀

    try {
      // 기본 SOL 트랜잭션만 조회 (SPL 토큰은 필요 시 개별 조회)
      final solTransactions = await getSolTransactions(address);

      // 토큰 트랜잭션 조회는 필요할 때 특정 토큰별로 수행
      // 솔라나에서는 모든 토큰을 한 번에 불러오는 것이 비효율적이므로

      // 시간순 정렬 (최신순)
      solTransactions.sort((a, b) =>
          (b.timestamp ?? DateTime(0)).compareTo(a.timestamp ?? DateTime(0)));

      return solTransactions;
    } catch (e) {
      print('Failed to get all Solana transactions: $e');
      return []; // 오류 발생 시 빈 목록 반환
    }
  }

  /// 특정 토큰의 트랜잭션 조회
  @override
  Future<List<TransactionHistory>> getSpecificTokenTransactions(
    String address,
    TokenInfo info,
  ) async {
    try {
      // SOL인 경우 SOL 트랜잭션만 반환
      if (info.symbol == "SOL") {
        try {
          return await getSolTransactions(address);
        } catch (e) {
          print('Error fetching SOL transactions: $e');
          return [];
        }
      }

      // 특정 SPL 토큰 트랜잭션 조회
      try {
        return await getTokenTransactions(address, info.address);
      } catch (e) {
        print('Error fetching SPL token transactions: $e');
        return [];
      }
    } catch (e) {
      print('Error fetching transactions for ${info.symbol}: $e');
      return []; // 빈 목록 반환하여 UI가 크래시되지 않도록 함
    }
  }

  /// Alchemy API를 사용하여 트랜잭션 내역 조회
  Future<List<TransactionHistory>> _fetchAlchemyTransactions({
    required String address,
    String? tokenMintAddress,
    int maxCount = 100,
  }) async {
    try {
      var params = {
        'fromBlock': '0x0',
        'toBlock': 'latest',
        'category': ['solana'],
        'withMetadata': true,
        'maxCount': '0x${maxCount.toRadixString(16)}',
        'order': 'desc',
        if (tokenMintAddress != null) 'contractAddresses': [tokenMintAddress],
      };

      // 보낸 트랜잭션 요청
      var sentParams = {'fromAddress': address, ...params};
      final sentTxRequestBody = {
        'id': 1,
        'jsonrpc': '2.0',
        'method': 'alchemy_getAssetTransfers',
        'params': [sentParams],
      };

      // 받은 트랜잭션 요청
      var receivedParams = {'toAddress': address, ...params};
      final receivedTxRequestBody = {
        'id': 1,
        'jsonrpc': '2.0',
        'method': 'alchemy_getAssetTransfers',
        'params': [receivedParams],
      };

      // 요청 실행
      final sentData = await _makeRequest(sentTxRequestBody);
      final receivedData = await _makeRequest(receivedTxRequestBody);

      // 트랜잭션 처리 및 결과 합치기
      return [
        ..._transcationJsonToTransactionHistory(sentData, address, true),
        ..._transcationJsonToTransactionHistory(receivedData, address, false),
      ];
    } catch (e) {
      print('Failed to get Solana transactions: $e');
      throw Exception('Failed to get Solana transactions: $e');
    }
  }

  Future<Map<String, dynamic>> _makeRequest(Map<String, dynamic> body) async {
    final response = await httpClient
        .post(
          Uri.parse(config.solanaRpcUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        )
        .timeout(
          const Duration(seconds: _requestTimeout),
          onTimeout: () => throw Exception('Request timed out'),
        );

    if (response.statusCode == 400) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error']?['message'] ?? '잘못된 요청입니다');
    }

    if (response.statusCode != 200) {
      throw Exception('API 요청 실패: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  List<TransactionHistory> _transcationJsonToTransactionHistory(
    Map<String, dynamic> data,
    String address,
    bool isSent,
  ) {
    if (data['result']?['transfers'] == null) return [];

    return (data['result']['transfers'] as List)
        .map((tx) =>
            _mapAlchemyTransactionToHistory(tx, address, isSent: isSent))
        .where((tx) => tx != TransactionHistory.empty)
        .toList();
  }

  /// Alchemy 트랜잭션 데이터를 TransactionHistory 객체로 변환
  TransactionHistory _mapAlchemyTransactionToHistory(
      Map<String, dynamic> tx, String userAddress,
      {bool isSent = false}) {
    try {
      final timestamp = DateTime.tryParse(
          tx['metadata']?['blockTimestamp']?.toString() ?? '');

      // timestamp 존재 여부로 confirmed 상태 확인
      final isConfirmed = timestamp != null;
      final confirmations = isConfirmed ? 1 : 0;

      // 트랜잭션 상태 결정
      final status = !isConfirmed
          ? TransactionHistoryStatus.isPending
          : (isSent
              ? TransactionHistoryStatus.isSent
              : TransactionHistoryStatus.isReceived);

      final commonData = AlchemyCommonTransactionData(
        hash: tx['hash']?.toString() ?? '',
        from: tx['from']?.toString() ?? '',
        to: tx['to']?.toString() ?? '',
        timestamp: timestamp,
        confirmations: confirmations,
        status: status,
      );

      return TransactionHistory.createSolanaTransaction(commonData, tx);
    } catch (e) {
      print('Error mapping Solana transaction: $e');
      return TransactionHistory.empty;
    }
  }

  /// 솔라나 네이티브 트랜잭션 조회 (SOL)
  Future<List<TransactionHistory>> getSolTransactions(String address) async {
    return _fetchAlchemyTransactions(
      address: address,
    );
  }

  /// 특정 SPL 토큰 트랜잭션 조회
  Future<List<TransactionHistory>> getTokenTransactions(
      String address, String tokenMintAddress) async {
    return _fetchAlchemyTransactions(
      address: address,
      tokenMintAddress: tokenMintAddress,
    );
  }

  /// 서비스 종료 시 리소스 해제
  @override
  void dispose() {
    httpClient.close();
  }
}
