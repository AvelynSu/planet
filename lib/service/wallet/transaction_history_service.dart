import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:planet/model/token_info.dart';

import '../../enum/network_type.dart';
import '../../model/transaction_history.dart';
import '../../util/wallet_config.dart';

class WalletHistoryService {
  final config = WalletConfig();
  final Map<NetworkType, BlockchainHistoryService> _services = {};

  WalletHistoryService() {
    _services[NetworkType.ethereum] = EthereumHistoryService();
    _services[NetworkType.bitcoin] = BitcoinHistoryService();
  }

  /// 통합 거래 내역 조회 (모든 유형)
  Future<List<TransactionHistory>> getAllTransactions({
    required String address,
    required NetworkType networkType,
  }) {
    return _services[networkType]!.getAllTransactions(address);
  }

  /// 특정 토큰의 거래 내역만 조회
  Future<List<TransactionHistory>> getSpecificTokenTransactions({
    required String address,
    required TokenInfo info,
  }) {
    return _services[info.networkType]!
        .getSpecificTokenTransactions(address, info);
  }

  /// 서비스 종료 시 리소스 해제
  void dispose() {
    for (var service in _services.values) {
      service.dispose();
    }
  }
}

/// 블록체인별 거래 내역 서비스 인터페이스
abstract class BlockchainHistoryService {
  Future<List<TransactionHistory>> getAllTransactions(String address);
  Future<List<TransactionHistory>> getSpecificTokenTransactions(
      String address, TokenInfo info);
  void dispose();
}

/// 이더리움 거래 내역 서비스
class EthereumHistoryService implements BlockchainHistoryService {
  final config = WalletConfig();

  /// 공통 Etherscan API 요청 메서드
  Future<List<TransactionHistory>> _fetchEtherscanData({
    required String action,
    required String address,
    required TransactionHistory Function(Map<String, dynamic>, String) mapper,
    int offset = 100,
  }) async {
    final uri = Uri.https('api.etherscan.io', '/api', {
      'module': 'account',
      'action': action,
      'address': address,
      'startblock': '0',
      'endblock': '99999999',
      'page': '1',
      'offset': offset.toString(),
      'sort': 'desc',
      'apikey': config.etherscanApiKey,
    });

    try {
      final response = await http.get(uri).timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Request timed out'),
          );

      final data = jsonDecode(response.body);

      // Etherscan API가 "No transactions found"를 반환하는 경우를 정상 처리
      if (data['status'] == '0' && data['message'] == 'No transactions found') {
        return []; // 빈 목록 반환
      }

      if (data['status'] != '1') {
        // 다른 API 오류 상황
        throw Exception(
            '${action.toUpperCase()} request failed: ${data['message']}');
      }

      if (data['result'] is! List) {
        throw Exception('Unexpected API response format');
      }

      final result = (data['result'] as List)
          .map((tx) => mapper(tx as Map<String, dynamic>, address))
          .where((tx) => tx != TransactionHistory.empty)
          .toList();

      return result;
    } catch (e) {
      throw Exception('Failed to get $action transactions: $e');
    }
  }

  /// ETH 트랜잭션 조회
  Future<List<TransactionHistory>> getEthTransactions(String address) async {
    return _fetchEtherscanData(
      action: 'txlist',
      address: address,
      mapper: TransactionHistory.fromEtherscanTx,
    );
  }

  /// 토큰 트랜잭션 조회
  Future<List<TransactionHistory>> getTokenTransactions(String address) async {
    return _fetchEtherscanData(
      action: 'tokentx',
      address: address,
      mapper: TransactionHistory.fromEtherscanTokenTx,
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

      // 토큰 트랜잭션 조회 후 특정 토큰으로 필터링
      try {
        final allTokenTxs = await getTokenTransactions(address);
        return allTokenTxs
            .where((tx) =>
                tx.tokenAddress?.toLowerCase() == info.address.toLowerCase())
            .toList();
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
    // 필요한 리소스 정리
  }
}

/// 비트코인 거래 내역 서비스
class BitcoinHistoryService implements BlockchainHistoryService {
  final String _apiBaseUrl;
  final http.Client _httpClient;

  BitcoinHistoryService({String? apiBaseUrl})
      : _apiBaseUrl = apiBaseUrl ?? WalletConfig().bitcoinApiUrl,
        _httpClient = http.Client();

  @override
  Future<List<TransactionHistory>> getAllTransactions(String address) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_apiBaseUrl/addrs/$address/full?limit=50'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 15),
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
      final transactions = txs
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
