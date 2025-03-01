import '../util/data/token_data.dart';

class TransactionHistory {
  // 공통 필드
  final String hash; // 트랜잭션 해시 (이더리움/비트코인 공통)
  final String from; // 송신자 주소 (이더리움/비트코인 공통)
  final String to; // 수신자 주소 (이더리움/비트코인 공통)
  final DateTime? timestamp; // 트랜잭션 타임스탬프 (이더리움/비트코인 공통)
  final bool isIncoming; // 입금 여부 (이더리움/비트코인 공통)
  final int? confirmations; // 확인 수 (이더리움/비트코인 공통)
  final bool? isSuccess; // 성공 여부 (이더리움/비트코인 공통)

  // 토큰 관련 필드
  final String? tokenSymbol; // 토큰 심볼 (이더리움에서 주로 사용, 비트코인은 "BTC" 고정)
  final double? amount; // 거래 금액 (이더리움/비트코인 공통)
  final int? decimals; // 토큰 소수점 자릿수 (이더리움에서 주로 사용, 비트코인은 8 고정)
  final String? tokenAddress; // 토큰 컨트랙트 주소 (이더리움에서만 사용)

  // 추가 필드
  final double? fee; // 트랜잭션 수수료 (이더리움/비트코인 공통)
  final int? gas; // 가스 한도 (이더리움 전용)
  final double? gasPrice; // 가스 가격 (이더리움 전용)
  final int? gasUsed; // 사용된 가스 (이더리움 전용)
  final String? status; // 트랜잭션 상태 (이더리움/비트코인 공통)

  const TransactionHistory({
    this.hash = "",
    this.from = "",
    this.to = "",
    this.timestamp,
    this.isIncoming = true,
    this.tokenSymbol,
    this.amount,
    this.confirmations,
    this.isSuccess,
    this.decimals,
    this.tokenAddress,
    this.fee,
    this.gas,
    this.gasPrice,
    this.gasUsed,
    this.status,
  });

  static const empty = const TransactionHistory();

  // Etherscan ETH 트랜잭션 응답에서 생성
  factory TransactionHistory.fromEtherscanTx(
    Map<String, dynamic> tx,
    String userAddress,
  ) {
    final decimals =
        TokenData.ethTokens.where((e) => e.symbol == "ETH").first.decimals;

    // Dart에서는 BigInt를 double로 직접 나눌 수 없으므로 계산 방식 변경
    final amountInWei = BigInt.parse(tx['value']);
    final divisor = BigInt.from(10).pow(decimals);
    final wholeNumber = amountInWei ~/ divisor;
    final fraction = amountInWei % divisor;

    // 소수점 이하 계산
    final fractionalPart = fraction.toDouble() / divisor.toDouble();
    final amount = wholeNumber.toDouble() + fractionalPart;

    // 수수료 계산 (gasPrice * gasUsed)
    final gasPrice = BigInt.parse(tx['gasPrice']);
    final gasUsed = BigInt.parse(tx['gasUsed']);
    final feeInWei = gasPrice * gasUsed;
    final feeWhole = feeInWei ~/ divisor;
    final feeFraction = feeInWei % divisor;
    final fee =
        feeWhole.toDouble() + (feeFraction.toDouble() / divisor.toDouble());

    final isSuccess = tx['txreceipt_status'] == '1';
    final status = isSuccess ? 'confirmed' : 'failed';

    return TransactionHistory(
      hash: tx['hash'],
      from: tx['from'],
      to: tx['to'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        int.parse(tx['timeStamp']) * 1000,
      ),
      isIncoming: tx['to'].toLowerCase() == userAddress.toLowerCase(),
      tokenSymbol: 'ETH',
      amount: amount,
      confirmations: int.parse(tx['confirmations']),
      isSuccess: isSuccess,
      decimals: decimals,
      tokenAddress: null, // ETH는 토큰 주소가 없음
      fee: fee,
      gas: int.parse(tx['gas']),
      gasPrice: double.parse(tx['gasPrice']) / 1e9, // Gwei로 변환
      gasUsed: int.parse(tx['gasUsed']),
      status: status,
    );
  }

  // Etherscan 토큰 트랜잭션 응답에서 생성
  factory TransactionHistory.fromEtherscanTokenTx(
    Map<String, dynamic> tx,
    String userAddress,
  ) {
    var info = TokenData.ethTokens
        .where((e) => e.symbol == tx['tokenSymbol'])
        .firstOrNull;
    if (info == null) {
      return TransactionHistory.empty;
    }

    final decimals = info.decimals;

    // Dart에서는 BigInt를 double로 직접 나눌 수 없으므로 계산 방식 변경
    final amountInWei = BigInt.parse(tx['value']);
    final divisor = BigInt.from(10).pow(decimals);
    final wholeNumber = amountInWei ~/ divisor;
    final fraction = amountInWei % divisor;

    // 소수점 이하 계산
    final fractionalPart = fraction.toDouble() / divisor.toDouble();
    final amount = wholeNumber.toDouble() + fractionalPart;

    // 수수료 계산 (가능한 경우)
    double? fee;
    try {
      final gasPrice = BigInt.parse(tx['gasPrice'] ?? '0');
      final gasUsed = BigInt.parse(tx['gasUsed'] ?? '0');
      final ethDivisor = BigInt.from(10).pow(18); // ETH는 항상 18 자리
      final feeInWei = gasPrice * gasUsed;
      final feeWhole = feeInWei ~/ ethDivisor;
      final feeFraction = feeInWei % ethDivisor;
      fee = feeWhole.toDouble() +
          (feeFraction.toDouble() / ethDivisor.toDouble());
    } catch (e) {
      fee = null;
    }

    return TransactionHistory(
      hash: tx['hash'],
      from: tx['from'],
      to: tx['to'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        int.parse(tx['timeStamp']) * 1000,
      ),
      isIncoming: tx['to'].toLowerCase() == userAddress.toLowerCase(),
      tokenSymbol: tx['tokenSymbol'],
      amount: amount,
      confirmations: int.parse(tx['confirmations']),
      isSuccess: true, // 토큰 트랜잭션은 성공한 것으로 간주
      decimals: decimals,
      tokenAddress: tx['contractAddress'],
      fee: fee,
      gas: tx['gas'] != null ? int.parse(tx['gas']) : null,
      gasPrice: tx['gasPrice'] != null
          ? double.parse(tx['gasPrice']) / 1e9
          : null, // Gwei로 변환
      gasUsed: tx['gasUsed'] != null ? int.parse(tx['gasUsed']) : null,
      status: 'confirmed',
    );
  }

  // 내부 트랜잭션 응답에서 생성 (이더리움 전용)
  factory TransactionHistory.fromEtherscanInternalTx(
    Map<String, dynamic> tx,
    String userAddress,
  ) {
    var info = TokenData.ethTokens
        .where((e) => e.symbol == tx['tokenSymbol'])
        .firstOrNull;
    if (info == null) {
      return TransactionHistory.empty;
    }
    // Dart에서는 BigInt를 double로 직접 나눌 수 없으므로 계산 방식 변경
    final amountInWei = BigInt.parse(tx['value']);
    final divisor = BigInt.from(10).pow(info.decimals);
    final wholeNumber = amountInWei ~/ divisor;
    final fraction = amountInWei % divisor;

    // 소수점 이하 계산
    final fractionalPart = fraction.toDouble() / divisor.toDouble();
    final amount = wholeNumber.toDouble() + fractionalPart;

    return TransactionHistory(
      hash: tx['hash'],
      from: tx['from'],
      to: tx['to'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        int.parse(tx['timeStamp']) * 1000,
      ),
      isIncoming: tx['to'].toLowerCase() == userAddress.toLowerCase(),
      tokenSymbol: 'ETH',
      amount: amount,
      confirmations: int.parse(tx['blockNumber']),
      // 내부 트랜잭션은 confirmations 대신 blockNumber 사용
      isSuccess: true,
      // 내부 트랜잭션은 성공한 트랜잭션만 반환됨
      decimals: info.decimals,
      tokenAddress: null, // ETH는 토큰 주소가 없음
      fee: 0, // 내부 트랜잭션은 별도의 수수료가 없음
      gas: 0,
      gasPrice: 0,
      gasUsed: 0,
      status: 'confirmed',
    );
  }

  // BlockCypher 비트코인 트랜잭션 응답에서 생성 (비트코인 전용)
  factory TransactionHistory.fromBlockCypherTx(
    Map<String, dynamic> tx,
    String userAddress,
  ) {
    try {
      final String txHash = tx['hash'] ?? '';
      final int confirmations = tx['confirmations'] ?? 0;
      final DateTime? timestamp =
          tx['received'] != null ? DateTime.parse(tx['received']) : null;

      // 총 입력 및 출력 계산
      List inputs = tx['inputs'] ?? [];
      List outputs = tx['outputs'] ?? [];

      // 사용자 주소와 관련된 입출금 금액 계산
      double value = 0;
      bool isIncoming = false;

      // 받은 금액 계산 (outputs 중 사용자 주소로 들어온 금액)
      for (var output in outputs) {
        List addresses = output['addresses'] ?? [];
        if (addresses.contains(userAddress)) {
          value += (output['value'] ?? 0) / 100000000; // satoshi -> BTC 변환
          isIncoming = true;
        }
      }

      // 보낸 금액 계산 (inputs 중 사용자 주소에서 나간 금액)
      if (!isIncoming) {
        for (var input in inputs) {
          List addresses = input['addresses'] ?? [];
          if (addresses.contains(userAddress)) {
            value = (tx['total'] ?? 0) / 100000000; // satoshi -> BTC 변환
          }
        }
      }

      // 수수료 계산
      double fee = (tx['fees'] ?? 0) / 100000000; // satoshi -> BTC 변환

      // 송신자/수신자 주소 결정
      String from = 'Unknown';
      if (inputs.isNotEmpty &&
          inputs[0]['addresses'] is List &&
          inputs[0]['addresses'].isNotEmpty) {
        from = inputs[0]['addresses'][0];
      }

      String to = 'Unknown';
      if (outputs.isNotEmpty &&
          outputs[0]['addresses'] is List &&
          outputs[0]['addresses'].isNotEmpty) {
        to = outputs[0]['addresses'][0];
      }

      String status = confirmations > 0 ? 'confirmed' : 'pending';

      return TransactionHistory(
        hash: txHash,
        from: from,
        to: to,
        timestamp: timestamp,
        isIncoming: isIncoming,
        tokenSymbol: 'BTC',
        amount: value.abs(),
        confirmations: confirmations,
        isSuccess: true, // BlockCypher API는 성공한 트랜잭션만 반환
        decimals: 8, // BTC는 항상 8 소수점
        tokenAddress: null, // BTC는 토큰 주소가 없음
        fee: fee,
        gas: 0, // Bitcoin에는 해당 없음
        gasPrice: 0, // Bitcoin에는 해당 없음
        gasUsed: 0, // Bitcoin에는 해당 없음
        status: status,
      );
    } catch (e) {
      print('Error parsing Bitcoin transaction: $e');
      return TransactionHistory.empty;
    }
  }
}

// 이더리움 트랜잭션 필드 예시 (Etherscan API 응답)
// 0 = {map entry} "blockNumber" -> "21864720"
// 1 = {map entry} "timeStamp" -> "1739778611"
// 2 = {map entry} "hash" -> "0x337e68af3519f6623baf00a11ed55d94761ca3ebfdcdfd583b75b2fd9de604bd"
// 3 = {map entry} "nonce" -> "4"
// 4 = {map entry} "blockHash" -> "0x499256338649c67fa59ada001deafd412b05afe30c05a5000a4dddfc7fcc9a86"
// 5 = {map entry} "transactionIndex" -> "121"
// 6 = {map entry} "from" -> "0x5a7094f64e580a73051e4f6171a77025ffaa92e8"
// 7 = {map entry} "to" -> "0x2f01fc81c1c54a9d73edd126b45510926ef4099a"
// 8 = {map entry} "value" -> "100000000000000"
// 9 = {map entry} "gas" -> "21000"
// 10 = {map entry} "gasPrice" -> "1175420853"
// 11 = {map entry} "isError" -> "0"
// 12 = {map entry} "txreceipt_status" -> "1"
// 13 = {map entry} "input" -> "0x"
// 14 = {map entry} "contractAddress" -> ""
// 15 = {map entry} "cumulativeGasUsed" -> "10115515"
// 16 = {map entry} "gasUsed" -> "21000"
// 17 = {map entry} "confirmations" -> "25932"
// 18 = {map entry} "methodId" -> "0x"
// 19 = {map entry} "functionName" -> ""

// 비트코인 트랜잭션 필드 예시 (BlockCypher API 응답)
// {
//   "hash": "09a228c6cf72989d81cbcd3a906dcb1d4b4a4c1d796537c34925feea1da2af35",
//   "received": "2023-08-12T15:42:31Z",
//   "confirmations": 120,
//   "inputs": [
//     {
//       "addresses": ["1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"],
//       "output_value": 5000000
//     }
//   ],
//   "outputs": [
//     {
//       "addresses": ["1QENmP2UPQ99peUukfdc6spJFSNh9yk8TS"],
//       "value": 4900000
//     }
//   ],
//   "total": 4900000,
//   "fees": 100000
// }
