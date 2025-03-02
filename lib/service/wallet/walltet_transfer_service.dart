import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:planet/model/custom_exception.dart';
import 'package:web3dart/web3dart.dart';

import '../../enum/gas_priority.dart';
import '../../enum/network_type.dart';
import '../../model/transfer_fee.dart';
import '../../util/wallet_config.dart';

class WalletTransferService {
  final Map<NetworkType, BlockchainTransferService> _services = {};

  WalletTransferService() {
    _services[NetworkType.ethereum] = EthereumTransferService();
    _services[NetworkType.bitcoin] = BitcoinTransferService();
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
    required GasPriority gasPriority,
    required NetworkType networkType,
  }) {
    return _services[networkType]!.sendAndWaitForTransaction(
      fromAddress: fromAddress,
      toAddress: toAddress,
      amount: amount,
      privateKey: privateKey,
      gasPriority: gasPriority,
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
abstract class BlockchainTransferService {
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
    required GasPriority gasPriority,
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

/// 이더리움 전송 서비스
class EthereumTransferService implements BlockchainTransferService {
  final Web3Client web3client;
  final WalletConfig config;

  EthereumTransferService()
      : web3client = Web3Client(WalletConfig().rpcUrl, http.Client()),
        config = WalletConfig();

  // 가스 우선순위별 비율 상수 정의
  static const Map<GasPriority, double> _gasPriorityMultipliers = {
    GasPriority.slow: 0.8, // 80%
    GasPriority.medium: 1.0, // 100%
    GasPriority.fast: 1.2, // 120%
  };

  @override
  Future<Map<GasPriority, TransferFee>> estimateTransferFees({
    String? fromAddress,
    String? toAddress,
    BigInt? amount,
  }) async {
    // 기본 가스 가격 조회 및 BigInt로 변환
    final baseGasPrice = (await web3client.getGasPrice()).getInWei;
    final gasLimit = BigInt.from(21000);

    // 각 우선순위별 가스 가격 계산
    final gasPrices = {
      for (var entry in _gasPriorityMultipliers.entries)
        entry.key: _applyMultiplier(baseGasPrice, entry.value)
    };

    // 각 우선순위별 TransactionFee 생성
    return {
      for (var priority in GasPriority.values)
        priority: TransferFee(
          gasPrice: gasPrices[priority]!,
          gasLimit: gasLimit,
          estimatedFee: gasPrices[priority]! * gasLimit,
        )
    };
  }

  // double 배율을 BigInt에 안전하게 적용하는 헬퍼 메서드
  BigInt _applyMultiplier(BigInt value, double multiplier) {
    // 소수점 연산을 위해 정수로 변환 (100을 곱하여 백분율로 계산)
    final scaledMultiplier = (multiplier * 100).round();
    return value * BigInt.from(scaledMultiplier) ~/ BigInt.from(100);
  }

  /// 개인키로부터 Credentials 생성
  Credentials _getCredentials(String privateKey) {
    return EthPrivateKey.fromHex(privateKey);
  }

  @override
  Future<String> sendTransaction({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required GasPriority gasPriority,
  }) async {
    try {
      final credentials = _getCredentials(privateKey);

      // 1. 현재 가스 가격 가져오기
      final baseGasPrice = (await web3client.getGasPrice()).getInWei;

      // 2. 선택된 우선순위에 따른 가스 가격 계산
      final multiplier = _gasPriorityMultipliers[gasPriority] ?? 1.0;
      final gasPrice = _applyMultiplier(baseGasPrice, multiplier);

      // 3. 트랜잭션 생성
      final transaction = Transaction(
        to: EthereumAddress.fromHex(toAddress),
        value: EtherAmount.fromBigInt(EtherUnit.wei, amount),
        maxGas: 21000,
        gasPrice: EtherAmount.fromBigInt(EtherUnit.wei, gasPrice),
      );

      // 4. 트랜잭션 전송
      final txHash = await web3client.sendTransaction(
        credentials,
        transaction,
        chainId: config.chainId,
      );

      return txHash;
    } catch (e) {
      var errorMessage = e.toString();
      if (errorMessage.contains("insufficient funds for")) {
        throw const CustomException(
            errMsg: 'Not enough ETH to cover transaction costs.');
      } else if (errorMessage.contains("nonce too low")) {
        throw const CustomException(
            errMsg: 'Transaction nonce is too low. Please try again.');
      } else if (errorMessage.contains("gas price too low")) {
        throw const CustomException(errMsg: 'Gas price is too low.');
      }

      throw CustomException(errMsg: 'Transaction failed: $e');
    }
  }

  @override
  Future<String> sendTransactionWithCustomFee({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required BigInt fee,
  }) async {
    try {
      final credentials = _getCredentials(privateKey);

      // fee를 이더리움에서는 gasPrice로 사용
      final gasPrice = fee ~/ BigInt.from(21000); // 기본 가스 한도로 나눔

      // 트랜잭션 생성
      final transaction = Transaction(
        to: EthereumAddress.fromHex(toAddress),
        value: EtherAmount.fromBigInt(EtherUnit.wei, amount),
        maxGas: 21000,
        gasPrice: EtherAmount.fromBigInt(EtherUnit.wei, gasPrice),
      );

      // 트랜잭션 전송
      final txHash = await web3client.sendTransaction(
        credentials,
        transaction,
        chainId: config.chainId,
      );

      return txHash;
    } catch (e) {
      throw Exception('Transaction failed: $e');
    }
  }

  @override
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

  // 트랜잭션 상태를 기다리는 공통 메서드
  Future<bool> _waitForTransactionConfirmation(String txHash,
      {int maxAttempts = 30}) async {
    bool isConfirmed = false;
    int attempts = 0;

    while (!isConfirmed && attempts < maxAttempts) {
      isConfirmed = await checkTransactionStatus(txHash);
      if (!isConfirmed) {
        await Future.delayed(const Duration(seconds: 2)); // 2초마다 확인
        attempts++;
      }
    }

    return isConfirmed;
  }

  @override
  Future<bool> sendAndWaitForTransaction({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required GasPriority gasPriority,
  }) async {
    try {
      // 1. 트랜잭션 전송
      final txHash = await sendTransaction(
        fromAddress: fromAddress,
        toAddress: toAddress,
        amount: amount,
        privateKey: privateKey,
        gasPriority: gasPriority,
      );

      // 2. 트랜잭션 처리 완료 대기
      return await _waitForTransactionConfirmation(txHash);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    web3client.dispose();
  }
}

/// 비트코인 전송 서비스
class BitcoinTransferService implements BlockchainTransferService {
  final String _apiBaseUrl;
  final http.Client _httpClient;
  final WalletConfig config;

  BitcoinTransferService({String? apiBaseUrl})
      : _apiBaseUrl = apiBaseUrl ?? WalletConfig().bitcoinApiUrl,
        _httpClient = http.Client(),
        config = WalletConfig();

  // 가스 우선순위별 비율 상수 정의 (비트코인에서는 수수료 우선순위)
  static const Map<GasPriority, double> _feePriorityMultipliers = {
    GasPriority.slow: 0.5, // 50% - 경제적
    GasPriority.medium: 1.0, // 100% - 표준
    GasPriority.fast: 2.0, // 200% - 빠름
  };

  @override
  Future<Map<GasPriority, TransferFee>> estimateTransferFees({
    String? fromAddress,
    String? toAddress,
    BigInt? amount,
  }) async {
    try {
      // 1. 현재 권장 수수료율 조회 (satoshi/byte)
      final response = await _httpClient.get(
        Uri.parse('$_apiBaseUrl/fees'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Request timed out'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch Bitcoin fees: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      // 표준 수수료율 (satoshi/byte)
      final standardFeeRate = BigInt.from(data['medium'] ?? 20);

      // 표준 트랜잭션 크기 (바이트) - 일반적인 P2PKH 트랜잭션 (1 input, 2 outputs)
      final standardTxSize = BigInt.from(250);

      // 기본 수수료 (satoshi)
      final baseFee = standardFeeRate * standardTxSize;

      // 각 우선순위별 수수료 계산
      final fees = {
        for (var entry in _feePriorityMultipliers.entries)
          entry.key: _applyMultiplier(baseFee, entry.value)
      };

      // 각 우선순위별 TransferFee 생성
      return {
        for (var priority in GasPriority.values)
          priority: TransferFee(
            gasPrice: BigInt.from(0), // 비트코인은 gasPrice 개념이 없음
            gasLimit: BigInt.from(0), // 비트코인은 gasLimit 개념이 없음
            estimatedFee: fees[priority]!,
          )
      };
    } catch (e) {
      debugPrint('Error estimating Bitcoin fees: $e');

      // API 호출 실패 시 기본값 사용
      final baseFee = BigInt.from(5000); // 기본 5000 satoshi

      // 기본 수수료로 각 우선순위별 수수료 계산
      final fees = {
        for (var entry in _feePriorityMultipliers.entries)
          entry.key: _applyMultiplier(baseFee, entry.value)
      };

      return {
        for (var priority in GasPriority.values)
          priority: TransferFee(
            gasPrice: BigInt.from(0),
            gasLimit: BigInt.from(0),
            estimatedFee: fees[priority]!,
          )
      };
    }
  }

  // double 배율을 BigInt에 안전하게 적용하는 헬퍼 메서드
  BigInt _applyMultiplier(BigInt value, double multiplier) {
    final scaledMultiplier = (multiplier * 100).round();
    return value * BigInt.from(scaledMultiplier) ~/ BigInt.from(100);
  }

  @override
  Future<String> sendTransaction({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required GasPriority gasPriority,
  }) async {
    try {
      // 1. 현재 권장 수수료 예상
      final feesMap = await estimateTransferFees();
      final fee = feesMap[gasPriority]!.estimatedFee;

      // 2. UTXOs 조회
      final utxosResponse = await _httpClient.get(
        Uri.parse('$_apiBaseUrl/addrs/$fromAddress/utxo'),
        headers: {'Content-Type': 'application/json'},
      );

      if (utxosResponse.statusCode != 200) {
        throw Exception('Failed to fetch UTXOs: ${utxosResponse.statusCode}');
      }

      final utxosData = json.decode(utxosResponse.body);

      // 3. 트랜잭션 생성 및 서명을 위한 API 호출
      final txData = {
        'inputs': utxosData,
        'outputs': [
          {
            'addresses': [toAddress],
            'value': amount.toInt()
          }
        ],
        'fees': fee.toInt(),
        'includeToSignTx': true,
        'private': privateKey,
      };

      final txBuildResponse = await _httpClient.post(
        Uri.parse('$_apiBaseUrl/txs/new'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(txData),
      );

      if (txBuildResponse.statusCode != 200) {
        throw Exception(
            'Failed to build transaction: ${txBuildResponse.statusCode}');
      }

      final txBuildData = json.decode(txBuildResponse.body);

      // 4. 서명된 트랜잭션 전송
      final signedTxData = {
        'tx': txBuildData['tx'],
        'tosign': txBuildData['tosign'],
        'signatures': txBuildData['signatures'],
        'pubkeys': txBuildData['pubkeys'],
      };

      final txSendResponse = await _httpClient.post(
        Uri.parse('$_apiBaseUrl/txs/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(signedTxData),
      );

      if (txSendResponse.statusCode != 200) {
        throw Exception(
            'Failed to send transaction: ${txSendResponse.statusCode}');
      }

      final txSendData = json.decode(txSendResponse.body);
      return txSendData['tx']['hash'];
    } catch (e) {
      var errorMessage = e.toString();
      if (errorMessage.contains("insufficient funds")) {
        throw const CustomException(
            errMsg: 'Not enough BTC to cover transaction costs.');
      }

      throw CustomException(errMsg: 'Bitcoin transaction failed: $e');
    }
  }

  @override
  Future<String> sendTransactionWithCustomFee({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required BigInt fee,
  }) async {
    try {
      // UTXOs 조회
      final utxosResponse = await _httpClient.get(
        Uri.parse('$_apiBaseUrl/addrs/$fromAddress/utxo'),
        headers: {'Content-Type': 'application/json'},
      );

      if (utxosResponse.statusCode != 200) {
        throw Exception('Failed to fetch UTXOs: ${utxosResponse.statusCode}');
      }

      final utxosData = json.decode(utxosResponse.body);

      // 트랜잭션 생성 및 서명을 위한 API 호출
      final txData = {
        'inputs': utxosData,
        'outputs': [
          {
            'addresses': [toAddress],
            'value': amount.toInt()
          }
        ],
        'fees': fee.toInt(),
        'includeToSignTx': true,
        'private': privateKey,
      };

      final txBuildResponse = await _httpClient.post(
        Uri.parse('$_apiBaseUrl/txs/new'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(txData),
      );

      if (txBuildResponse.statusCode != 200) {
        throw Exception(
            'Failed to build transaction: ${txBuildResponse.statusCode}');
      }

      final txBuildData = json.decode(txBuildResponse.body);

      // 서명된 트랜잭션 전송
      final signedTxData = {
        'tx': txBuildData['tx'],
        'tosign': txBuildData['tosign'],
        'signatures': txBuildData['signatures'],
        'pubkeys': txBuildData['pubkeys'],
      };

      final txSendResponse = await _httpClient.post(
        Uri.parse('$_apiBaseUrl/txs/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(signedTxData),
      );

      if (txSendResponse.statusCode != 200) {
        throw Exception(
            'Failed to send transaction: ${txSendResponse.statusCode}');
      }

      final txSendData = json.decode(txSendResponse.body);
      return txSendData['tx']['hash'];
    } catch (e) {
      throw Exception('Bitcoin transaction failed: $e');
    }
  }

  @override
  Future<bool> checkTransactionStatus(String txHash) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_apiBaseUrl/txs/$txHash'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Request timed out'),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to check transaction status: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      // confirmations가 1 이상이면 확인됨
      final confirmations = data['confirmations'] ?? 0;
      return confirmations >= 1;
    } catch (e) {
      debugPrint('Error checking Bitcoin transaction status: $e');
      return false;
    }
  }

  // 트랜잭션 상태를 기다리는 공통 메서드
  Future<bool> _waitForTransactionConfirmation(String txHash,
      {int maxAttempts = 30}) async {
    bool isConfirmed = false;
    int attempts = 0;

    while (!isConfirmed && attempts < maxAttempts) {
      isConfirmed = await checkTransactionStatus(txHash);
      if (!isConfirmed) {
        await Future.delayed(
            const Duration(seconds: 10)); // 10초마다 확인 (비트코인은 블록 생성이 더 느림)
        attempts++;
      }
    }

    return isConfirmed;
  }

  @override
  Future<bool> sendAndWaitForTransaction({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required GasPriority gasPriority,
  }) async {
    try {
      // 1. 트랜잭션 전송
      final txHash = await sendTransaction(
        fromAddress: fromAddress,
        toAddress: toAddress,
        amount: amount,
        privateKey: privateKey,
        gasPriority: gasPriority,
      );

      // 2. 트랜잭션 처리 완료 대기
      return await _waitForTransactionConfirmation(txHash);
    } catch (e) {
      debugPrint('Bitcoin transaction failed: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _httpClient.close();
  }
}
