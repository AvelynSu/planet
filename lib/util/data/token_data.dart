import 'package:planet/enum/network_type.dart';

import '../../../model/token_info.dart';

class TokenData {
  static const TokenInfo bitToken = TokenInfo(
    name: "Bitcoin",
    symbol: "BTC",
    address: "",
    // 네이티브 토큰은 주소가 필요 없음
    decimals: 8,
    logoUrl:
        "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_bitcoin.png?alt=media&token=10606240-6ec8-4f0e-99d6-67a49cc70b72",
    networkType: NetworkType.bitcoin,
    coingeckoKey: "bitcoin",
  );

  // 이더리움 토큰 리스트
  static List<TokenInfo> ethTokens = [];

  // 솔라나 토큰 리스트
  static List<TokenInfo> solanaTokens = [];
}

class TokenDataSet {
  final List<TokenInfo> etherium;
  final List<TokenInfo> solana;

  TokenDataSet({required this.etherium, required this.solana});

  factory TokenDataSet.fromJson(Map<String, dynamic> json) {
    return TokenDataSet(
      etherium: (json["ethereum"] as List<dynamic>)
          .map((e) => TokenInfo.fromJson(e))
          .toList(),
      solana: (json["solana"] as List<dynamic>)
          .map((e) => TokenInfo.fromJson(e))
          .toList(),
    );
  }
}
