import 'package:planet/enum/network_type.dart';

class TokenInfo {
  final String symbol; // 토큰 심볼
  final String name; // 토큰 이름
  final String address; // 컨트랙트 주소
  final int decimals; // 소수점 자릿수
  final String? logoUrl; // 토큰 로고 URL (옵션)
  final NetworkType networkType;
  final String? coingeckoKey;

  // 가격 정보 관련 필드 추가
  final double tokenPrice; // 원화 가격
  final double priceChangePercentage24h; // 24시간 가격 변동률

  const TokenInfo({
    this.symbol = "",
    this.name = "",
    this.address = "",
    this.decimals = 0,
    this.logoUrl,
    this.networkType = NetworkType.ethereum,
    this.coingeckoKey = "",
    this.tokenPrice = 0.0,
    this.priceChangePercentage24h = 0.0,
  });

  // toJson 메서드 추가
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'address': address,
      'decimals': decimals,
      'logoUrl': logoUrl,
      'networkType': networkType.name,
      'coingeckoKey': coingeckoKey,
    };
  }

  factory TokenInfo.fromJson(Map<String, dynamic> json) {
    return TokenInfo(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      decimals: json['decimals'] ?? 0,
      logoUrl: json['logoUrl'],
      networkType: NetworkType.fromJson(json["networkType"]),
      coingeckoKey: json['coingeckoKey'],
    );
  }

  // copyWith 메서드 추가
  TokenInfo copyWith({
    String? symbol,
    String? name,
    String? address,
    int? decimals,
    String? logoUrl,
    NetworkType? networkType,
    String? coingeckoKey,
    double? tokenPrice,
    double? priceChangePercentage24h,
  }) {
    return TokenInfo(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      address: address ?? this.address,
      decimals: decimals ?? this.decimals,
      logoUrl: logoUrl ?? this.logoUrl,
      networkType: networkType ?? this.networkType,
      coingeckoKey: coingeckoKey ?? this.coingeckoKey,
      tokenPrice: tokenPrice ?? this.tokenPrice,
      priceChangePercentage24h:
          priceChangePercentage24h ?? this.priceChangePercentage24h,
    );
  }

  static const empty = TokenInfo();
}
