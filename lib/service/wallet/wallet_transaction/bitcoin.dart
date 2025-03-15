part of 'transaction_history_service.dart';

/// 비트코인 거래 내역 서비스
class _BitcoinHistoryService implements _BlockchainHistoryService {
  static const int _requestTimeout = 15;

  final String _apiBaseUrl;
  final http.Client _httpClient;

  _BitcoinHistoryService({String? apiBaseUrl})
      : _apiBaseUrl = apiBaseUrl ?? WalletConfig().bitcoinApiUrl,
        _httpClient = http.Client();

  String _buildTransactionUrl(String address) {
    return '$_apiBaseUrl/addrs/$address/full?limit=50?token=${WalletConfig().blockCypherToken}';
  }

  List<TransactionHistory> _processTransactions(List txs, String address) {
    return txs
        .map((tx) {
          try {
            return TransactionHistory.fromBlockCypherTx(tx, address);
          } catch (e) {
            print('Error mapping Bitcoin transaction: $e');
            return TransactionHistory.empty;
          }
        })
        .where((tx) => tx != TransactionHistory.empty)
        .toList();
  }

  @override
  Future<List<TransactionHistory>> getAllTransactions(String address) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(_buildTransactionUrl(address)),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: _requestTimeout),
        onTimeout: () => throw Exception('Request timed out'),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch Bitcoin transactions: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final List txs = data['txs'] ?? [];

      if (txs.isEmpty) {
        return [];
      }

      // BlockCypher API 응답에서 트랜잭션 매핑
      final transactions = _processTransactions(txs, address);

      // 시간순 정렬 (최신순)
      transactions.sort((a, b) =>
          (b.timestamp ?? DateTime(0)).compareTo(a.timestamp ?? DateTime(0)));

      return transactions;
    } catch (e) {
      print('Error fetching Bitcoin transactions: $e');
      // 오류 발생 시 빈 리스트 반환하여 UI가 크래시되지 않도록 함
      return [];
    }
  }

  @override
  Future<List<TransactionHistory>> getSpecificTokenTransactions(
    String address,
    TokenInfo info,
  ) async {
    // 비트코인에서는 BTC만 처리 (현재 다른 토큰을 지원하지 않음)
    if (info.symbol == "BTC") {
      return getAllTransactions(address);
    }

    // 지원하지 않는 토큰인 경우 빈 리스트 반환
    print('Token ${info.symbol} is not supported on Bitcoin network');
    return [];
  }

  @override
  void dispose() {
    _httpClient.close();
  }
}
