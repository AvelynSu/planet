part of 'wallet_balance_service.dart';

class _SolanaBalanceService implements _BlockchainBalanceService {
  final sol.SolanaClient _solanaClient;

  _SolanaBalanceService()
      : _solanaClient = sol.SolanaClient(
          rpcUrl: Uri.parse(WalletConfig.config.solanaRpcUrl),
          websocketUrl:
              Uri.parse(WalletConfig.config.getWsUrlForNetwork("solana")),
        );

  /// 특정 토큰 1개의 잔액 조회
  @override
  Future<TokenBalance> getTokenBalance({
    required String address,
    required TokenInfo info,
  }) async {
    try {
      // SOL(네이티브 토큰)인 경우
      if (info.symbol == "SOL") {
        final balance = await _solanaClient.rpcClient.getBalance(address);
        final value = AppUtil.lamportsToSol(balance.value, info.decimals);
        return TokenBalance(address: address, info: info, balance: value);
      }

      // SPL 토큰인 경우
      return await _getSPLTokenBalance(address, info);
    } catch (e) {
      debugPrint('Error getting ${info.symbol} balance: $e');
      throw Exception('Failed to get ${info.symbol} balance');
    }
  }

  /// SPL 토큰 잔액 조회
  Future<TokenBalance> _getSPLTokenBalance(
      String address, TokenInfo info) async {
    try {
      final accounts = await _solanaClient.rpcClient.getTokenAccountsByOwner(
        address,
        sol_dto.TokenAccountsFilter.byMint(info.address),
        encoding: sol_dto.Encoding.jsonParsed,
      );

      if (accounts.value.isEmpty) {
        return TokenBalance.fromInfo(info, address, 0);
      }

      final accountInfo = await _solanaClient.rpcClient
          .getTokenAccountBalance(accounts.value.first.pubkey);

      final amount = double.parse(accountInfo.value.uiAmountString ?? '0');
      return TokenBalance.fromInfo(info, address, amount);
    } catch (e) {
      debugPrint('Error getting SPL token balance: $e');
      return TokenBalance.fromInfo(info, address, 0);
    }
  }

  /// 지갑의 모든 지원 토큰 잔액 조회
  @override
  Future<List<TokenBalance>> getAllTokenBalances({
    required String walletAddress,
  }) async {
    try {
      final results = <TokenBalance>[];

      // 1. SOL 잔액 조회 (네이티브 토큰)
      final solToken =
          TokenData.solanaTokens.firstWhere((t) => t.symbol == "SOL");
      final solBalance =
          await getTokenBalance(address: walletAddress, info: solToken);
      results.add(solBalance);

      // 2. SPL 토큰 병렬 조회
      final splTokens = TokenData.solanaTokens
          .where((token) => token.symbol != "SOL")
          .toList();

      if (splTokens.isEmpty) {
        return results;
      }

      final splBalances = await Future.wait(
        splTokens.map(
          (token) => _getSPLTokenBalance(walletAddress, token).catchError(
            (e) {
              debugPrint('Error getting balance for ${token.symbol}: $e');
              return TokenBalance.fromInfo(token, walletAddress, 0);
            },
          ),
        ),
      );

      results.addAll(splBalances);
      return results;
    } catch (e) {
      debugPrint('Error in getAllTokenBalances: $e');
      throw Exception('Failed to get all token balances: $e');
    }
  }

  @override
  void dispose() {
    debugPrint('Disposing Solana balance service');
  }
}
