import '../ui/util/data/token_data.dart';

class TransactionHistory {
  final String hash;
  final String from;
  final String to;
  final DateTime? timestamp;
  final bool isIncoming;
  final String? tokenSymbol;
  final double? amount;
  final int? confirmations;
  final bool? isSuccess;
  final int? decimals;
  final String? tokenAddress;

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
      isSuccess: tx['txreceipt_status'] == '1',
      decimals: decimals,
      tokenAddress: null, // ETH는 토큰 주소가 없음
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
      isSuccess: true,
      decimals: decimals,
      tokenAddress: tx['contractAddress'],
    );
  }

  // 내부 트랜잭션 응답에서 생성 // todo : 내부는 안보일수도있음
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
    );
  }
}

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
