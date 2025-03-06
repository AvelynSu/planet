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
