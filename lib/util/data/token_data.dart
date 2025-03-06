import 'package:planet/enum/network_type.dart';

import '../../../model/token_info.dart';

class TokenData {
  static const TokenInfo bitToken = TokenInfo(
    name: "Bitcoin",
    symbol: "BTC",
    address: "",
    // 네이티브 토큰은 주소가 필요 없음
    decimals: 8,
    logoUrl: "icons/ic_bitcoin.png",
    networkType: NetworkType.bitcoin,
    coingeckoKey: "bitcoin",
  );

  // 메인넷 토큰 리스트 (ETH)
  static const List<TokenInfo> ethTokens = [
    TokenInfo(
      symbol: 'ETH',
      name: 'Ethereum',
      address: '0x0000000000000000000000000000000000000000',
      // ETH는 네이티브 토큰이라 주소가 0 주소
      decimals: 18,
      logoUrl: "icons/ic_ethereum.png",
      coingeckoKey: "ethereum",
    ),
    TokenInfo(
      symbol: 'USDT',
      name: 'Tether USD',
      address: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
      decimals: 6,
      logoUrl: "icons/ic_tether_usd.png",
      coingeckoKey: "tether",
    ),
    TokenInfo(
      symbol: 'USDC',
      name: 'USD Coin',
      address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
      decimals: 6,
      logoUrl: "icons/ic_usd_coin.png",
      coingeckoKey: "usd-coin",
    ),
    TokenInfo(
      symbol: 'DAI',
      name: 'Dai Stablecoin',
      address: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
      decimals: 18,
      logoUrl: "icons/ic_dai_stablecoin.png",
      coingeckoKey: "dai",
    ),
    TokenInfo(
      symbol: 'WETH',
      name: 'Wrapped Ether',
      address: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
      decimals: 18,
      logoUrl: "icons/ic_wrapped_ether.png",
      coingeckoKey: "weth",
    ),
    // TokenInfo(
    //   symbol: 'UNI',
    //   name: 'Uniswap',
    //   address: '0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984',
    //   decimals: 18,
    //   coingeckoKey: "uniswap",
    // ),
    // TokenInfo(
    //   symbol: 'EVZ',
    //   name: 'EVZ',
    //   address: '0x7A939Bb714fd2A48EbeB1E495AA9aaa74BA9fA68',
    //   decimals: 18,
    //   coingeckoKey: "evz",
    // ),
  ];
}
