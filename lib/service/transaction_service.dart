// 사용자 입력 (받는사람 주소, 보낼금액, 가스비 우선순위) → 가스비 계산 → 트랜잭션 생성 → 서명 → 전송 → 결과 확인

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

class TransactionInput {
  final String toAddress; // 받는 사람 주소
  final double amount; // 보낼 금액
  final GasPriority gasPriority; // 가스비 우선순위 선택
  TransactionInput(
    this.toAddress,
    this.amount,
    this.gasPriority,
  );
}

class TransactionFee {
  final BigInt gasPrice; // 가스 단위 가격
  final BigInt gasLimit; // 최대 사용 가능한 가스량
  final BigInt estimatedFee; // 예상 총 수수료 (gasPrice * gasLimit)

  TransactionFee({
    required this.gasPrice,
    required this.gasLimit,
    required this.estimatedFee,
  });

  // Wei 단위의 수수료를 ETH 단위로 변환
  double get feeInEth => estimatedFee / BigInt.from(pow(10, 18));

  // 사용자 표시용 포맷팅
  String get formatted => '${feeInEth.toStringAsFixed(8)} ETH';
}

enum GasPriority { slow, medium, fast }

class TransactionService {
  final Web3Client web3client;

  TransactionService({
    required String rpcUrl, // 이더리움 노드 RPC URL
  }) : web3client = Web3Client(rpcUrl, http.Client());

  Future<Map<GasPriority, TransactionFee>> estimateGasFeesByPriority() async {
    // 기본 가스 가격 조회 및 BigInt로 변환
    final baseGasPrice =
        (await web3client.getGasPrice()).getInWei; // getInWei로 BigInt 얻기
    final gasLimit = BigInt.from(21000);

    // 각 우선순위별 가스 가격 계산
    final gasPrices = {
      GasPriority.slow: baseGasPrice * BigInt.from(8) ~/ BigInt.from(10),
      // 80%
      GasPriority.medium: baseGasPrice,
      // 100%
      GasPriority.fast: baseGasPrice * BigInt.from(12) ~/ BigInt.from(10),
      // 120%
    };

    // 각 우선순위별 TransactionFee 생성
    return {
      for (var priority in GasPriority.values)
        priority: TransactionFee(
          gasPrice: gasPrices[priority]!,
          gasLimit: gasLimit,
          estimatedFee: gasPrices[priority]! * gasLimit,
        )
    };
  }

  Future<String> sendTransaction({
    required String toAddress,
    required BigInt amount,
    required Credentials credentials,
    required GasPriority gasPriority, // 가스비 우선순위 추가
  }) async {
    try {
      // 1. 현재 가스 가격 가져오기
      final baseGasPrice = (await web3client.getGasPrice()).getInWei;

      // 2. 선택된 우선순위에 따른 가스 가격 계산
      final gasPrice = switch (gasPriority) {
        GasPriority.slow => baseGasPrice * BigInt.from(8) ~/ BigInt.from(10),
        GasPriority.medium => baseGasPrice,
        GasPriority.fast => baseGasPrice * BigInt.from(12) ~/ BigInt.from(10),
      };

      // 3. 트랜잭션 생성
      final transaction = Transaction(
        to: EthereumAddress.fromHex(toAddress),
        value: EtherAmount.fromBigInt(EtherUnit.wei, amount),
        maxGas: 21000,
        gasPrice:
            EtherAmount.fromBigInt(EtherUnit.wei, gasPrice), // 계산된 가스 가격 사용
      );

      // 4. 트랜잭션 전송
      final txHash = await web3client.sendTransaction(
        credentials,
        transaction,
        chainId: 1,
      );

      return txHash;
    } catch (e) {
      throw Exception('Transaction failed: $e');
    }
  }

  //
  Future<bool> sendAndWaitForTransaction({
    required String toAddress,
    required BigInt amount,
    required Credentials credentials,
    required GasPriority gasPriority,
  }) async {
    try {
      // 1. 트랜잭션 전송
      final txHash = await sendTransaction(
        toAddress: toAddress,
        amount: amount,
        credentials: credentials,
        gasPriority: gasPriority,
      );

      // 2. 트랜잭션 처리 완료 대기
      bool isConfirmed = false;
      int attempts = 0;
      while (!isConfirmed && attempts < 30) {
        // 최대 1분 대기 (2초 * 30)
        isConfirmed = await checkTransactionStatus(txHash);
        if (!isConfirmed) {
          await Future.delayed(const Duration(seconds: 2)); // 2초마다 확인
          attempts++;
        }
      }

      return isConfirmed;
    } catch (e) {
      debugPrint('Transaction failed: $e');
      return false;
    }
  }

  Future<bool> checkTransactionStatus(String txHash) async {
    try {
      // 트랜잭션 영수증 조회
      final receipt = await web3client.getTransactionReceipt(txHash);

      // null이면 아직 처리 중
      if (receipt == null) return false;

      // status가 1이면 성공
      return receipt.status!;
    } catch (e) {
      throw Exception('Failed to check transaction status: $e');
    }
  }
}
