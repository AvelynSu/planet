part of 'wallet_balance_service.dart';

class _BitcoinBalanceService implements _BlockchainBalanceService {
  final String _apiBaseUrl;
  final http.Client _httpClient;

  _BitcoinBalanceService({String? apiBaseUrl})
      : _apiBaseUrl = apiBaseUrl ?? WalletConfig().bitcoinApiUrl,
        _httpClient = http.Client();

  @override
  Future<TokenBalance> getTokenBalance({
    required String address,
    required TokenInfo info,
  }) async {
    try {
      if (info.symbol == "BTC") {
        // BlockCypher API를 사용하여 잔액 조회
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
        print('BlockCypher Response: $data'); // 응답 로깅

        // BlockCypher API는 'balance', 'unconfirmed_balance' 필드를 제공
        final int confirmedBalance = data['balance'] ?? 0;
        final int unconfirmedBalance = data['unconfirmed_balance'] ?? 0;

        // 전체 잔액 (확정 + 미확정)
        final int totalBalance = confirmedBalance + unconfirmedBalance;

        // satoshi를 BTC로 변환 (1 BTC = 100,000,000 satoshi)
        final double btcBalance = totalBalance / 100000000;

        return TokenBalance(
          address: address,
          info: info,
          balance: btcBalance,
        );
      } else {
        throw Exception('${info.symbol} is not supported on Bitcoin network');
      }
    } catch (e) {
      debugPrint('Error getting Bitcoin balance: $e');
      // return TokenBalance(
      //   address: address,
      //   info: info,
      //   balance: 0.001,
      // );
      throw Exception('Failed to get Bitcoin balance: $e');
    }
  }

  @override
  Future<List<TokenBalance>> getAllTokenBalances({
    required String walletAddress,
  }) async {
    try {
      // BTC만 가져오는 방식으로 간소화
      final TokenInfo btcInfo = TokenData.bitToken;

      final btcBalance = await getTokenBalance(
        address: walletAddress,
        info: btcInfo,
      );

      return [btcBalance];

      // 나중에 Omni USDT 등이 필요하면 추가할 수 있음
    } catch (e) {
      debugPrint('Error getting Bitcoin balance: $e');
      throw Exception('Failed to get Bitcoin balance');
    }
  }

  /// UTXO(미사용 트랜잭션 출력) 목록 가져오기
  /// 필요할 경우 사용
  Future<List<Map<String, dynamic>>> getUTXOs(String address) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(
            '$_apiBaseUrl/address/$address/utxo?token=${WalletConfig().blockCypherToken}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch Bitcoin UTXOs: ${response.statusCode}');
      }

      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Error getting Bitcoin UTXOs: $e');
      throw Exception('Failed to get Bitcoin UTXOs: $e');
    }
  }

  /// 트랜잭션 상세 조회
  /// 필요할 경우 사용
  Future<Map<String, dynamic>> getTransaction(String txid) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(
            '$_apiBaseUrl/tx/$txid?token=${WalletConfig().blockCypherToken}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch transaction: ${response.statusCode}');
      }

      return json.decode(response.body);
    } catch (e) {
      debugPrint('Error getting transaction: $e');
      throw Exception('Failed to get transaction: $e');
    }
  }

  @override
  void dispose() {
    _httpClient.close();
  }
}
