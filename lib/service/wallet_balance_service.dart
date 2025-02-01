import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import '../model/token_info.dart';

class WalletBalanceService {
  final Web3Client web3client;

  // ERC-20 표준 인터페이스의 ABI (Application Binary Interface)
  // balanceOf 함수만 포함된 최소 버전
  final String erc20Abi = '''[
    {
      "constant": true,
      "inputs": [{"name": "_owner", "type": "address"}],
      "name": "balanceOf",
      "outputs": [{"name": "balance", "type": "uint256"}],
      "type": "function"
    }
  ]''';

  WalletBalanceService({
    required String rpcUrl, // 이더리움 노드 RPC URL
  }) : web3client = Web3Client(rpcUrl, http.Client());

  /// 지갑의 ETH 잔액 조회
  Future<BigInt> getEthBalance(String address) async {
    try {
      // getBalance는 Wei 단위로 잔액을 반환 (1 ETH = 10^18 Wei)
      final balance =
          await web3client.getBalance(EthereumAddress.fromHex(address));
      return balance.getInWei;
    } catch (e) {
      print('Error getting ETH balance: $e');
      throw Exception('Failed to get ETH balance');
    }
  }

  /// 지정된 ERC-20 토큰의 잔액 조회
  Future<BigInt> getTokenBalance({
    required String walletAddress, // 잔액을 조회할 지갑 주소
    required String tokenAddress, // 토큰 컨트랙트 주소
  }) async {
    try {
      // 1. 컨트랙트 인스턴스 생성
      final contract = DeployedContract(
        ContractAbi.fromJson(erc20Abi, 'ERC20'), // ABI와 컨트랙트 이름
        EthereumAddress.fromHex(tokenAddress), // 토큰 컨트랙트 주소
      );

      // 2. balanceOf 함수 레퍼런스 가져오기
      final balanceFunction = contract.function('balanceOf');

      // 3. balanceOf 함수 호출
      final result = await web3client.call(
        contract: contract,
        function: balanceFunction,
        params: [EthereumAddress.fromHex(walletAddress)],
      );

      // 4. 결과 반환 (BigInt 타입)
      return result.first as BigInt;
    } catch (e) {
      print('Error getting token balance: $e');
      throw Exception('Failed to get token balance');
    }
  }

  /// 지갑의 모든 지원 토큰 잔액 조회
  Future<Map<String, double>> getAllTokenBalances({
    required String walletAddress,
    required List<TokenInfo> supportedTokens,
  }) async {
    Map<String, double> balances = {};

    try {
      // 1. ETH 잔액 조회
      final ethBalance = await getEthBalance(walletAddress);
      // Wei를 ETH로 변환 (18 자리 소수점)
      balances['ETH'] = ethBalance / BigInt.from(10).pow(18);

      // 2. 각 ERC-20 토큰 잔액 조회
      for (var token in supportedTokens) {
        final rawBalance = await getTokenBalance(
          walletAddress: walletAddress,
          tokenAddress: token.address,
        );

        // 토큰의 decimals에 따라 변환
        // 예: USDT는 6자리, 대부분의 토큰은 18자리
        final actualBalance = rawBalance / BigInt.from(10).pow(token.decimals);
        balances[token.symbol] = actualBalance;
      }

      return balances;
    } catch (e) {
      print('Error getting all balances: $e');
      throw Exception('Failed to get all balances');
    }
  }

  /// Wei 단위를 ETH 단위로 변환 (1 ETH = 10^18 Wei)
  double weiToEth(BigInt wei) {
    return wei / BigInt.from(10).pow(18);
  }

  /// 토큰 단위 변환 (decimals에 따라)
  double rawToActual(BigInt raw, int decimals) {
    return raw / BigInt.from(10).pow(decimals);
  }

  /// 서비스 종료 시 리소스 해제
  void dispose() {
    web3client.dispose();
  }
}

// void example() async {
//   final service = WalletBalanceService(
//     rpcUrl: 'https://mainnet.infura.io/v3/e2e92d65ad42465e880c01edc6969cba',
//   );
//
//   final walletAddress = '0x123...'; // 사용자 지갑 주소
//
//   try {
//     // 모든 지원 토큰의 잔액 조회
//     final balances = await service.getAllTokenBalances(
//       walletAddress: walletAddress,
//       supportedTokens: SupportedTokens.mainnetTokens,
//     );
//
//     // 결과 출력
//     balances.forEach((symbol, balance) {
//       print('$symbol: $balance');
//     });
//   } catch (e) {
//     print('Error: $e');
//   } finally {
//     service.dispose(); // 리소스 해제
//   }
// }

class SupportedTokens {
  // 메인넷 토큰 리스트
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

  // 테스트넷(Goerli) 토큰 리스트
  static const List<TokenInfo> testnetTokens = [
    TokenInfo(
      symbol: 'USDT',
      name: 'Tether USD (Goerli)',
      address: '0x509Ee0d083DdF8AC028f2a56731412edD63223B9',
      decimals: 6,
    ),
    // 필요한 테스트넷 토큰들 추가...
  ];
}
