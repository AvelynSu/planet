import 'package:planet/model/token_info.dart';

class TokenBalance {
  final String symbol; // 토큰 심볼
  final String name; // 토큰 이름
  final String address; // 컨트랙트 주소
  final int decimals; // 소수점 자릿수
  final String? logoUrl; // 토큰 로고 URL (옵션)
  final double balance;

  const TokenBalance({
    required this.symbol,
    required this.name,
    required this.address,
    required this.decimals,
    this.logoUrl,
    this.balance = 0,
  });

  factory TokenBalance.fromInfo(TokenInfo info, double balance) {
    return TokenBalance(
      symbol: info.symbol,
      name: info.name,
      address: info.address,
      decimals: info.decimals,
      balance: balance,
    );
  }
}
