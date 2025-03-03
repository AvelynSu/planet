part of 'walltet_transfer_service.dart';

/// 이더리움 전송 서비스
class _EthereumTransferService implements _BlockchainTransferService {
  final Web3Client web3client;
  final WalletConfig config;

  _EthereumTransferService()
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

      // 1. 현재 가스 기본 수수료 가져오기
      final baseGasPrice = (await web3client.getGasPrice()).getInWei;

// 2. 선택된 우선순위에 따른 가스 가격 계산
      final multiplier = _gasPriorityMultipliers[gasPriority] ?? 1.0;
      final gasPrice = _applyMultiplier(baseGasPrice, multiplier);

// 3. EIP-1559 트랜잭션 생성
      final transaction = Transaction(
        to: EthereumAddress.fromHex(toAddress),
        value: EtherAmount.fromBigInt(EtherUnit.wei, amount),
        maxGas: 21000,
        maxPriorityFeePerGas:
            EtherAmount.fromBigInt(EtherUnit.wei, gasPrice ~/ BigInt.from(2)),
        maxFeePerGas: EtherAmount.fromBigInt(EtherUnit.wei, gasPrice),
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
    required BigInt fee,
  }) async {
    try {
      // 1. 트랜잭션 전송
      final txHash = await sendTransactionWithCustomFee(
        fromAddress: fromAddress,
        toAddress: toAddress,
        amount: amount,
        privateKey: privateKey,
        fee: fee,
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
