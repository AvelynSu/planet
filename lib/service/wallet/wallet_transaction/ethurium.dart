part of 'transaction_history_service.dart';

/// 이더리움 거래 내역 서비스
class _EthereumHistoryService implements _BlockchainHistoryService {
  static const int _requestTimeout = 15;

  final config = WalletConfig();
  final httpClient = http.Client();

  @override
  Future<List<TransactionHistory>> getAllTransactions(String address) async {
    try {
      final results = await Future.wait([
        _getEthTransactions(address),
        _getTokenTransactions(address),
      ]);

      // 두 리스트 합치기
      final allTransactions = [
        ...results[0], // ETH 거래
        ...results[1], // 토큰 거래
      ];

      // 시간순 정렬 (최신순)
      allTransactions.sort((a, b) =>
          (b.timestamp ?? DateTime(0)).compareTo(a.timestamp ?? DateTime(0)));

      return allTransactions;
    } catch (e) {
      print('Failed to get all transactions: $e');
      return []; // 오류 발생 시 빈 목록 반환
    }
  }

  @override
  Future<List<TransactionHistory>> getSpecificTokenTransactions(
    String address,
    TokenInfo info,
  ) async {
    try {
      // ETH인 경우 ETH 트랜잭션만 반환
      if (info.symbol == "ETH") {
        try {
          return await _getEthTransactions(address);
        } catch (e) {
          // 트랜잭션을 찾을 수 없는 경우 빈 목록 반환
          print('Error fetching ETH transactions: $e');
          return [];
        }
      }

      // 특정 토큰 트랜잭션 직접 조회
      try {
        return await _fetchAlchemyTransactions(
          address: address,
          category: 'erc20',
          contractAddress: info.address,
        );
      } catch (e) {
        print('Error fetching token transactions: $e');
        return [];
      }
    } catch (e) {
      // 특정 토큰 트랜잭션 조회 실패 시 처리
      print('Error fetching transactions for ${info.symbol}: $e');
      return [];
    }
  }

  /// Alchemy API를 사용하여 트랜잭션 내역 조회
  Future<List<TransactionHistory>> _fetchAlchemyTransactions({
    required String address,
    String category = 'external',
    String? contractAddress,
    int maxCount = 100,
  }) async {
    try {
      // HTTP 요청 함수 분리
      Future<Map<String, dynamic>> makeRequest(
          Map<String, dynamic> body) async {
        final response = await httpClient
            .post(
              Uri.parse('${config.rpcUrl}'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(body),
            )
            .timeout(
              const Duration(seconds: _requestTimeout),
              onTimeout: () => throw TimeoutException('Request timed out'),
            );
        return jsonDecode(response.body);
      }

      var params = {
        if (contractAddress != null) 'contractAddresses': [contractAddress],
        'fromBlock': '0x0',
        'toBlock': 'latest',
        'category': [category],
        'withMetadata': true,
        'maxCount': '0x${maxCount.toRadixString(16)}',
        'order': 'desc',
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
      final sentData = await makeRequest(sentTxRequestBody);
      final receivedData = await makeRequest(receivedTxRequestBody);

      // 트랜잭션 처리 및 결과 합치기
      return [
        ..._transactionJsonToTransactionHistory(
            sentData, address, category, true),
        ..._transactionJsonToTransactionHistory(
            receivedData, address, category, false),
      ];
    } catch (e) {
      // 구체적인 에러 타입 처리 추가
      if (e is TimeoutException) {
        throw Exception('요청 시간이 초과되었습니다');
      } else if (e is http.ClientException) {
        throw Exception('네트워크 연결에 실패했습니다');
      }
      throw Exception('트랜잭션 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// Alchemy 트랜잭션 데이터를 TransactionHistory 객체로 변환
  TransactionHistory _mapAlchemyTransactionToHistory(
    Map<String, dynamic> tx,
    String userAddress,
    String category, {
    bool isSent = false,
  }) {
    try {
      // 공통 데이터 추출
      final commonData = _extractCommonTransactionData(tx, isSent);
      if (commonData == null) return TransactionHistory.empty;

      // value 값 직접 변환
      final value = double.tryParse(tx['value']?.toString() ?? '0') ?? 0.0;

      // ETH 또는 토큰 데이터 생성
      if (category == 'external') {
        return TransactionHistory.createEthTransaction(commonData, value);
      } else if (category == 'erc20') {
        return TransactionHistory.createTokenTransaction(commonData, tx, value);
      }

      return TransactionHistory.empty;
    } catch (e) {
      print('Error mapping transaction: $e');
      return TransactionHistory.empty;
    }
  }

  // 공통 데이터 추출
  AlchemyCommonTransactionData? _extractCommonTransactionData(
      Map<String, dynamic> tx, bool isSent) {
    final timestamp =
        DateTime.tryParse(tx['metadata']?['blockTimestamp']?.toString() ?? '');

    // timestamp 존재 여부로 confirmed 상태 확인
    final isConfirmed = timestamp != null;
    final confirmations = isConfirmed ? 1 : 0;

    // 트랜잭션 상태 결정
    final status = !isConfirmed
        ? TransactionHistoryStatus.isPending
        : (isSent
            ? TransactionHistoryStatus.isSent
            : TransactionHistoryStatus.isReceived);

    return AlchemyCommonTransactionData(
      hash: tx['hash']?.toString() ?? '',
      from: tx['from']?.toString() ?? '',
      to: tx['to']?.toString() ?? '',
      timestamp: timestamp,
      confirmations: confirmations,
      status: status,
    );
  }

  /// ETH 트랜잭션 조회
  Future<List<TransactionHistory>> _getEthTransactions(String address) async {
    return _fetchAlchemyTransactions(
      address: address,
      category: 'external',
    );
  }

  /// 토큰 트랜잭션 조회
  Future<List<TransactionHistory>> _getTokenTransactions(String address) async {
    return _fetchAlchemyTransactions(
      address: address,
      category: 'erc20',
    );
  }

  // 트랜잭션 데이터 처리 헬퍼 메소드
  List<TransactionHistory> _transactionJsonToTransactionHistory(
    Map<String, dynamic> data,
    String address,
    String category,
    bool isSent,
  ) {
    if (data['result']?['transfers'] == null) return [];

    return (data['result']['transfers'] as List)
        .map((tx) => _mapAlchemyTransactionToHistory(tx, address, category,
            isSent: isSent))
        .where((tx) => tx != TransactionHistory.empty)
        .toList();
  }

  @override
  void dispose() {
    httpClient.close();
  }
}
