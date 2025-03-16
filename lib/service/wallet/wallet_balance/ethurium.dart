part of 'wallet_balance_service.dart';

class _EthereumBalanceService implements _BlockchainBalanceService {
  final Web3Client web3client;

  _EthereumBalanceService()
      : web3client = Web3Client(
          WalletConfig().ethRpcUrl,
          http.Client(),
        );

  /// 특정 토큰 1개의 잔액 조회
  @override
  Future<TokenBalance> getTokenBalance({
    required String address,
    required TokenInfo info,
  }) async {
    try {
      // ETH(네이티브 토큰)인 경우 web3client 사용
      if (info.symbol == "ETH") {
        final balance =
            await web3client.getBalance(AppUtil.hexToEthereumAddress(address));
        final value = AppUtil.weiToEth(balance.getInWei);
        return TokenBalance(address: address, info: info, balance: value);
      }

      // ERC-20 토큰은 직접 컨트랙트 호출
      return await _getTokenBalanceUsingContract(address, info);
    } catch (e) {
      debugPrint('Error getting ${info.symbol} balance: $e');
      throw Exception('Failed to get ${info.symbol} balance');
    }
  }

  /// 지갑의 모든 지원 토큰 잔액 조회
  @override
  Future<List<TokenBalance>> getAllTokenBalances({
    required String walletAddress,
  }) async {
    try {
      final results = <TokenBalance>[];

      // 1. ETH 잔액 조회 (네이티브 토큰)
      final ethToken = TokenData.ethTokens.firstWhere((t) => t.symbol == "ETH");
      final ethBalance =
          await getTokenBalance(address: walletAddress, info: ethToken);
      results.add(ethBalance);

      // 2. ERC-20 토큰 병렬 조회
      final erc20Tokens =
          TokenData.ethTokens.where((token) => token.symbol != "ETH").toList();
      if (erc20Tokens.isEmpty) {
        return results;
      }

      final erc20Balances = await Future.wait(
        erc20Tokens.map(
          (token) =>
              _getTokenBalanceUsingContract(walletAddress, token).catchError(
            (e) {
              debugPrint('Error getting balance for ${token.symbol}: $e');
              return TokenBalance.fromInfo(token, walletAddress, 0);
            },
          ),
        ),
      );

      results.addAll(erc20Balances);
      return results;
    } catch (e) {
      debugPrint('Error in getAllTokenBalances: $e');
      throw Exception('Failed to get all token balances: $e');
    }
  }

  /// 기존 컨트랙트 호출 방식으로 토큰 잔액 조회 (폴백 메서드)
  Future<TokenBalance> _getTokenBalanceUsingContract(
      String address, TokenInfo info) async {
    // DeployedContract : 이더리움 스마트컨트렉트와 상호작용 하기 위한 객체
    final contract = DeployedContract(
      ContractAbi.fromJson(TokenAbi.ERC20, 'ERC20'),
      AppUtil.hexToEthereumAddress(info.address),
    );

    final balanceFunction = contract.function('balanceOf');
    final result = await web3client.call(
      contract: contract,
      function: balanceFunction,
      params: [AppUtil.hexToEthereumAddress(address)],
    );

    final rawBalance = result.first as BigInt;
    final actualBalance = AppUtil.weiToEth(rawBalance, decimals: info.decimals);
    return TokenBalance.fromInfo(info, address, actualBalance);
  }

  /// 서비스 종료 시 리소스 해제
  @override
  void dispose() {
    web3client.dispose();
  }
}
