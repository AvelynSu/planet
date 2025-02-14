class TransactionHistory {
  final String hash;
  final String from;
  final String to;
  final DateTime timestamp;
  final bool isIncoming;
  final String tokenSymbol;
  final double amount;
  final int confirmations;
  final bool isSuccess;
  final int decimals;
  final String? tokenAddress;

  TransactionHistory({
    required this.hash,
    required this.from,
    required this.to,
    required this.timestamp,
    required this.isIncoming,
    required this.tokenSymbol,
    required this.amount,
    required this.confirmations,
    required this.isSuccess,
    required this.decimals,
    this.tokenAddress,
  });

  Map<String, dynamic> toJson() => {
        'hash': hash,
        'from': from,
        'to': to,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'isIncoming': isIncoming,
        'tokenSymbol': tokenSymbol,
        'amount': amount,
        'confirmations': confirmations,
        'isSuccess': isSuccess,
        'decimals': decimals,
        'tokenAddress': tokenAddress,
      };

  factory TransactionHistory.fromJson(Map<String, dynamic> json) =>
      TransactionHistory(
        hash: json['hash'],
        from: json['from'],
        to: json['to'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
        isIncoming: json['isIncoming'],
        tokenSymbol: json['tokenSymbol'],
        amount: json['amount'],
        confirmations: json['confirmations'],
        isSuccess: json['isSuccess'],
        decimals: json['decimals'],
        tokenAddress: json['tokenAddress'],
      );

  // Etherscan ETH 트랜잭션 응답에서 생성
  factory TransactionHistory.fromEtherscanTx(
    Map<String, dynamic> tx,
    String userAddress,
  ) {
    final value = BigInt.parse(tx['value']);
    return TransactionHistory(
      hash: tx['hash'],
      from: tx['from'],
      to: tx['to'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        int.parse(tx['timeStamp']) * 1000,
      ),
      isIncoming: tx['to'].toLowerCase() == userAddress.toLowerCase(),
      tokenSymbol: 'ETH',
      amount: value / BigInt.from(10).pow(18),
      confirmations: int.parse(tx['confirmations']),
      isSuccess: tx['isError'] == '0',
      decimals: 18,
    );
  }

  // Etherscan 토큰 트랜잭션 응답에서 생성
  factory TransactionHistory.fromEtherscanTokenTx(
    Map<String, dynamic> tx,
    String userAddress,
  ) {
    final decimals = int.parse(tx['tokenDecimal']);
    final value = BigInt.parse(tx['value']);
    return TransactionHistory(
      hash: tx['hash'],
      from: tx['from'],
      to: tx['to'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        int.parse(tx['timeStamp']) * 1000,
      ),
      isIncoming: tx['to'].toLowerCase() == userAddress.toLowerCase(),
      tokenSymbol: tx['tokenSymbol'],
      amount: value / BigInt.from(10).pow(decimals),
      confirmations: int.parse(tx['confirmations']),
      isSuccess: true,
      decimals: decimals,
      tokenAddress: tx['contractAddress'],
    );
  }
}
