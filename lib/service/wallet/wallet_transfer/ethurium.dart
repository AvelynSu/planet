part of 'walltet_transfer_service.dart';

/// 이더리움 전송 서비스
class _EthereumTransferService implements _BlockchainTransferService {
  final Web3Client web3client;
  final WalletConfig config;

  _EthereumTransferService()
      : web3client = Web3Client(WalletConfig().ethRpcUrl, http.Client()),
        config = WalletConfig();

  @override
  Future<String> sendTransaction({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required BigInt fee,
  }) async {
    try {
      final credentials = AppUtil.getEthCredentials(privateKey);
      final senderAddress = AppUtil.hexToEthereumAddress(fromAddress);

      final Future<int> nonceFuture =
          web3client.getTransactionCount(senderAddress);
      final Future<EtherAmount> gasPriceFuture = web3client.getGasPrice();

      final currentNonce = await nonceFuture;
      final currentGasPrice = (await gasPriceFuture).getInWei;

      final gasPrice = _calculateGasPrice(fee, currentGasPrice);

      final transaction = Transaction(
        to: AppUtil.hexToEthereumAddress(toAddress),
        value: EtherAmount.fromBigInt(EtherUnit.wei, amount),
        gasPrice: EtherAmount.fromBigInt(EtherUnit.wei, gasPrice),
        nonce: currentNonce,
        maxGas: 21000,
      );

      return await web3client.sendTransaction(
        credentials,
        transaction,
        chainId: config.chainId,
      );
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains("insufficient funds for")) {
        throw const CustomException(
            errMsg: 'Not enough ETH to cover transaction costs.');
      } else if (errorMessage.contains("nonce too low")) {
        throw const CustomException(
            errMsg: 'Transaction nonce is too low. Please try again.');
      } else if (errorMessage.contains("gas price too low") ||
          errorMessage.contains("replacement transaction underpriced")) {
        throw const CustomException(errMsg: 'Gas price is too low.');
      }
      throw CustomException(errMsg: 'Transaction failed: $e');
    }
  }

  BigInt _calculateGasPrice(BigInt fee, BigInt currentGasPrice) {
    final calculatedGasPrice = fee ~/ BigInt.from(21000);
    final minGasPrice =
        (currentGasPrice * BigInt.from(110)) ~/ BigInt.from(100);
    return calculatedGasPrice > minGasPrice ? calculatedGasPrice : minGasPrice;
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
      final txHash = await sendTransaction(
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
  Future<bool> checkTransactionStatus(String txHash) async {
    try {
      // 트랜잭션 영수증 조회
      final receipt = await web3client.getTransactionReceipt(txHash);

      // null이면 아직 처리 중
      if (receipt == null) return false;

      // status가 1이면 성공
      return receipt.status!;
    } catch (e) {
      throw CustomException(errMsg: 'Failed to check transaction status: $e');
    }
  }

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
      for (var entry in AppUtil.feePriority(NetworkType.ethereum).entries)
        entry.key: AppUtil.adjustFeeByPercentage(baseGasPrice, entry.value)
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

  // 트랜잭션 상태를 기다리는 공통 메서드
  Future<bool> _waitForTransactionConfirmation(
    String txHash, {
    int maxAttempts = 30,
  }) async {
    bool isConfirmed = false;
    int attempts = 0;

    while (!isConfirmed && attempts < maxAttempts) {
      isConfirmed = await checkTransactionStatus(txHash);
      if (!isConfirmed) {
        await Future.delayed(const Duration(seconds: 3)); // 3초마다 확인
        attempts++;
      }
    }

    return isConfirmed;
  }

  @override
  void dispose() {
    web3client.dispose();
  }
}
