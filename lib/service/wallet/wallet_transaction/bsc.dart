part of 'transaction_history_service.dart';

/// BSC 거래 내역 서비스
class _BscHistoryService implements _BlockchainHistoryService {
  static const int _requestTimeout = 15;

  final config = WalletConfig.config;
  final httpClient = http.Client();

  @override
  Future<List<TransactionHistory>> getAllTransactions(String address) async {
    try {
      final results = await Future.wait([
        _getBnbTransactions(address),
        _getTokenTransactions(address),
      ]);

      final allTransactions = [
        ...results[0], // BNB 거래
        ...results[1], // 토큰 거래
      ];

      // 시간순 정렬 (최신순)
      allTransactions.sort((a, b) =>
          (b.timestamp ?? DateTime(0)).compareTo(a.timestamp ?? DateTime(0)));

      return allTransactions;
    } catch (e) {
      print('Failed to get all transactions: $e');
      return [];
    }
  }

  @override
  Future<List<TransactionHistory>> getSpecificTokenTransactions(
    String address,
    TokenInfo info,
  ) async {
    try {
      // BNB인 경우 BNB 트랜잭션만 반환
      if (info.symbol == "BNB") {
        try {
          return await _getBnbTransactions(address);
        } catch (e) {
          print('Error fetching BNB transactions: $e');
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
      print('Error fetching transactions for ${info.symbol}: $e');
      return [];
    }
  }

  /// Alchemy API를 사용하여 트랜잭션 내역 조회
  Future<List<TransactionHistory>> _fetchAlchemyTransactions({
    required String address,
    String category = 'native',
    String? contractAddress,
    int maxCount = 1000,
  }) async {
    try {
      Future<Map<String, dynamic>> makeRequest(
          Map<String, dynamic> body) async {
        final response = await httpClient
            .post(
              Uri.parse(config.bscRpcUrl), // ethRpcUrl -> bscRpcUrl
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

      // 보낸/받은 트랜잭션 요청
      var sentParams = {'fromAddress': address, ...params};
      var receivedParams = {'toAddress': address, ...params};

      final sentTxRequestBody = {
        'id': 1,
        'jsonrpc': '2.0',
        'method': 'alchemy_getAssetTransfers',
        'params': [sentParams],
      };

      final receivedTxRequestBody = {
        'id': 1,
        'jsonrpc': '2.0',
        'method': 'alchemy_getAssetTransfers',
        'params': [receivedParams],
      };

      final sentData = await makeRequest(sentTxRequestBody);
      final receivedData = await makeRequest(receivedTxRequestBody);

      return [
        ..._transactionJsonToTransactionHistory(
            sentData, address, category, true),
        ..._transactionJsonToTransactionHistory(
            receivedData, address, category, false),
      ];
    } catch (e) {
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
      final commonData = _extractCommonTransactionData(tx, isSent);
      if (commonData == null) return TransactionHistory.empty;

      double value = 0.0;
      if (category == 'external') {
        value = double.tryParse(tx['value']?.toString() ?? '0') ?? 0.0;
      } else if (category == 'erc20') {
        // rawContract.value에서 16진수 문자열을 가져와 처리
        final rawValue = tx['rawContract']?['value']?.toString() ?? '0';
        // 16진수 문자열에서 '0x' 제거 후 BigInt로 변환
        final bigIntValue = BigInt.parse(rawValue.replaceAll('0x', ''), radix: 16);
        // 18자리 소수점으로 나누어 실제 값으로 변환
        value = bigIntValue / BigInt.from(10).pow(18);
      }

      if (category == 'external') {
        return TransactionHistory.createBnbTransaction(commonData, value);
      } else if (category == 'erc20') {
        final tokenData = {
          ...tx,
          'value': value,  // 변환된 value 값 사용
          'contractAddress': tx['rawContract']?['address'],  // 컨트랙트 주소 추가
        };
        return TransactionHistory.createTokenTransaction(commonData, tokenData, value);
      }

      return TransactionHistory.empty;
    } catch (e) {
      print('Error mapping transaction: $e');
      return TransactionHistory.empty;
    }
  }

  AlchemyCommonTransactionData? _extractCommonTransactionData(
      Map<String, dynamic> tx, bool isSent) {
    final timestamp =
        DateTime.tryParse(tx['metadata']?['blockTimestamp']?.toString() ?? '');

    final isConfirmed = timestamp != null;
    final confirmations = isConfirmed ? 1 : 0;

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

  /// BNB 트랜잭션 조회
  Future<List<TransactionHistory>> _getBnbTransactions(String address) async {
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
