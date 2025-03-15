part of 'wallet_balance_service.dart';

class _EthereumBalanceService implements _BlockchainBalanceService {
  // 상수 정의
  static const String _METHOD_TOKEN_BALANCES = 'alchemy_getTokenBalances';
  static const String _JSON_RPC_VERSION = '2.0';

  final Web3Client web3client;

  _EthereumBalanceService()
      : web3client = Web3Client(WalletConfig().rpcUrl, http.Client());

  /// 이더리움 주소 변환 유틸리티 메서드
  EthereumAddress _hexToAddress(String address) {
    return EthereumAddress.fromHex(address);
  }

  /// 특정 토큰 1개의 잔액 조회
  @override
  Future<TokenBalance> getTokenBalance({
    required String address,
    required TokenInfo info,
  }) async {
    try {
      // ETH(네이티브 토큰)인 경우 web3client 사용
      if (info.symbol == "ETH") {
        final balance = await web3client.getBalance(_hexToAddress(address));
        final value = AppUtil.weiToEth(balance.getInWei);
        return TokenBalance(address: address, info: info, balance: value);
      }

      // ERC-20 토큰인 경우 Alchemy API 사용 시도
      try {
        // 토큰 주소 배열에 단일 주소 포함
        final balances =
            await _getTokenBalancesUsingAlchemy(address, [info.address]);

        // 성공적으로 잔액을 가져온 경우
        if (balances.isNotEmpty) {
          final contractAddr = balances.keys.first.toLowerCase();
          if (contractAddr == info.address.toLowerCase()) {
            final actualBalance =
                AppUtil.rawToActual(balances[contractAddr]!, info.decimals);
            return TokenBalance.fromInfo(info, address, actualBalance);
          }
        }

        // 결과가 없으면 컨트랙트 호출로 폴백
        return await _getTokenBalanceUsingContract(address, info);
      } catch (e) {
        debugPrint('Alchemy API error: $e, using contract call');
        return await _getTokenBalanceUsingContract(address, info);
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

    final rawBalance = result.first as BigInt;
    final actualBalance = AppUtil.rawToActual(rawBalance, info.decimals);
    return TokenBalance.fromInfo(info, address, actualBalance);
  }

  /// Alchemy API를 사용하여 토큰 잔액 조회 (단일 또는 배치)
  /// 반환값: Map<String, BigInt> - 토큰 컨트랙트 주소를 키로, 잔액을 값으로 하는 맵
  Future<Map<String, BigInt>> _getTokenBalancesUsingAlchemy(
      String ownerAddress, List<String> tokenAddresses) async {
    final uri = Uri.parse(WalletConfig().rpcUrl);
    final client = http.Client();

    try {
      final requestBody = json.encode({
        'id': 1,
        'jsonrpc': _JSON_RPC_VERSION,
        'method': _METHOD_TOKEN_BALANCES,
        'params': [ownerAddress, tokenAddresses],
      });

      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      final data = json.decode(response.body);

      if (data['error'] != null) {
        throw Exception('API Error: ${data['error']['message']}');
      }

      final result = <String, BigInt>{};

      if (data['result'] != null && data['result']['tokenBalances'] != null) {
        final tokenBalances = data['result']['tokenBalances'] as List;

        for (final balanceData in tokenBalances) {
          final contractAddress = balanceData['contractAddress'] as String;
          final hexBalance = balanceData['tokenBalance'] as String;

          // 16진수 문자열을 BigInt로 변환
          final rawBalance = hexBalance == '0x0'
              ? BigInt.zero
              : BigInt.parse(hexBalance.substring(2), radix: 16);

          result[contractAddress.toLowerCase()] = rawBalance;
        }
      }

      return result;
    } finally {
      client.close();
    }
  }

  /// 지갑의 모든 지원 토큰 잔액 조회
  @override
  Future<List<TokenBalance>> getAllTokenBalances(
      {required String walletAddress}) async {
    try {
      final results = <TokenBalance>[];

      // 1. ETH 잔액 조회 (네이티브 토큰)
      final ethToken = TokenData.ethTokens.firstWhere((t) => t.symbol == "ETH");
      final ethBalance =
          await getTokenBalance(address: walletAddress, info: ethToken);
      results.add(ethBalance);

      // 2. ERC-20 토큰 주소 목록 가져오기
      final erc20Tokens =
          TokenData.ethTokens.where((token) => token.symbol != "ETH").toList();
      if (erc20Tokens.isEmpty) {
        return results; // ETH만 있는 경우
      }

      final tokenAddresses = erc20Tokens.map((token) => token.address).toList();

      try {
        // 3. Alchemy API로 한 번에 모든 토큰 잔액 조회
        final tokenBalances =
            await _getTokenBalancesUsingAlchemy(walletAddress, tokenAddresses);

        // 4. 결과 처리
        for (final token in erc20Tokens) {
          final contractAddr = token.address.toLowerCase();
          if (tokenBalances.containsKey(contractAddr)) {
            // Alchemy API에서 결과를 얻은 경우
            final rawBalance = tokenBalances[contractAddr]!;
            final actualBalance =
                AppUtil.rawToActual(rawBalance, token.decimals);
            results.add(
                TokenBalance.fromInfo(token, walletAddress, actualBalance));
          } else {
            // Alchemy API에서 결과를 얻지 못한 경우 컨트랙트 호출
            try {
              final balance =
                  await _getTokenBalanceUsingContract(walletAddress, token);
              results.add(balance);
            } catch (e) {
              debugPrint('Error getting balance for ${token.symbol}: $e');
              // 오류가 있어도 계속 진행 (0 잔액으로 처리)
              results.add(TokenBalance.fromInfo(token, walletAddress, 0));
            }
          }
        }
      } catch (e) {
        debugPrint(
            'Batch query failed: $e, falling back to individual queries');
        // Alchemy API 실패 시 개별 조회로 폴백
        final erc20Balances = await Future.wait(erc20Tokens.map(
            (token) => getTokenBalance(address: walletAddress, info: token)));
        results.addAll(erc20Balances);
      }

      return results;
    } catch (e) {
      debugPrint('Error in getAllTokenBalances: $e');
      throw Exception('Failed to get all token balances: $e');
    }
  }

  /// 서비스 종료 시 리소스 해제
  @override
  void dispose() {
    web3client.dispose();
  }
}
