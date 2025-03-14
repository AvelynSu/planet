part of 'wallet_balance_service.dart';

class _EthereumBalanceService implements _BlockchainBalanceService {
  final Web3Client web3client;
  final http.Client httpClient = http.Client();

  _EthereumBalanceService()
      : web3client = Web3Client(WalletConfig().rpcUrl, http.Client());

  _hexToAddress(String address) {
    return EthereumAddress.fromHex(address);
  }

  /// 특정 토큰 1개의 잔액 조회
  @override
  Future<TokenBalance> getTokenBalance({
    required String address, // 잔액을 조회할 지갑 주소
    required TokenInfo info, // 토큰 정보
  }) async {
    try {
      // ETH(네이티브 토큰)인 경우
      if (info.symbol == "ETH") {
        final balance = await web3client.getBalance(_hexToAddress(address));
        var value = AppUtil.weiToEth(balance.getInWei);
        return TokenBalance(address: address, info: info, balance: value);
      }
      // ERC-20 토큰인 경우
      else {
        // Alchemy API를 사용하여 단일 토큰 잔액 조회
        try {
          final uri = Uri.parse('${WalletConfig().rpcUrl}');

          final requestBody = json.encode({
            'id': 1,
            'jsonrpc': '2.0',
            'method': 'alchemy_getTokenBalances',
            'params': [
              address,
              [info.address]
            ]
          });

          final response = await httpClient.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          );

          final data = json.decode(response.body);

          if (data['error'] != null) {
            throw Exception('API Error: ${data['error']['message']}');
          }

          if (data['result'] != null &&
              data['result']['tokenBalances'] != null) {
            final tokenBalances = data['result']['tokenBalances'] as List;
            if (tokenBalances.isNotEmpty) {
              final hexBalance = tokenBalances[0]['tokenBalance'] as String;
              // 16진수 문자열을 BigInt로 변환 (0x 제거)
              final rawBalance = hexBalance == '0x0'
                  ? BigInt.zero
                  : BigInt.parse(hexBalance.substring(2), radix: 16);

              // 토큰의 decimals에 따라 변환
              final actualBalance =
                  AppUtil.rawToActual(rawBalance, info.decimals);
              return TokenBalance.fromInfo(info, address, actualBalance);
            }
          }

          // API 응답이 예상과 다른 경우 기존 방식으로 폴백
          return await _getTokenBalanceUsingContract(address, info);
        } catch (alchemyError) {
          debugPrint(
              'Alchemy API error: $alchemyError, falling back to contract call');
          return await _getTokenBalanceUsingContract(address, info);
        }
      }
    } catch (e) {
      debugPrint('Error getting ${info.symbol} balance: $e');
      throw Exception('Failed to get ${info.symbol} balance');
    }
  }

  /// 기존 컨트랙트 호출 방식으로 토큰 잔액 조회 (폴백 메서드)
  Future<TokenBalance> _getTokenBalanceUsingContract(
      String address, TokenInfo info) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(TokenAbi.ERC20, 'ERC20'),
      _hexToAddress(info.address),
    );

    final balanceFunction = contract.function('balanceOf');
    final result = await web3client.call(
      contract: contract,
      function: balanceFunction,
      params: [_hexToAddress(address)],
    );

    var rawBalance = result.first as BigInt;
    final actualBalance = AppUtil.rawToActual(rawBalance, info.decimals);
    return TokenBalance.fromInfo(info, address, actualBalance);
  }

  /// 지갑의 모든 지원 토큰 잔액 조회 (배치 요청 사용)
  @override
  Future<List<TokenBalance>> getAllTokenBalances(
      {required String walletAddress}) async {
    try {
      final results = <TokenBalance>[];

      // 1. ETH 잔액 별도 조회 (네이티브 토큰)
      final ethToken = TokenData.ethTokens.firstWhere((t) => t.symbol == "ETH");
      final ethBalance =
          await getTokenBalance(address: walletAddress, info: ethToken);
      results.add(ethBalance);

      // 2. 나머지 ERC-20 토큰 잔액을 배치로 조회
      final tokenAddresses = TokenData.ethTokens
          .where((token) => token.symbol != "ETH")
          .map((token) => token.address)
          .toList();

      if (tokenAddresses.isEmpty) {
        return results; // ETH만 있는 경우
      }

      // Alchemy API를 사용한 배치 토큰 잔액 조회
      final uri = Uri.parse('${WalletConfig().rpcUrl}');

      final requestBody = json.encode({
        'id': 1,
        'jsonrpc': '2.0',
        'method': 'alchemy_getTokenBalances',
        'params': [walletAddress, tokenAddresses]
      });

      final response = await httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      final data = json.decode(response.body);

      if (data['error'] != null) {
        throw Exception('API Error: ${data['error']['message']}');
      }

      if (data['result'] != null && data['result']['tokenBalances'] != null) {
        final tokenBalances = data['result']['tokenBalances'] as List;

        // 각 토큰 잔액 처리
        for (final balanceData in tokenBalances) {
          final contractAddress = balanceData['contractAddress'] as String;
          final hexBalance = balanceData['tokenBalance'] as String;

          // 해당 토큰 정보 찾기
          final tokenInfo = TokenData.ethTokens.firstWhere(
            (t) => t.address.toLowerCase() == contractAddress.toLowerCase(),
            orElse: () => TokenData.ethTokens.first, // 기본값 (오류 방지)
          );

          // 토큰 주소가 일치하는 경우에만 처리
          if (tokenInfo.address.toLowerCase() ==
              contractAddress.toLowerCase()) {
            // 16진수 문자열을 BigInt로 변환
            final rawBalance = hexBalance == '0x0'
                ? BigInt.zero
                : BigInt.parse(hexBalance.substring(2), radix: 16);

            // 토큰의 decimals에 따라 변환
            final actualBalance =
                AppUtil.rawToActual(rawBalance, tokenInfo.decimals);

            results.add(
                TokenBalance.fromInfo(tokenInfo, walletAddress, actualBalance));
          }
        }
      }

      // 3. 모든 토큰이 처리되지 않은 경우 개별적으로 조회
      // 필요한 토큰 목록 가져오기
      final processedAddresses = results
          .where((tb) => tb.info.symbol != "ETH")
          .map((tb) => tb.info.address.toLowerCase())
          .toList();

      final missingTokens = TokenData.ethTokens
          .where((token) =>
              token.symbol != "ETH" &&
              !processedAddresses.contains(token.address.toLowerCase()))
          .toList();

      if (missingTokens.isNotEmpty) {
        debugPrint('일부 토큰(${missingTokens.length}개)은 개별 조회 중...');

        // 누락된 토큰 잔액 개별 조회
        final missingBalances = await Future.wait(missingTokens.map(
            (token) => _getTokenBalanceUsingContract(walletAddress, token)));

        results.addAll(missingBalances);
      }

      return results;
    } catch (e) {
      debugPrint('Error getting all balances: $e');

      // 오류 발생 시 기존 방법으로 대체
      debugPrint('Falling back to individual token queries...');
      final futures = TokenData.ethTokens
          .map((token) => getTokenBalance(address: walletAddress, info: token));

      final balances = await Future.wait(futures);
      return balances;
    }
  }

  /// 서비스 종료 시 리소스 해제
  @override
  void dispose() {
    web3client.dispose();
    httpClient.close();
  }
}
