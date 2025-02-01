class TokenInfo {
  final String symbol; // 토큰 심볼
  final String name; // 토큰 이름
  final String address; // 컨트랙트 주소
  final int decimals; // 소수점 자릿수
  final String? logoUrl; // 토큰 로고 URL (옵션)

  const TokenInfo({
    required this.symbol,
    required this.name,
    required this.address,
    required this.decimals,
    this.logoUrl,
  });
}
