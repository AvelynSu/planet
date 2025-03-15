part of 'transaction_history_service.dart';

/// 솔라나 거래 내역 서비스
class _SolanaHistoryService implements _BlockchainHistoryService {
  final config = WalletConfig();
  final httpClient = http.Client();

  /// Alchemy API를 사용하여 트랜잭션 내역 조회
  Future<List<TransactionHistory>> _fetchAlchemyTransactions({
    required String address,
    String? tokenMintAddress,
    int maxCount = 100,
  }) async {
    try {
      // 1. 일반 솔 트랜잭션과 SPL 토큰 트랜잭션을 구분하여 조회
      final Map<String, dynamic> requestBody = {
        'id': 1,
        'jsonrpc': '2.0',
        'method': 'alchemy_getAssetTransfers',
        'params': [
          {
            'fromBlock': '0x0',
            'toBlock': 'latest',
            'category': ['solana'],
            'withMetadata': true,
            'maxCount': '0x${maxCount.toRadixString(16)}',
            'order': 'desc',
          }
        ],
      };

      // 특정 토큰에 대한 조회인 경우
      if (tokenMintAddress != null) {
        requestBody['params'][0]['contractAddresses'] = [tokenMintAddress];
      }

      // 주소 필터링 (보내거나 받은 모든 트랜잭션)
      requestBody['params'][0]['fromAddress'] = address;

      // 다음 요청을 위해 참조에 null을 지우는 "두 번째" 요청 준비
      final secondRequestBody = Map<String, dynamic>.from(requestBody);
      secondRequestBody['params'] = List.from(requestBody['params']);
      secondRequestBody['params'][0] =
          Map<String, dynamic>.from(requestBody['params'][0]);
      secondRequestBody['params'][0].remove('fromAddress');
      secondRequestBody['params'][0]['toAddress'] = address;

      final uri = Uri.parse(config.solanaRpcUrl);

      // 첫 번째 요청 (보낸 트랜잭션)
      final response = await httpClient
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Request timed out'),
          );

      // 두 번째 요청 (받은 트랜잭션)
      final responseReceived = await httpClient
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(secondRequestBody),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Request timed out'),
          );

      final data = jsonDecode(response.body);
      final dataReceived = jsonDecode(responseReceived.body);

      List<TransactionHistory> result = [];

      // 보낸 트랜잭션 처리
      if (data['result'] != null && data['result']['transfers'] != null) {
        final transfers = data['result']['transfers'] as List;
        result.addAll(transfers
            .map((tx) =>
                _mapAlchemyTransactionToHistory(tx, address, isSent: true))
            .where((tx) => tx != TransactionHistory.empty)
            .toList());
      }

      // 받은 트랜잭션 처리
      if (dataReceived['result'] != null &&
          dataReceived['result']['transfers'] != null) {
        final transfers = dataReceived['result']['transfers'] as List;
        result.addAll(transfers
            .map((tx) =>
                _mapAlchemyTransactionToHistory(tx, address, isSent: false))
            .where((tx) => tx != TransactionHistory.empty)
            .toList());
      }

      return result;
    } catch (e) {
      print('Failed to get Solana transactions: $e');
      throw Exception('Failed to get Solana transactions: $e');
    }
  }

  /// Alchemy 트랜잭션 데이터를 TransactionHistory 객체로 변환
  TransactionHistory _mapAlchemyTransactionToHistory(
      Map<String, dynamic> tx, String userAddress,
      {bool isSent = false}) {
    try {
      final timestamp =
          tx['metadata'] != null && tx['metadata']['blockTimestamp'] != null
              ? DateTime.parse(tx['metadata']['blockTimestamp'].toString())
              : null;

      final hash = tx['hash']?.toString() ?? '';
      final from = tx['from']?.toString() ?? '';
      final to = tx['to']?.toString() ?? '';

      // 확인 수 계산
      int confirmations = 1; // 기본값
      if (tx['metadata'] != null && tx['metadata']['blockNumber'] != null) {
        confirmations = 1;
      }

      // 트랜잭션 상태 판별
      TransactionHistoryStatus status;
      if (confirmations == 0) {
        status = TransactionHistoryStatus.isPending;
      } else {
        status = isSent
            ? TransactionHistoryStatus.isSent
            : TransactionHistoryStatus.isReceived;
      }

      // SOL 또는 토큰 트랜잭션 처리
      final asset = tx['asset']?.toString() ?? '';
      final tokenAddress = tx['tokenAddress']?.toString();
      final tokenSymbol = asset.isEmpty ? 'SOL' : asset;

      // 토큰인지 SOL인지에 따라 데시멀 설정
      int decimals = 9; // SOL은 9 데시멀 기본값
      if (tokenAddress != null && tokenAddress.isNotEmpty) {
        // 토큰인 경우 해당 토큰의 데시멀 찾기
        final token = TokenData.solanaTokens.firstWhere(
          (t) => t.address.toLowerCase() == tokenAddress.toLowerCase(),
          orElse: () => TokenInfo(
            symbol: tokenSymbol,
            name: tokenSymbol,
            address: tokenAddress,
            decimals: 9,
            // 기본값
            logoUrl: '',
            coingeckoKey: '',
          ),
        );
        decimals = token.decimals;
      }

      // 금액 처리
      double value = 0.0;
      if (tx['value'] != null) {
        // 문자열이나 숫자 모두 처리
        if (tx['value'] is String) {
          value = double.tryParse(tx['value']) ?? 0.0;
        } else if (tx['value'] is num) {
          value = (tx['value'] as num).toDouble();
        }
      }

      return TransactionHistory(
        hash: hash,
        from: from,
        to: to,
        timestamp: timestamp,
        tokenSymbol: tokenSymbol,
        amount: value,
        confirmations: confirmations,
        isSuccess: true,
        decimals: decimals,
        tokenAddress: tokenAddress,
        fee: null,
        // 수수료 정보는 별도로 조회 필요
        gas: null,
        gasPrice: null,
        gasUsed: null,
        status: status,
      );
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

  /// 솔라나 주소의 모든 트랜잭션 조회 (SOL + 모든 SPL 토큰)
  @override
  Future<List<TransactionHistory>> getAllTransactions(String address) async {
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

  /// 서비스 종료 시 리소스 해제
  @override
  void dispose() {
    httpClient.close();
  }
}
