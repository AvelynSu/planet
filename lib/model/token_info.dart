import 'package:planet/enum/network_type.dart';

class TokenInfo {
  final String symbol; // 토큰 심볼
  final String name; // 토큰 이름
  final String address; // 컨트랙트 주소
  final int decimals; // 소수점 자릿수
  final String? logoUrl; // 토큰 로고 URL (옵션)
  final NetworkType networkType;

  const TokenInfo({
    this.symbol = "",
    this.name = "",
    this.address = "",
    this.decimals = 0,
    this.logoUrl,
    this.networkType = NetworkType.ethereum,
  });

  static const empty = TokenInfo();
}
