import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:planet/model/token_info.dart';

import '../../../enum/network_type.dart';
import '../../../model/transaction_history.dart';
import '../../../util/data/token_data.dart';
import '../../../util/wallet_config.dart';

part 'bitcoin.dart';
part 'ethurium.dart';
part 'solana.dart';

class WalletHistoryService {
  final config = WalletConfig();
  final Map<NetworkType, _BlockchainHistoryService> _services = {};

  WalletHistoryService() {
    _services[NetworkType.ethereum] = _EthereumHistoryService();
    _services[NetworkType.bitcoin] = _BitcoinHistoryService();
    _services[NetworkType.solana] = _SolanaHistoryService();
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
abstract class _BlockchainHistoryService {
  Future<List<TransactionHistory>> getAllTransactions(String address);

  Future<List<TransactionHistory>> getSpecificTokenTransactions(
      String address, TokenInfo info);

  void dispose();
}
