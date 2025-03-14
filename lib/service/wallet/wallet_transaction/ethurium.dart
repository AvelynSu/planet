part of 'transaction_history_service.dart';

/// 이더리움 거래 내역 서비스
class _EthereumHistoryService implements _BlockchainHistoryService {
  final config = WalletConfig();
  final httpClient = http.Client();

  /// Alchemy API를 사용하여 트랜잭션 내역 조회
  Future<List<TransactionHistory>> _fetchAlchemyTransactions({
    required String address,
    String category = 'external',
    String? contractAddress,
    int maxCount = 100,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'id': 1,
        'jsonrpc': '2.0',
        'method': 'alchemy_getAssetTransfers',
        'params': [
          {
            'fromBlock': '0x0',
            'toBlock': 'latest',
            'category': [category],
            'withMetadata': true,
            'maxCount': '0x${maxCount.toRadixString(16)}',
            'order': 'desc',
          }
        ],
      };

      // 특정 토큰에 대한 조회인 경우
      if (contractAddress != null) {
        requestBody['params'][0]['contractAddresses'] = [contractAddress];
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

      final uri = Uri.parse('${config.rpcUrl}');

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
            .map((tx) => _mapAlchemyTransactionToHistory(tx, address, category,
                isSent: true))
            .where((tx) => tx != TransactionHistory.empty)
            .toList());
      }

      // 받은 트랜잭션 처리
      if (dataReceived['result'] != null &&
          dataReceived['result']['transfers'] != null) {
        final transfers = dataReceived['result']['transfers'] as List;
        result.addAll(transfers
            .map((tx) => _mapAlchemyTransactionToHistory(tx, address, category,
                isSent: false))
            .where((tx) => tx != TransactionHistory.empty)
            .toList());
      }

      return result;
    } catch (e) {
      print('Failed to get transactions: $e');
      throw Exception('Failed to get transactions: $e');
    }
  }

  /// Alchemy 트랜잭션 데이터를 TransactionHistory 객체로 변환
  TransactionHistory _mapAlchemyTransactionToHistory(
      Map<String, dynamic> tx, String userAddress, String category,
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

      // ETH 또는 토큰 처리
      if (category == 'external') {
        // ETH 트랜잭션
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
          tokenSymbol: 'ETH',
          amount: value,
          confirmations: confirmations,
          isSuccess: true,
          decimals: 18,
          tokenAddress: null,
          fee: null,
          gas: null,
          gasPrice: null,
          gasUsed: null,
          status: status,
        );
      } else if (category == 'erc20') {
        // ERC-20 토큰 트랜잭션
        final tokenAddress = tx['rawContract'] != null
            ? tx['rawContract']['address']?.toString()
            : null;

        int decimal = 18;
        if (tx['rawContract'] != null && tx['rawContract']['decimal'] != null) {
          if (tx['rawContract']['decimal'] is String) {
            decimal = int.tryParse(tx['rawContract']['decimal']) ?? 18;
          } else if (tx['rawContract']['decimal'] is num) {
            decimal = (tx['rawContract']['decimal'] as num).toInt();
          }
        }

        final tokenSymbol = tx['asset']?.toString();

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
          decimals: decimal,
          tokenAddress: tokenAddress,
          fee: null,
          gas: null,
          gasPrice: null,
          gasUsed: null,
          status: status,
        );
      }

      return TransactionHistory.empty;
    } catch (e) {
      print('Error mapping transaction: $e');
      return TransactionHistory.empty;
    }
  }

  /// ETH 트랜잭션 조회
  Future<List<TransactionHistory>> getEthTransactions(String address) async {
    return _fetchAlchemyTransactions(
      address: address,
      category: 'external',
    );
  }

  /// 토큰 트랜잭션 조회
  Future<List<TransactionHistory>> getTokenTransactions(String address) async {
    return _fetchAlchemyTransactions(
      address: address,
      category: 'erc20',
    );
  }

  @override
  Future<List<TransactionHistory>> getAllTransactions(String address) async {
    try {
      // ETH와 토큰 거래 내역을 병렬로 조회
      final results = await Future.wait([
        getEthTransactions(address),
        getTokenTransactions(address),
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
          return await getEthTransactions(address);
        } catch (e) {
          print('Error fetching ETH transactions: $e');
          // 트랜잭션을 찾을 수 없는 경우 빈 목록 반환
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
      return []; // 빈 목록 반환하여 UI가 크래시되지 않도록 함
    }
  }

  @override
  void dispose() {
    httpClient.close();
  }
}
