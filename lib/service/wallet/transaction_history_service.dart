import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:planet/model/token_info.dart';

import '../../model/transaction_history.dart';
import '../../util/wallet_config.dart';

class WalletHistoryService {
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

      if (data['status'] != '1') {
        // API 상태 코드가 성공이 아닌 경우
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

  /// 통합 거래 내역 조회 (ETH + 토큰)
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
      throw Exception('Failed to get all transactions: $e');
    }
  }

  /// 특정 토큰의 거래 내역만 조회
  Future<List<TransactionHistory>> getSpecificTokenTransactions(
    String address,
    TokenInfo info,
  ) async {
    try {
      // ETH인 경우 ETH 트랜잭션만 반환
      if (info.symbol == "ETH") {
        return await getEthTransactions(address);
      }

      // 토큰 트랜잭션 조회 후 특정 토큰으로 필터링
      final allTokenTxs = await getTokenTransactions(address);

      return allTokenTxs
          .where((tx) =>
              tx.tokenAddress?.toLowerCase() == info.address.toLowerCase())
          .toList();
    } catch (e) {
      // 특정 토큰 트랜잭션 조회 실패 시 처리
      print('Error fetching transactions for ${info.symbol}: $e');
      return []; // 빈 목록 반환하여 UI가 크래시되지 않도록 함
    }
  }

// /// 페이지네이션을 지원하는 트랜잭션 조회 (추가 기능)
// Future<Map<String, dynamic>> getPaginatedTransactions(
//   String address, {
//   int page = 1,
//   int offset = 100,
// }) async {
//   try {
//     final uri = Uri.https('api.etherscan.io', '/api', {
//       'module': 'account',
//       'action': 'txlist',
//       'address': address,
//       'startblock': '0',
//       'endblock': '99999999',
//       'page': page.toString(),
//       'offset': offset.toString(),
//       'sort': 'desc',
//       'apikey': config.etherscanApiKey,
//     });
//
//     final response = await http.get(uri);
//     final data = jsonDecode(response.body);
//
//     if (data['status'] != '1') {
//       throw Exception('Pagination request failed: ${data['message']}');
//     }
//
//     final transactions = (data['result'] as List)
//         .map((tx) => TransactionHistory.fromEtherscanTx(tx, address))
//         .where((e) => e != TransactionHistory.empty)
//         .toList();
//
//     return {
//       'transactions': transactions,
//       'hasMore': transactions.length >= offset,
//       'currentPage': page,
//     };
//   } catch (e) {
//     throw Exception('Failed to get paginated transactions: $e');
//   }
// }
}
