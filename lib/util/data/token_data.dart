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

  // 메인넷 토큰 리스트 (ETH)
  static List<TokenInfo> ethTokens = [];
}
