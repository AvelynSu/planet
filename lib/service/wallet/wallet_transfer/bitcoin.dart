part of 'walltet_transfer_service.dart';

/// 비트코인 전송 서비스
class _BitcoinTransferService implements _BlockchainTransferService {
  final String _apiBaseUrl;
  final http.Client _httpClient;
  final WalletConfig config;

  _BitcoinTransferService({String? apiBaseUrl})
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

      // 네트워크에서 제공하는 수수료율 사용 (기본값은 더 현실적으로)
      final standardFeeRate =
          BigInt.from(data['medium'] ?? 50); // 50 satoshi/byte로 조정

      // 트랜잭션 크기 동적 계산
      final inputCount = 1; // 예시: 입력 개수
      final outputCount = 2; // 예시: 출력 개수 (수취인, 잔액 변경)
      final standardTxSize =
          BigInt.from(_calculateTxSize(inputCount, outputCount));

      // 기본 수수료 (satoshi)
      final baseFee = standardFeeRate * standardTxSize;

      // 각 우선순위별 수수료 계산
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
    } catch (e) {
      debugPrint('Error estimating Bitcoin fees: $e');

      // 대체 수수료 계산 로직 개선
      final fallbackFeeRate = BigInt.from(100); // 더 현실적인 기본 수수료율
      final fallbackTxSize = BigInt.from(250); // 평균적인 트랜잭션 크기
      final baseFee = fallbackFeeRate * fallbackTxSize;

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

// 트랜잭션 크기 계산 헬퍼 메서드
  int _calculateTxSize(int inputCount, int outputCount) {
    // 대략적인 트랜잭션 크기 계산
    // 이는 대략적인 추정치이며, 실제 크기는 서명 등에 따라 달라질 수 있음
    const int baseSize = 10; // 기본 트랜잭션 오버헤드
    const int inputSize = 150; // P2PKH 인풋 평균 크기
    const int outputSize = 34; // P2PKH 아웃풋 평균 크기

    return baseSize + (inputCount * inputSize) + (outputCount * outputSize);
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
