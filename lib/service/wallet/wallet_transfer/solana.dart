part of 'walltet_transfer_service.dart';

/// 솔라나 전송 서비스
class _SolanaTransferService implements _BlockchainTransferService {
  final sol3.Connection _rpcClient;
  final WalletConfig config;

  _SolanaTransferService()
      : _rpcClient = sol3.Connection(sol3.Cluster(Uri.parse(WalletConfig().solanaRpcUrl))),
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
    // try {
    // 프라이빗키 받아서 fromAddress와 일치하는지 확인
    final keyPair = await WalletService.getSolKeyPairByPrivacyKey(privateKey);

    if (keyPair.pubkey.toBase58() != fromAddress) {
      throw const CustomException(
        errMsg: 'Private key does not match the sender address',
      );
    }

    final sourceOwner = sol3.Pubkey.fromBase58(fromAddress);
    final destinationOwner = sol3.Pubkey.fromBase58(toAddress);

    // 네이티브 SOL인지 SPL 토큰인지 확인
    final bool isNativeToken = tokenInfo.symbol == 'SOL';

    if (isNativeToken) {
      // 기존 SOL 전송 로직 (solana_web3 패키지 사용)
      final balance = await _rpcClient.getBalance(sourceOwner);

      final receiverAccount = await _rpcClient.getAccountInfo(destinationOwner);
      final minimumRent =
          receiverAccount == null ? BigInt.from(890880.round()) : BigInt.zero;
      final minimumFee = BigInt.from(5000.round()); // 트랜잭션 수수료 (고정)
      final amountWithRent = amount + minimumRent; // 전송금액 + 렌트비용
      final totalRequired = amountWithRent + minimumFee; // 총 필요한 금액

      if (BigInt.from(balance) < totalRequired) {
        throw const CustomException(
          errMsg:
              'Insufficient balance. Please check transfer amount, fee, and account creation cost',
        );
      }

      // 최근 블록해시 가져오기
      final recentBlockhash = await _rpcClient.getLatestBlockhash();

      // 트랜잭션 생성
      final transaction = sol3.Transaction.v0(
        payer: keyPair.pubkey,
        recentBlockhash: recentBlockhash.blockhash,
        instructions: [
          SystemProgram.transfer(
            fromPubkey: keyPair.pubkey,
            toPubkey: destinationOwner,
            lamports: amountWithRent,
          ),
        ],
      );

      // 트랜잭션 서명
      transaction.sign([keyPair]);

      // 트랜잭션 전송
      final signature = await _rpcClient.sendTransaction(
        transaction,
        config: const sol3.SendTransactionConfig(
          skipPreflight: false,
          preflightCommitment: sol3.Commitment.confirmed,
          encoding: sol3.TransactionEncoding.base64,
        ),
      );

      return signature;
    } else {
      // throw CustomException(errMsg: 'Coming soon...');
      final mintPubkey = sol3.Pubkey.fromBase58(tokenInfo.address);

      // 보내는 사람의 토큰 계정 주소 가져오기
      final sourceATA =
          sol3.Pubkey.findAssociatedTokenAddress(sourceOwner, mintPubkey);

      // 받는 사람의 토큰 계정 주소 가져오기
      final destinationATA =
          sol3.Pubkey.findAssociatedTokenAddress(destinationOwner, mintPubkey);
// 받는 사람의 토큰 계정이 없다면 생성
      final receiverTokenAccount =
          await _rpcClient.getAccountInfo(destinationATA.pubkey);
      List<sol3.TransactionInstruction> instructions = [];

      if (receiverTokenAccount == null) {
        instructions.add(
          AssociatedTokenProgram.create(
            fundingAccount: keyPair.pubkey,
            associatedTokenAccount: destinationATA.pubkey, // .pubkey 추가
            associatedTokenAccountOwner: destinationOwner,
            tokenMint: mintPubkey,
          ),
        );
      }

// 토큰 전송 instruction 추가
      instructions.add(
        TokenProgram.transfer(
          source: sourceATA.pubkey, // .pubkey 추가
          destination: destinationATA.pubkey, // .pubkey 추가
          owner: keyPair.pubkey,
          amount: amount,
        ),
      );

// 토큰 전송 instruction 추가
      instructions.add(
        TokenProgram.transfer(
          source: sourceATA.pubkey, // 보내는 토큰 계정
          destination: destinationATA.pubkey, // 받는 토큰 계정
          owner: keyPair.pubkey, // 보내는 사람의 지갑 주소
          amount: amount, // 전송할 양
        ),
      );

// 최근 블록해시 가져오기
      final recentBlockhash = await _rpcClient.getLatestBlockhash();

// 트랜잭션 생성
      final transaction = sol3.Transaction.v0(
        payer: keyPair.pubkey,
        recentBlockhash: recentBlockhash.blockhash,
        instructions: instructions,
      );

// 트랜잭션 서명
      transaction.sign([keyPair]);

// 트랜잭션 전송 및 서명값 반환
      final signature = await _rpcClient.sendTransaction(
        transaction,
        config: const sol3.SendTransactionConfig(
          skipPreflight: false,
          preflightCommitment: sol3.Commitment.confirmed,
          encoding: sol3.TransactionEncoding.base64,
        ),
      );

      return signature;
    }
    // } catch (e) {
    //   if (e is CustomException) rethrow;
    //   if (e.toString().contains("AccountNotFound") ||
    //       e.toString().contains("Attempt to debit an account")) {
    //     throw const CustomException(
    //         errMsg: 'Account not found or insufficient balance');
    //   }
    //   print(e);
    //   throw CustomException(errMsg: 'Transaction failed: $e');
    // }
  }

  @override
  Future<TransactionConfirmationStatus> checkTransactionStatus(
      String txHash) async {
    try {
      final status = await _rpcClient.getSignatureStatus(
        txHash,
        config: const sol3.GetSignatureStatusesConfig(
            searchTransactionHistory: true),
      );

      if (status == null) {
        return TransactionConfirmationStatus.unconfirmed;
      }

      final confirmStatus = status.confirmationStatus;
      return (confirmStatus == sol3.Commitment.finalized ||
              confirmStatus == sol3.Commitment.confirmed)
          ? TransactionConfirmationStatus.confirmed
          : TransactionConfirmationStatus.unconfirmed;
    } catch (e) {
      throw CustomException(errMsg: '트랜잭션 상태 확인 실패: $e');
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
    // try {
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
    // } catch (e) {
    //   rethrow;
    // }
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
