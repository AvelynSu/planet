part of 'walltet_transfer_service.dart';

/// 이더리움 전송 서비스
class _EthereumTransferService implements _BlockchainTransferService {
  final Web3Client web3client;
  final WalletConfig config;

  _EthereumTransferService()
      : web3client = Web3Client(WalletConfig.config.ethRpcUrl, http.Client()),
        config = WalletConfig.config;

  @override
  Future<String> sendTransaction({
    required TokenInfo tokenInfo,
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

      // 네이티브 토큰(ETH)인지 아닌지 확인
      final bool isNativeToken = tokenInfo.symbol == 'ETH';

      String txHash;

      if (isNativeToken) {
        // ETH 전송 처리
        final transaction = Transaction(
          to: AppUtil.hexToEthereumAddress(toAddress),
          value: EtherAmount.fromBigInt(EtherUnit.wei, amount),
          gasPrice: EtherAmount.fromBigInt(EtherUnit.wei, gasPrice),
          nonce: currentNonce,
          maxGas: 21000,
        );

        txHash = await web3client.sendTransaction(
          credentials,
          transaction,
          chainId: config.chainId(NetworkType.ethereum),
        );
      } else {
        // ERC-20 토큰 전송 처리
        // 토큰 컨트랙트 ABI 정의 (간소화된 버전)
        final String tokenAbi = '''
[{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"type":"function"}]
''';
        final contract = DeployedContract(
          ContractAbi.fromJson(tokenAbi, tokenInfo.symbol),
          AppUtil.hexToEthereumAddress(tokenInfo.address),
        );

        final transferFunction = contract.function('transfer');

        final transaction = Transaction.callContract(
          contract: contract,
          function: transferFunction,
          parameters: [AppUtil.hexToEthereumAddress(toAddress), amount],
          gasPrice: EtherAmount.fromBigInt(EtherUnit.wei, gasPrice),
          maxGas: 100000,
          // 토큰 전송은 일반적으로 더 많은 가스가 필요
          nonce: currentNonce,
        );

        txHash = await web3client.sendTransaction(
          credentials,
          transaction,
          chainId: config.chainId(NetworkType.ethereum),
        );
      }

      return txHash;
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
  Future<TransactionConfirmationStatus> sendAndWaitForTransaction({
    required TokenInfo tokenInfo,
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required BigInt fee,
  }) async {
    try {
      // 1. 트랜잭션 전송
      final txHash = await sendTransaction(
        tokenInfo: tokenInfo,
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
  Future<TransactionConfirmationStatus> checkTransactionStatus(
      String txHash) async {
    try {
      // 트랜잭션 영수증 조회
      final receipt = await web3client.getTransactionReceipt(txHash);

      // null이면 아직 처리 중
      if (receipt == null) return TransactionConfirmationStatus.unconfirmed;

      // receipt.status가 1이면 성공
      return TransactionConfirmationStatus.confirmed;
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
  Future<TransactionConfirmationStatus> _waitForTransactionConfirmation(
      String txHash,
      {int maxAttempts = 15}) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      if (await checkTransactionStatus(txHash) ==
          TransactionConfirmationStatus.confirmed) {
        return TransactionConfirmationStatus.confirmed;
      }
      await Future.delayed(const Duration(seconds: 3));
      attempts++;
    }

    return TransactionConfirmationStatus.attemptsExceeded;
  }

  @override
  void dispose() {
    web3client.dispose();
  }
}
