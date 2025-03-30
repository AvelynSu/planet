part of 'walltet_transfer_service.dart';

/// 비트코인 전송 서비스
class _BitcoinTransferService implements _BlockchainTransferService {
  final String _apiBaseUrl;
  final http.Client _httpClient;
  final WalletConfig config;

  _BitcoinTransferService({String? apiBaseUrl})
      : _apiBaseUrl = apiBaseUrl ?? WalletConfig.config.bitcoinApiUrl,
        _httpClient = http.Client(),
        config = WalletConfig.config;

  /// 트랜잭션 크기를 계산 (bytes)
  /// P2PKH 트랜잭션 기준으로 계산됨
  int _calculateTxSize(int inputCount, int outputCount) {
    const int baseSize = 10; // 트랜잭션 헤더 크기
    const int inputSize = 150; // 입력당 크기 (서명 포함)
    const int outputSize = 34; // 출력당 크기 (P2PKH)

    return baseSize + (inputCount * inputSize) + (outputCount * outputSize);
  }

  /// 수수료 배율 적용 (소수점 처리를 위해 100을 곱하고 나눔)
  BigInt _applyMultiplier(BigInt value, double multiplier) {
    final scaledMultiplier = (multiplier * 100).round();
    return value * BigInt.from(scaledMultiplier) ~/ BigInt.from(100);
  }

  /// 주소의 미사용 UTXO 목록 조회
  Future<List<Map<String, dynamic>>> _getUnspentOutputs(String address) async {
    final response = await _httpClient.get(Uri.parse(
        '$_apiBaseUrl/addrs/$address?unspentOnly=true&includeScript=true&token=${WalletConfig.config.blockCypherToken}'));

    if (response.statusCode != 200) {
      throw CustomException(errMsg: 'Failed to fetch UTXOs: ${response.body}');
    }

    final responseData = json.decode(response.body);
    final txrefs = responseData['txrefs'] as List<dynamic>? ?? [];

    return txrefs
        .where((txref) => txref['spent'] != true && txref['tx_output_n'] >= 0)
        .map((txref) => Map<String, dynamic>.from(txref))
        .toList();
  }

  /// 비트코인 트랜잭션 생성
  /// 입력(UTXO)을 모아서 출력과 거스름돈을 설정하고 서명
  btc.Transaction _buildTransaction({
    required List<Map<String, dynamic>> utxos,
    required String toAddress,
    required BigInt amount,
    required BigInt fee,
    required String fromAddress,
    required btc.ECPair keyPair,
    required btc.NetworkType network,
  }) {
    final txb = btc.TransactionBuilder(network: network);
    int totalInput = 0;

    // UTXO 입력 추가 (필요한 금액만큼만)
    for (var utxo in utxos) {
      txb.addInput(utxo['tx_hash'], utxo['tx_output_n']);
      totalInput += (utxo['value'] as num).toInt();

      if (totalInput >= amount.toInt() + fee.toInt()) break;
    }

    if (totalInput < amount.toInt() + fee.toInt()) {
      throw const CustomException(
          errMsg: 'Insufficient balance for transaction and fee');
    }

    txb.addOutput(toAddress, amount.toInt());

    // 거스름돈 처리 (더스트 한계 고려)
    final changeAmount = totalInput - amount.toInt() - fee.toInt();
    if (changeAmount > 546) {
      // 546 satoshi = 더스트 한계
      txb.addOutput(fromAddress, changeAmount);
    }

    // 모든 입력에 서명
    for (int i = 0; i < txb.inputs.length; i++) {
      txb.sign(vin: i, keyPair: keyPair);
    }

    return txb.build();
  }

  // sendTransaction 메서드가 더 깔끔해짐
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
      final network = WalletConfig.env == Environment.prod
          ? btc.bitcoin
          : TokenData.btcTestNet;

      final keyPair = btc.ECPair.fromPrivateKey(
        AppUtil.hexToUint8List(privateKey),
        network: network,
      );

      if (WalletService.getBtcAddressFromPrivateKey(privateKey) !=
          fromAddress) {
        throw const CustomException(errMsg: '제공된 주소와 개인 키가 일치하지 않습니다.');
      }

      final utxos = await _getUnspentOutputs(fromAddress);

      if (utxos.isEmpty) {
        throw const CustomException(
            errMsg: 'No available unspent UTXOs found.');
      }

      final transaction = _buildTransaction(
        utxos: utxos,
        toAddress: toAddress,
        amount: amount,
        fee: fee,
        fromAddress: fromAddress,
        keyPair: keyPair,
        network: network,
      );

      final response = await _httpClient.post(
        Uri.parse(
            '$_apiBaseUrl/txs/push?token=${WalletConfig.config.blockCypherToken}'),
        body: json.encode({'tx': transaction.toHex()}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 201) {
        throw CustomException(
            errMsg: 'Failed to broadcast transaction: ${response.body}');
      }

      return json.decode(response.body)['tx']['hash'];
    } catch (e) {
      if (e is CustomException) rethrow;
      throw CustomException(errMsg: 'Failed to send Bitcoin transaction: $e');
    }
  }

  @override
  Future<TransactionConfirmationStatus> checkTransactionStatus(
      String txHash) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(
            '$_apiBaseUrl/txs/$txHash?token=${WalletConfig.config.blockCypherToken}'),
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
      return confirmations >= 1
          ? TransactionConfirmationStatus.confirmed
          : TransactionConfirmationStatus.unconfirmed;
    } catch (e) {
      debugPrint('Error checking Bitcoin transaction status: $e');
      return TransactionConfirmationStatus.unconfirmed;
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
      // 트랜잭션 전송
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
      debugPrint('Error in sendAndWaitForTransaction: $e');
      throw Exception('Failed to send and wait for transaction: $e');
    }
  }

  Future<TransactionConfirmationStatus> _waitForTransactionConfirmation(
    String txHash, {
    int maxAttempts = 15,
  }) async {
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
  Future<Map<GasPriority, TransferFee>> estimateTransferFees({
    String? fromAddress,
    String? toAddress,
    BigInt? amount,
  }) async {
    try {
      // 1. 현재 권장 수수료율 조회 (satoshi/byte)
      final response = await _httpClient.get(
        Uri.parse(_apiBaseUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Request timed out'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch Bitcoin fees: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      // 네트워크에서 제공하는 수수료율 사용 (기본값은 더 현실적으로)
      final standardFeeRate =
          BigInt.from((data['medium_fee_per_kb'] ?? 50000) ~/ 1000);

      // 트랜잭션 크기 동적 계산
      const inputCount = 1; // 예시: 입력 개수
      const outputCount = 2; // 예시: 출력 개수 (수취인, 잔액 변경)
      final standardTxSize =
          BigInt.from(_calculateTxSize(inputCount, outputCount));

      // 기본 수수료 (satoshi)
      final baseFee = standardFeeRate * standardTxSize;

      // 각 우선순위별 수수료 계산
      final fees = {
        for (var entry in AppUtil.feePriority(NetworkType.bitcoin).entries)
          entry.key: _applyMultiplier(baseFee, entry.value)
      };

      return {
        for (var priority in GasPriority.values)
          priority: TransferFee(
            gasPrice: BigInt.from(0),
            gasLimit: BigInt.from(0),
            // satoshi 값을 그대로 유지 (나누지 않음)
            estimatedFee: fees[priority]!,
          )
      };
    } catch (e) {
      debugPrint('Error estimating Bitcoin fees: $e');

      // 대체 수수료 계산 로직 개선
      final fallbackFeeRate = BigInt.from(100); // 더 현실적인 기본 수수료율
      final fallbackTxSize = BigInt.from(250); // 평균적인 트랜잭션 크기
      final baseFee = fallbackFeeRate * fallbackTxSize;

      final fees = {
        for (var entry in AppUtil.feePriority(NetworkType.bitcoin).entries)
          entry.key: _applyMultiplier(baseFee, entry.value)
      };

      return {
        for (var priority in GasPriority.values)
          priority: TransferFee(
            gasPrice: BigInt.from(0),
            gasLimit: BigInt.from(0),
            // satoshi에서 BTC로 변환 (1 BTC = 100,000,000 satoshi)
            estimatedFee: fees[priority]! ~/ BigInt.from(100000000),
          )
      };
    }
  }

  @override
  void dispose() {
    _httpClient.close();
  }
}
