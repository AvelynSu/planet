part of 'walltet_transfer_service.dart';

/// 솔라나 전송 서비스
class _SolanaTransferService implements _BlockchainTransferService {
  final sol.RpcClient _rpcClient;
  final WalletConfig config;

  _SolanaTransferService()
      : _rpcClient = sol.RpcClient(WalletConfig().solanaRpcUrl),
        config = WalletConfig();

  @override
  Future<String> sendTransaction({
    required TokenInfo tokenInfo,
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required BigInt fee, // fee는 솔라나에서 무시됨
  }) async {
    try {
      // 프라이빗키 받아서 fromAddress와 일치하는지 확인
      final keyPair = await WalletService.getSolKeyPairByPrivacyKey(privateKey);

      if (keyPair.publicKey.toBase58() != fromAddress) {
        throw const CustomException(
          errMsg: 'Private key does not match the sender address',
        );
      }

      // 네이티브 SOL인지 SPL 토큰인지 확인
      final bool isNativeToken = tokenInfo.symbol == 'SOL';

      if (isNativeToken) {
        // 기존 SOL 전송 로직 (변경 없음)
        final balance = await _rpcClient.getBalance(fromAddress);
        final destinationPubkey = sol.Ed25519HDPublicKey.fromBase58(toAddress);

        final receiverAccount =
            await _rpcClient.getAccountInfo(toAddress); // 새 계정 생성시 필요한 비용
        final minimumRent =
            receiverAccount.value == null ? BigInt.from(890880) : BigInt.zero;
        final minimumFee = BigInt.from(5000); // 트렌젝션 수수료 (고정)
        final amountWithRent = amount + minimumRent; // 전송금액 + 렌트비용
        final totalRequired = amountWithRent + minimumFee; // 총 필요한 금액

        if (BigInt.from(balance.value) < totalRequired) {
          throw const CustomException(
            errMsg:
                'Insufficient balance. Please check transfer amount, fee, and account creation cost',
          );
        }

        final recentBlockhash =
            await _rpcClient.getLatestBlockhash(); // 내부에서 이 값을 사용함
        final systemProgramId =
            sol.Ed25519HDPublicKey.fromBase58(sol.SystemProgram.programId);

        final transferInstruction = sol_encoder.Instruction(
          programId: systemProgramId,
          accounts: [
            sol_encoder.AccountMeta.writeable(
                pubKey: keyPair.publicKey, isSigner: true),
            sol_encoder.AccountMeta.writeable(
                pubKey: destinationPubkey, isSigner: false), // 받는 사람 서명은 불필요
          ],
          data: _createTransferData(amountWithRent),
        );

        final message = sol.Message.only(transferInstruction);
        final signature =
            await _rpcClient.signAndSendTransaction(message, [keyPair]);

        return signature;
      } else {
        throw CustomException(errMsg: 'Coming soon...');
      }
    } catch (e) {
      if (e is CustomException) rethrow;
      if (e.toString().contains("AccountNotFound") ||
          e.toString().contains("Attempt to debit an account")) {
        throw const CustomException(
            errMsg: 'Account not found or insufficient balance');
      }
      print(e);
      throw CustomException(errMsg: 'Transaction failed: $e');
    }
  }

// 64비트 정수를 리틀 엔디안 바이트 배열로 변환
  Uint8List _uint64ToByteArray(int value) {
    final buffer = Uint8List(8);
    final byteData = ByteData.view(buffer.buffer);
    byteData.setUint64(0, value, Endian.little);
    return buffer;
  }

// SOL 전송 데이터 생성 헬퍼 메서드
  sol_encoder.ByteArray _createTransferData(BigInt amount) {
    // 1. 명령어 인덱스 (2 = transfer)
    final instructionIndex = sol_encoder.ByteArray(const [2, 0, 0, 0]);

    // 2. 금액을 바이트 배열로 변환 (리틀 엔디안)
    final amountBytes = _uint64ToByteArray(amount.toInt());

    // 3. 데이터 합치기
    return sol_encoder.ByteArray([...instructionIndex, ...amountBytes]);
  }

// SPL 토큰 전송 데이터 생성 헬퍼 메서드
  sol_encoder.ByteArray _createTokenTransferData(BigInt amount) {
    // 1. 명령어 인덱스 (3 = transfer)
    final instructionIndex = sol_encoder.ByteArray(const [3, 0, 0, 0]);

    // 2. 금액을 바이트 배열로 변환 (리틀 엔디안)
    final amountBytes = _uint64ToByteArray(amount.toInt());

    // 3. 데이터 합치기
    return sol_encoder.ByteArray([...instructionIndex, ...amountBytes]);
  }

  @override
  Future<TransactionConfirmationStatus> checkTransactionStatus(
      String txHash) async {
    try {
      final status = await _rpcClient.getSignatureStatuses(
        [txHash],
        searchTransactionHistory: true,
      );

      if (status.value.isEmpty || status.value[0] == null) {
        return TransactionConfirmationStatus.unconfirmed;
      }

      final confirmStatus = status.value[0]!.confirmationStatus;
      return (confirmStatus == sol_dto.Commitment.finalized ||
              confirmStatus == sol_dto.Commitment.confirmed)
          ? TransactionConfirmationStatus.confirmed
          : TransactionConfirmationStatus.unconfirmed;
    } catch (e) {
      throw CustomException(errMsg: 'Failed to check transaction status: $e');
    }
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
  Future<Map<GasPriority, TransferFee>> estimateTransferFees({
    String? fromAddress,
    String? toAddress,
    BigInt? amount,
  }) async {
    try {
      final Map<GasPriority, TransferFee> result = {};

      for (final priority in AppUtil.feePriority(NetworkType.solana).entries) {
        result[priority.key] = TransferFee(
          gasPrice: BigInt.from(5000), // 솔라나는 값이 고정 됨
          gasLimit: BigInt.from(1),
          estimatedFee: BigInt.from(5000),
        );
      }

      return result;
    } catch (e) {
      throw CustomException(
          errMsg: 'Failed to estimate Solana transfer fees: $e');
    }
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
  void dispose() {}
}
