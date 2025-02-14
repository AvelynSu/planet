import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:planet/service/wallet/wallet_config.dart';

import '../../model/transaction_history.dart';

class WalletHistoryService {
  final config = WalletConfig();

  Future<List<TransactionHistory>> getEthTransactions(String address) async {
    final url = 'https://api.etherscan.io/api'
        '?module=account'
        '&action=txlist'
        '&address=$address'
        '&startblock=0'
        '&endblock=99999999'
        '&page=1'
        '&offset=100' // 최근 100개 거래
        '&sort=desc' // 최신순
        '&apikey=${config.etherscanApiKey}';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['status'] != '1') {
      throw Exception('Failed to get ETH transactions: ${data['message']}');
    }

    return (data['result'] as List)
        .map((tx) => TransactionHistory.fromEtherscanTx(tx, address))
        .toList();
  }

  Future<List<TransactionHistory>> getTokenTransactions(String address) async {
    final url = 'https://api.etherscan.io/api'
        '?module=account'
        '&action=tokentx'
        '&address=$address'
        '&startblock=0'
        '&endblock=99999999'
        '&page=1'
        '&offset=100' // 최근 100개 거래
        '&sort=desc' // 최신순
        '&apikey=${config.etherscanApiKey}';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['status'] != '1') {
      throw Exception('Failed to get token transactions: ${data['message']}');
    }

    return (data['result'] as List)
        .map((tx) => TransactionHistory.fromEtherscanTokenTx(tx, address))
        .toList();
  }

  /// 통합 거래 내역 조회 (ETH + 토큰)
  Future<List<TransactionHistory>> getAllTransactions(String address) async {
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
    allTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return allTransactions;
  }

  /// 특정 토큰의 거래 내역만 조회
  Future<List<TransactionHistory>> getSpecificTokenTransactions(
    String address,
    String tokenAddress,
  ) async {
    final allTokenTxs = await getTokenTransactions(address);
    return allTokenTxs
        .where((tx) =>
            tx.tokenAddress?.toLowerCase() == tokenAddress.toLowerCase())
        .toList();
  }
}

// 사용 예시:
// void example() async {
//   final service = WalletHistoryService();
//   final address = '0x123...';
//
//   try {
//     // 전체 거래 내역 조회
//     final transactions = await service.getAllTransactions(address);
//
//     for (var tx in transactions) {
//       print('${tx.timestamp} - ${tx.tokenSymbol} '
//           '${tx.isIncoming ? "받음" : "보냄"} ${tx.amount}');
//     }
//   } catch (e) {
//     print('Error: $e');
//   }
// }
