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

    // 최대 8자리까지만 표시하되 decimals보다 작은 값 사용
    String formatted = balance.toStringAsFixed(min(8, info.decimals));

    // 소수점이 있는 경우에만 처리
    if (formatted.contains('.')) {
      // 후행 0 제거
      while (formatted.endsWith('0')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }

      // 소수점만 남은 경우 소수점도 제거
      if (formatted.endsWith('.')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
    }

    return formatted;
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
