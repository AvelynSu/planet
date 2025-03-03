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
  Future<Map<GasPriority, TransferFee>> estimateTransferFees({
    String? fromAddress,
    String? toAddress,
    BigInt? amount,
  }) async {
    try {
      // 1. 현재 권장 수수료율 조회 (satoshi/byte)
      final response = await _httpClient.get(
        Uri.parse('$_apiBaseUrl'),
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
        for (var entry in _feePriorityMultipliers.entries)
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
      // 1. 수수료 추정
      final feesMap = await estimateTransferFees();
      final fee = feesMap[gasPriority]!.estimatedFee;

      // 2. 커스텀 수수료로 트랜잭션 전송
      return await sendTransactionWithCustomFee(
        fromAddress: fromAddress,
        toAddress: toAddress,
        amount: amount,
        privateKey: privateKey,
        fee: fee,
      );
    } catch (e) {
      debugPrint('Error sending Bitcoin transaction: $e');
      throw Exception('Failed to send Bitcoin transaction: $e');
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
      // 1. 새 트랜잭션 생성 요청
      final token = config.blockCypherToken;
      final newTxUrl = '$_apiBaseUrl/txs/new?token=$token';

      final newTxResponse = await _httpClient
          .post(
            Uri.parse(newTxUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'inputs': [
                {
                  'addresses': [fromAddress]
                }
              ],
              'outputs': [
                {
                  'addresses': [toAddress],
                  'value': amount.toInt()
                }
              ],
              'fees': fee.toInt(),
            }),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw Exception('Request timed out creating transaction'),
          );

      if (newTxResponse.statusCode != 200 && newTxResponse.statusCode != 201) {
        throw Exception(
            'Failed to create transaction: ${newTxResponse.statusCode}, ${newTxResponse.body}');
      }

      final txSkeleton = json.decode(newTxResponse.body);

      // 서명을 위한 데이터가 없으면 오류
      if (txSkeleton['tosign'] == null ||
          (txSkeleton['tosign'] as List).isEmpty) {
        throw Exception('No data to sign in transaction response');
      }

      // 2. 데이터 서명
      final signatures = <String>[];
      final List<dynamic> toSignList = txSkeleton['tosign'];

      // 비트코인 라이브러리를 사용하여 데이터 서명
      final bitcoinNetwork = WalletConfig.env == Environment.prod
          ? btc.bitcoin
          : btc.NetworkType(
              messagePrefix: '\x18BlockCypher Signed Message:\n',
              bech32: 'bc',
              bip32: btc.Bip32Type(public: 0x0488b21e, private: 0x0488ade4),
              pubKeyHash: 0x1B,
              scriptHash: 0x1F,
              wif: 0x49, // BCY testnet용 WIF
            );

      final cleanPrivateKey = privateKey.trim();

      final keyPair =
          btc.ECPair.fromWIF(cleanPrivateKey, network: bitcoinNetwork);

      signatures.clear(); // 기존 signatures 초기화

      for (String dataToSign in toSignList.cast<String>()) {
        if (dataToSign.isEmpty) {
          throw Exception('Empty data to sign');
        }

        // 16진수 문자열을 바이트 배열로 변환
        final dataBytes = _hexToBytes(dataToSign);

        // 서명 생성
        final signature = keyPair.sign(dataBytes);

        signatures.add(_bytesToHex(signature));
      }

      // 서명 없으면 예외 처리
      if (signatures.isEmpty) {
        throw Exception('No signatures generated');
      }

      // 3. 서명된 트랜잭션 전송
      final sendTxUrl = '$_apiBaseUrl/txs/send?token=$token';
      final body = {
        'tx': txSkeleton['tx'],
        'tosign': txSkeleton['tosign'],
        'signatures': signatures,
        'pubkeys': [_bytesToHex(keyPair.publicKey)],
      };
      print(body);
      final sendResponse = await _httpClient
          .post(
            Uri.parse(sendTxUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw Exception('Request timed out sending transaction'),
          );

      if (sendResponse.statusCode != 200 && sendResponse.statusCode != 201) {
        throw Exception(
            'Failed to send transaction: ${sendResponse.statusCode}, ${sendResponse.body}');
      }

      final sendData = json.decode(sendResponse.body);

      // 트랜잭션 해시 반환
      return sendData['tx']['hash'];
    } catch (e) {
      debugPrint('Error sending Bitcoin transaction with custom fee: $e');
      throw Exception('Failed to send Bitcoin transaction: $e');
    }
  }

  @override
  Future<bool> checkTransactionStatus(String txHash) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(
            '$_apiBaseUrl/txs/$txHash?token=${WalletConfig().blockCypherToken}'),
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

  @override
  Future<bool> sendAndWaitForTransaction({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String privateKey,
    required GasPriority gasPriority,
  }) async {
    try {
      // 트랜잭션 전송
      final txHash = await sendTransaction(
        fromAddress: fromAddress,
        toAddress: toAddress,
        amount: amount,
        privateKey: privateKey,
        gasPriority: gasPriority,
      );

      // 트랜잭션 확인 대기 (최대 20번 시도, 15초마다)
      const maxAttempts = 20;
      const pollInterval = Duration(seconds: 15);

      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        // 첫 번째 시도가 아니면 잠시 대기
        if (attempt > 0) {
          await Future.delayed(pollInterval);
        }

        // 트랜잭션 상태 확인
        final isConfirmed = await checkTransactionStatus(txHash);

        if (isConfirmed) {
          return true;
        }
      }

      // 모든 폴링 시도 후에도 확인되지 않음
      return false;
    } catch (e) {
      debugPrint('Error in sendAndWaitForTransaction: $e');
      throw Exception('Failed to send and wait for transaction: $e');
    }
  }

  @override
  void dispose() {
    _httpClient.close();
  }

  // 16진수 문자열을 바이트 배열로 변환하는 유틸리티 메서드
  Uint8List _hexToBytes(String hex) {
    // 홀수 길이 문자열은 앞에 0을 추가
    if (hex.length % 2 != 0) {
      hex = '0$hex';
    }

    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < hex.length; i += 2) {
      final byte = int.parse(hex.substring(i, i + 2), radix: 16);
      result[i ~/ 2] = byte;
    }
    return result;
  }

  // 바이트 배열을 16진수 문자열로 변환하는 유틸리티 메서드
  String _bytesToHex(Uint8List bytes) {
    return List.generate(
        bytes.length, (i) => bytes[i].toRadixString(16).padLeft(2, '0')).join();
  }
}
