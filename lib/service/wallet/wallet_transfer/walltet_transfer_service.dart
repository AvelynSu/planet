import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bitcoin/flutter_bitcoin.dart' as btc;
import 'package:http/http.dart' as http;
import 'package:planet/model/custom_exception.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/service/wallet/wallet_service.dart';
import 'package:planet/util/data/token_data.dart';
import 'package:solana/dto.dart' as sol_dto;
import 'package:solana/solana.dart' as sol;
import 'package:solana_web3/programs.dart';
import 'package:solana_web3/solana_web3.dart' as sol3;
import 'package:web3dart/web3dart.dart';

import '../../../enum/gas_priority.dart';
import '../../../enum/network_type.dart';
import '../../../model/transfer_fee.dart';
import '../../../util/app_util.dart';
import '../../../util/wallet_config.dart';

part 'bitcoin.dart';
part 'ethurium.dart';
part 'solana.dart';

class WalletTransferService {
  final Map<NetworkType, _BlockchainTransferService> _services = {};

  WalletTransferService() {
    _services[NetworkType.ethereum] = _EthereumTransferService();
    _services[NetworkType.bitcoin] = _BitcoinTransferService();
    _services[NetworkType.solana] = _SolanaTransferService();
  }

  // 가스비 또는 수수료 예상
  Future<Map<GasPriority, TransferFee>> estimateTransferFees({
    required NetworkType networkType,
    String? fromAddress,
    String? toAddress,
    BigInt? amount,
  }) {
    return _services[networkType]!.estimateTransferFees(
      fromAddress: fromAddress,
      toAddress: toAddress,
      amount: amount,
    );
  }

  // 트랜잭션 전송만 하고 끝냄
  Future<String> sendTransaction({
    required TokenInfo tokenInfo,
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required BigInt fee,
    required NetworkType networkType,
  }) {
    return _services[networkType]!.sendTransaction(
      tokenInfo: tokenInfo,
      fromAddress: fromAddress,
      toAddress: toAddress,
      amount: amount,
      privateKey: privateKey,
      fee: fee,
    );
  }

  // 트랜잭션 상태 확인
  Future<TransactionConfirmationStatus> checkTransactionStatus({
    required String txHash,
    required NetworkType networkType,
  }) {
    return _services[networkType]!.checkTransactionStatus(txHash);
  }

  // 트랜잭션을 전송하고 결과까지 기다림
  Future<TransactionConfirmationStatus> sendAndWaitForTransaction({
    required TokenInfo tokenInfo,
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required BigInt fee,
    required NetworkType networkType,
  }) {
    return _services[networkType]!.sendAndWaitForTransaction(
      tokenInfo: tokenInfo,
      fromAddress: fromAddress,
      toAddress: toAddress,
      amount: amount,
      privateKey: privateKey,
      fee: fee,
    );
  }

  void dispose() {
    for (var service in _services.values) {
      service.dispose();
    }
  }
}

/// 블록체인별 전송 서비스 인터페이스
abstract class _BlockchainTransferService {
  Future<Map<GasPriority, TransferFee>> estimateTransferFees({
    String? fromAddress,
    String? toAddress,
    BigInt? amount,
  });

  Future<String> sendTransaction({
    required TokenInfo tokenInfo,
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required BigInt fee,
  });

  Future<TransactionConfirmationStatus> checkTransactionStatus(String txHash);

  Future<TransactionConfirmationStatus> sendAndWaitForTransaction({
    required TokenInfo tokenInfo,
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required BigInt fee,
  });

  void dispose();
}

enum TransactionConfirmationStatus {
  confirmed, // 트랜잭션 확인됨
  unconfirmed, // 트랜잭션 미확인
  attemptsExceeded, // 최대 시도 횟수 초과
}
