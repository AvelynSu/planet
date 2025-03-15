import 'dart:convert';
import 'dart:typed_data' show ByteData, Endian, Uint8List;

import 'package:bs58/bs58.dart';
import 'package:convert/convert.dart' show hex;
import 'package:flutter/cupertino.dart';
import 'package:flutter_bitcoin/flutter_bitcoin.dart' as btc;
import 'package:http/http.dart' as http;
import 'package:planet/model/custom_exception.dart';
import 'package:solana/dto.dart' as sol_dto;
import 'package:solana/encoder.dart' as sol_encoder;
import 'package:solana/solana.dart' as sol;
import 'package:web3dart/web3dart.dart';

import '../../../enum/gas_priority.dart';
import '../../../enum/network_type.dart';
import '../../../model/transfer_fee.dart';
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
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required GasPriority gasPriority,
    required NetworkType networkType,
  }) {
    return _services[networkType]!.sendTransaction(
      fromAddress: fromAddress,
      toAddress: toAddress,
      amount: amount,
      privateKey: privateKey,
      gasPriority: gasPriority,
    );
  }

  // 트랜잭션 상태 확인
  Future<bool> checkTransactionStatus({
    required String txHash,
    required NetworkType networkType,
  }) {
    return _services[networkType]!.checkTransactionStatus(txHash);
  }

  // 트랜잭션을 전송하고 결과까지 기다림
  Future<bool> sendAndWaitForTransaction({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required BigInt fee,
    required NetworkType networkType,
  }) {
    return _services[networkType]!.sendAndWaitForTransaction(
      fromAddress: fromAddress,
      toAddress: toAddress,
      amount: amount,
      privateKey: privateKey,
      fee: fee,
    );
  }

  // 커스텀 수수료로 트랜잭션 전송
  Future<String> sendTransactionWithCustomFee({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required BigInt fee,
    required NetworkType networkType,
  }) {
    return _services[networkType]!.sendTransactionWithCustomFee(
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
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required GasPriority gasPriority,
  });

  Future<bool> checkTransactionStatus(String txHash);

  Future<bool> sendAndWaitForTransaction({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required BigInt fee,
  });

  Future<String> sendTransactionWithCustomFee({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required BigInt fee,
  });

  void dispose();
}
