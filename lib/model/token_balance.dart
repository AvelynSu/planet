import 'dart:math';

import 'package:planet/model/token_info.dart';

class TokenBalance {
  final TokenInfo info;
  final String address;
  final double balance;

  const TokenBalance({
    this.info = TokenInfo.empty,
    this.address = "",
    this.balance = 0,
  });

  static const empty = TokenBalance();

  double get price {
    return (info.tokenPrice * balance);
  }

  String get balanceToString {
    if (balance == 0) {
      return "0";
    }
    return balance.toStringAsFixed(min(8, info.decimals));
  }

  factory TokenBalance.fromInfo(
    TokenInfo info,
    String address,
    double balance,
  ) {
    return TokenBalance(
      info: info,
      address: address,
      balance: balance,
    );
  }

  TokenBalance copyWith({
    TokenInfo? info,
    String? address,
    double? balance,
  }) {
    return TokenBalance(
      info: info ?? this.info,
      address: address ?? this.address,
      balance: balance ?? this.balance,
    );
  }
}
