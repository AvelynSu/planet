part of 'walltet_transfer_service.dart';

/// 솔라나 전송 서비스
class _SolanaTransferService implements _BlockchainTransferService {
  final sol.RpcClient _rpcClient;
  final WalletConfig config;

  _SolanaTransferService()
      : _rpcClient = sol.RpcClient(WalletConfig().solanaRpcUrl),
        config = WalletConfig();
  @override
  Future<Map<GasPriority, TransferFee>> estimateTransferFees({
    String? fromAddress,
    String? toAddress,
    BigInt? amount,
  }) async {
    try {
      // 솔라나 기본 전송 수수료 (lamports)
      final baseFee = BigInt.from(5000);

      // 각 우선순위별 수수료 계산
      final Map<GasPriority, TransferFee> result = {};
      for (final priority in AppUtil.feePriority(NetworkType.solana).entries) {
        final feeMultiplier = priority.value;
        final priorityFee =
            BigInt.from((baseFee.toDouble() * feeMultiplier).toInt());

        // 솔라나의 고정 수수료 구조에 맞게 설정
        result[priority.key] = TransferFee(
          gasPrice: BigInt.from(5000), // 솔라나의 기본 수수료
          gasLimit: BigInt.from(1), // 솔라나는 가스 한도 개념이 없음
          estimatedFee: priorityFee,
        );
      }

      return result;
    } catch (e) {
      throw Exception('Failed to estimate Solana transfer fees: $e');
    }
  }

  /// 개인키로부터 키페어 생성
  Future<sol.Ed25519HDKeyPair> _getKeyPair(String privateKey) async {
    try {
      // Hex 형식이면 Hex 디코딩
      if (RegExp(r'^[0-9a-fA-F]+$').hasMatch(privateKey)) {
        final privateKeyBytes = Uint8List.fromList(hex.decode(privateKey));

        // 32바이트 체크
        if (privateKeyBytes.length != 32) {
          throw CustomException(
            errMsg: '개인키는 반드시 32바이트여야 합니다. (현재: ${privateKeyBytes.length}바이트)',
          );
        }

        return await sol.Ed25519HDKeyPair.fromPrivateKeyBytes(
          privateKey: privateKeyBytes,
        );
      }

      throw CustomException(errMsg: "개인키는 16진수 형식이어야 합니다.");
    } catch (e) {
      throw CustomException(errMsg: '개인키 형식이 잘못되었습니다: $e');
    }
  }

  Future<String> sendTransaction({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required BigInt fee, // fee는 솔라나에서 무시됨
  }) async {
    try {
      final keyPair = await _getKeyPair(privateKey);

      if (keyPair.publicKey.toBase58() != fromAddress) {
        throw const CustomException(
          errMsg: '개인키가 송금 주소와 일치하지 않습니다.',
        );
      }

      final balance = await _rpcClient.getBalance(fromAddress);
      final destinationPubkey = sol.Ed25519HDPublicKey.fromBase58(toAddress);

      final minimumRent = BigInt.from(890880);
      final minimumFee = BigInt.from(5000);
      final amountWithRent = amount + minimumRent;
      final totalRequired = amountWithRent + minimumFee;

      if (BigInt.from(balance.value) < totalRequired) {
        throw const CustomException(
          errMsg: '잔액이 부족합니다. 전송 금액, 수수료, 그리고 계정 생성 비용을 확인해주세요.',
        );
      }

      final recentBlockhash = await _rpcClient.getLatestBlockhash();
      final systemProgramId =
          sol.Ed25519HDPublicKey.fromBase58(sol.SystemProgram.programId);

      final transferInstruction = sol_encoder.Instruction(
        programId: systemProgramId,
        accounts: [
          sol_encoder.AccountMeta.writeable(
              pubKey: keyPair.publicKey, isSigner: true),
          sol_encoder.AccountMeta.writeable(
              pubKey: destinationPubkey, isSigner: false),
        ],
        data: _createTransferData(amountWithRent),
      );

      final message = sol.Message.only(transferInstruction);
      final signature =
          await _rpcClient.signAndSendTransaction(message, [keyPair]);

      return signature;
    } catch (e) {
      if (e is CustomException) rethrow;
      if (e.toString().contains("AccountNotFound") ||
          e.toString().contains("Attempt to debit an account")) {
        throw const CustomException(errMsg: '계정을 찾을 수 없거나 잔액이 부족합니다.');
      }
      throw CustomException(errMsg: '트랜잭션 실패: $e');
    }
  }

  // SOL 전송 데이터 생성 헬퍼 메서드
  sol_encoder.ByteArray _createTransferData(BigInt amount) {
    // 1. 명령어 인덱스 (2 = transfer)
    final instructionIndex = sol_encoder.ByteArray([2, 0, 0, 0]);

    // 2. 금액을 바이트 배열로 변환 (리틀 엔디안)
    final amountBytes = _uint64ToByteArray(amount.toInt());

    // 3. 데이터 합치기
    return sol_encoder.ByteArray([
      ...instructionIndex.toList(),
      ...amountBytes.toList(),
    ]);
  }

  // 64비트 정수를 리틀 엔디안 바이트 배열로 변환
  Uint8List _uint64ToByteArray(int value) {
    final buffer = Uint8List(8);
    final byteData = ByteData.view(buffer.buffer);
    byteData.setUint64(0, value, Endian.little);
    return buffer;
  }

  Future<String> sendTransactionWithCustomFee({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required BigInt fee,
  }) async {
    // 솔라나는 가스 가격을 직접 설정할 수 없으므로
    // 일반 전송과 동일하게 처리
    return sendTransaction(
      fromAddress: fromAddress,
      toAddress: toAddress,
      amount: amount,
      privateKey: privateKey,
      fee: fee,
    );
  }

  @override
  Future<bool> checkTransactionStatus(String txHash) async {
    try {
      final status = await _rpcClient.getSignatureStatuses(
        [txHash],
        searchTransactionHistory: true,
      );

      if (status.value.isEmpty || status.value[0] == null) {
        return false;
      }

      return status.value[0]!.confirmationStatus ==
              sol_dto.Commitment.finalized.name ||
          status.value[0]!.confirmationStatus ==
              sol_dto.Commitment.confirmed.name;
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
        await Future.delayed(const Duration(seconds: 4)); // 2초마다 확인
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
    // 솔라나 클라이언트는 dispose 메서드가 없음
    // 필요한 리소스 정리 코드 추가 가능
  }
}
