import 'package:flutter_bitcoin/flutter_bitcoin.dart' as btc;
import 'package:planet/enum/network_type.dart';

import '../../../model/token_info.dart';

class TokenData {
  static btc.NetworkType btcTestNet = btc.NetworkType(
    messagePrefix: '\x18BlockCypher Signed Message:\n',
    bech32: 'bc',
    bip32: btc.Bip32Type(public: 0x0488b21e, private: 0x0488ade4),
    pubKeyHash: 0x1B,
    scriptHash: 0x1F,
    wif: 0x49,
  );

  static const List<TokenInfo> bscTokens = [
    // BNB (네이티브 토큰)
    TokenInfo(
      symbol: "BNB",
      name: "Binance Coin",
      address: "",
      // 네이티브 토큰은 주소 필요 없음
      decimals: 18,
      logoUrl:
          "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_bsc.png?alt=media&token=da3578ae-495c-49e0-9111-7ac0c09ee77d",
      networkType: NetworkType.bsc,
      coingeckoKey: "binancecoin",
    ),

    // USDT (BEP-20)
    TokenInfo(
      symbol: "USDT",
      name: "Tether USD",
      address: "0x55d398326f99059fF775485246999027B3197955",
      decimals: 18,
      logoUrl:
          "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_bsc.png?alt=media&token=da3578ae-495c-49e0-9111-7ac0c09ee77d",
      networkType: NetworkType.bsc,
      coingeckoKey: "tether",
    ),

    // CAKE (PancakeSwap 토큰)
    TokenInfo(
      symbol: "CAKE",
      name: "PancakeSwap Token",
      address: "0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82",
      decimals: 18,
      logoUrl:
          "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_bsc.png?alt=media&token=da3578ae-495c-49e0-9111-7ac0c09ee77d",
      networkType: NetworkType.bsc,
      coingeckoKey: "pancakeswap-token",
    ),
  ];

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
