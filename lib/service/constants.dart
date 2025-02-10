import '../model/token_info.dart';

class Constants {
  // 메인넷 토큰 리스트 (ETH)
  static const List<TokenInfo> mainnetTokens = [
    TokenInfo(
      symbol: 'USDT',
      name: 'Tether USD',
      address: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
      decimals: 6,
    ),
    TokenInfo(
      symbol: 'USDC',
      name: 'USD Coin',
      address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
      decimals: 6,
    ),
    TokenInfo(
      symbol: 'DAI',
      name: 'Dai Stablecoin',
      address: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
      decimals: 18,
    ),
    TokenInfo(
      symbol: 'WETH',
      name: 'Wrapped Ether',
      address: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
      decimals: 18,
    ),
    TokenInfo(
      symbol: 'UNI',
      name: 'Uniswap',
      address: '0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984',
      decimals: 18,
    ),
    TokenInfo(
      symbol: 'EVZ',
      name: 'EVZ',
      address: '0x7A939Bb714fd2A48EbeB1E495AA9aaa74BA9fA68',
      decimals: 18,
    ),
  ];

// // 테스트넷(Goerli) 토큰 리스트
// static const List<TokenInfo> testnetTokens = [
//   TokenInfo(
//     symbol: 'USDT',
//     name: 'Tether USD (Goerli)',
//     address: '0x509Ee0d083DdF8AC028f2a56731412edD63223B9',
//     decimals: 6,
//   ),
//   // 필요한 테스트넷 토큰들 추가...
// ];
}
