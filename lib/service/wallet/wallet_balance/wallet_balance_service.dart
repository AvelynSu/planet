import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:planet/model/token_balance.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/util/app_util.dart';
import 'package:planet/util/data/token_abi.dart';
import 'package:solana/dto.dart' as sol_dto;
import 'package:solana/solana.dart' as sol;
import 'package:web3dart/web3dart.dart';

import '../../../enum/network_type.dart';
import '../../../util/data/token_data.dart';
import '../../../util/wallet_config.dart';

part 'bitcoin.dart';
part 'bsc.dart';
part 'ethurium.dart';
part 'solana.dart';

class WalletBalanceService {
  final Map<NetworkType, _BlockchainBalanceService> _services = {};

  WalletBalanceService() {
    _services[NetworkType.ethereum] = _EthereumBalanceService();
    _services[NetworkType.bitcoin] = _BitcoinBalanceService();
    _services[NetworkType.solana] = _SolanaBalanceService();
    _services[NetworkType.bsc] = _BscBalanceService();
  }

  Future<TokenBalance> getTokenBalance({
    required String address,
    required TokenInfo info,
    required NetworkType networkType,
  }) {
    return _services[networkType]!.getTokenBalance(
      address: address,
      info: info,
    );
  }

  Future<List<TokenBalance>> getAllTokenBalances({
    required String walletAddress,
    required NetworkType networkType,
  }) {
    return _services[networkType]!.getAllTokenBalances(
      walletAddress: walletAddress,
    );
  }

  void dispose() {
    for (var service in _services.values) {
      service.dispose();
    }
  }
}

/// -------------------
abstract class _BlockchainBalanceService {
  Future<TokenBalance> getTokenBalance({
    required String address,
    required TokenInfo info,
  });

  Future<List<TokenBalance>> getAllTokenBalances({
    required String walletAddress,
  });

  void dispose();
}
