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

// 주소 생성 메서드
  String getAddressFromPrivateKey(String privateKey) {
    final keyPair = btc.ECPair.fromPrivateKey(hexToUint8List(privateKey));
    final network = WalletConfig.env == Environment.prod
        ? btc.bitcoin
        : btc.NetworkType(
            messagePrefix: '\x18BlockCypher Signed Message:\n',
            bech32: 'bc',
            bip32: btc.Bip32Type(public: 0x0488b21e, private: 0x0488ade4),
            pubKeyHash: 0x1B,
            scriptHash: 0x1F,
            wif: 0x49,
          );
    return btc
            .P2PKH(
              data: btc.PaymentData(pubkey: keyPair.publicKey),
              network: network,
            )
            .data
            .address ??
        "";
  }

  Uint8List hexToUint8List(String hex) {
    // 16진수 문자열에서 '0x' 접두사 제거
    hex = hex.replaceFirst('0x', '');

    // 홀수 길이일 경우 앞에 0 추가
    if (hex.length % 2 != 0) {
      hex = '0$hex';
    }

    return Uint8List.fromList(List.generate(hex.length ~/ 2,
        (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)));
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
      // 네트워크 설정
      final network = WalletConfig.env == Environment.prod
          ? btc.bitcoin
          : btc.NetworkType(
              messagePrefix: '\x18BlockCypher Signed Message:\n',
              bech32: 'bc',
              bip32: btc.Bip32Type(public: 0x0488b21e, private: 0x0488ade4),
              pubKeyHash: 0x1B,
              scriptHash: 0x1F,
              wif: 0x49,
            );

      // 키페어 생성
      final keyPair = btc.ECPair.fromPrivateKey(hexToUint8List(privateKey),
          network: network);
      final senderAddress = getAddressFromPrivateKey(privateKey);

      if (senderAddress != fromAddress) {
        throw Exception('제공된 주소와 개인 키가 일치하지 않습니다.');
      }

      // 다른 API 엔드포인트 사용 - unspent outputs만 가져옴
      final utxoResponse = await http.get(Uri.parse(
          '$_apiBaseUrl/addrs/$fromAddress?unspentOnly=true&includeScript=true&token=${WalletConfig().blockCypherToken}'));

      if (utxoResponse.statusCode != 200) {
        throw Exception('Failed to fetch UTXOs : ${utxoResponse.body}');
      }

      // API 응답 디버깅
      debugPrint('UTXO response : ${utxoResponse.body}');

      final Map<String, dynamic> responseData = json.decode(utxoResponse.body);

      // txrefs 필드에서 미사용 출력 가져옴
      List<dynamic> unspentOutputs = responseData['txrefs'] ?? [];

      // 미사용 상태만 명시적으로 필터링
      unspentOutputs = unspentOutputs
          .where((txref) =>
                  txref['spent'] != true &&
                  txref['tx_output_n'] >= 0 // 출력 인덱스가 0 이상인 경우만 (입력이 아닌 출력)
              )
          .toList();

      if (unspentOutputs.isEmpty) {
        throw Exception('No available unspent UTXOs found.');
      }

      // 트랜잭션 빌더
      final txb = btc.TransactionBuilder(network: network);
      int totalInput = 0;

      // 선택된 UTXO 입력 추가
      for (var utxo in unspentOutputs) {
        String txHash = utxo['tx_hash'];
        int vout = utxo['tx_output_n'];
        int value = utxo['value'];

        txb.addInput(txHash, vout);
        totalInput += value;

        // 필요한 금액을 충족하면 중단 (입력 최소화)
        if (totalInput >= amount.toInt() + fee.toInt()) {
          break;
        }
      }

      if (totalInput < amount.toInt() + fee.toInt()) {
        throw Exception(
            'Insufficient balance: total input ($totalInput) is less than output (${amount.toInt()}) plus fee(${fee.toInt()})');
      }

      // 출력 추가
      txb.addOutput(toAddress, amount.toInt());

      // 거스름돈 계산 및 추가
      final int changeAmount = totalInput - amount.toInt() - fee.toInt();
      if (changeAmount > 546) {
        // 546 사토시는 더스트 한계
        txb.addOutput(fromAddress, changeAmount);
      }

      // 서명
      for (int i = 0; i < txb.inputs.length; i++) {
        txb.sign(
          vin: i,
          keyPair: keyPair,
        );
      }

      // 트랜잭션 브로드캐스트
      final txHex = txb.build().toHex();

      debugPrint('Transaction Hex: $txHex');

      final broadcastResponse = await http.post(
        Uri.parse(
            '$_apiBaseUrl/txs/push?token=${WalletConfig().blockCypherToken}'),
        body: json.encode({'tx': txHex}),
        headers: {'Content-Type': 'application/json'},
      );

      if (broadcastResponse.statusCode != 201) {
        throw Exception(
            'Failed to broadcast transaction : ${broadcastResponse.body}');
      }

      final broadcastResult = json.decode(broadcastResponse.body);
      return broadcastResult['tx']['hash'];
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
    required BigInt fee,
  }) async {
    try {
      // 트랜잭션 전송
      final txHash = await sendTransactionWithCustomFee(
        fromAddress: fromAddress,
        toAddress: toAddress,
        amount: amount,
        privateKey: privateKey,
        fee: fee,
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
