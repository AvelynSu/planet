part of 'wallet_balance_service.dart';

class _BitcoinBalanceService implements _BlockchainBalanceService {
  final String _apiBaseUrl;
  final http.Client _httpClient;

  _BitcoinBalanceService({String? apiBaseUrl})
      : _apiBaseUrl = apiBaseUrl ?? WalletConfig().bitcoinApiUrl,
        _httpClient = http.Client();

  /// 특정 주소의 BTC 잔액 조회
  Future<TokenBalance> _getBTCBalance(String address, TokenInfo info) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(
            '$_apiBaseUrl/addrs/$address?token=${WalletConfig().blockCypherToken}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch Bitcoin balance: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      final int confirmedBalance = data['balance'] ?? 0;
      final int unconfirmedBalance = data['unconfirmed_balance'] ?? 0;
      final int totalSatoshi = confirmedBalance + unconfirmedBalance;

      return TokenBalance.fromInfo(
        info,
        address,
        AppUtil.satoshiToBtc(totalSatoshi),
      );
    } catch (e) {
      debugPrint('Error getting BTC balance: $e');
      throw Exception('Failed to get BTC balance: $e');
    }
  }

  @override
  Future<TokenBalance> getTokenBalance({
    required String address,
    required TokenInfo info,
  }) async {
    try {
      if (info.symbol == "BTC") {
        return await _getBTCBalance(address, info);
      }
      throw Exception('${info.symbol} is not supported on Bitcoin network');
    } catch (e) {
      debugPrint('Error getting ${info.symbol} balance: $e');
      throw Exception('Failed to get ${info.symbol} balance');
    }
  }

  @override
  Future<List<TokenBalance>> getAllTokenBalances({
    required String walletAddress,
  }) async {
    try {
      final btcBalance = await getTokenBalance(
        address: walletAddress,
        info: TokenData.bitToken,
      );

      return [btcBalance];
    } catch (e) {
      debugPrint('Error in getAllTokenBalances: $e');
      throw Exception('Failed to get all token balances');
    }
  }

  @override
  void dispose() {
    _httpClient.close();
  }
}
