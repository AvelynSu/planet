import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:planet/model/token_balance.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/ui/util/wallet_config.dart';
import 'package:web3dart/web3dart.dart';

import '../../ui/util/data/token_data.dart';

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

  WalletBalanceService()
      : web3client = Web3Client(WalletConfig().rpcUrl, http.Client());

  /// 지갑의 ETH 잔액 조회 (네이티브 토큰)
  Future<BigInt> getEthBalance(String address) async {
    try {
      // getBalance는 Wei 단위로 잔액을 반환 (1 ETH = 10^18 Wei)
      final balance =
          await web3client.getBalance(EthereumAddress.fromHex(address));
      return balance.getInWei;
    } catch (e) {
      debugPrint('Error getting ETH balance: $e');
      throw Exception('Failed to get ETH balance');
    }
  }

  /// 지정된 ERC-20 토큰의 잔액 조회 (스마트컨트렉트로 만들어진 토큰
  Future<TokenBalance> getTokenBalance({
    required String address, // 잔액을 조회할 지갑 주소
    required TokenInfo info, // 토큰 컨트랙트 주소
  }) async {
    try {
      // 1. 컨트랙트 인스턴스 생성
      final contract = DeployedContract(
        ContractAbi.fromJson(erc20Abi, 'ERC20'), // ABI와 컨트랙트 이름
        EthereumAddress.fromHex(info.address), // 토큰 컨트랙트 주소
      );

      // 2. balanceOf 함수 레퍼런스 가져오기
      final balanceFunction = contract.function('balanceOf');

      // 3. balanceOf 함수 호출
      final result = await web3client.call(
        contract: contract,
        function: balanceFunction,
        params: [EthereumAddress.fromHex(address)],
      );

      var rawBalance = result.first as BigInt;
      // 토큰의 decimals에 따라 변환
      // 예: USDT는 6자리, 대부분의 토큰은 18자리
      final actualBalance = rawBalance / BigInt.from(10).pow(info.decimals);

      return TokenBalance.fromInfo(info, address, actualBalance);
    } catch (e) {
      debugPrint('Error getting token balance: $e');
      throw Exception('Failed to get token balance');
    }
  }

  /// 지갑의 모든 지원 토큰 잔액 조회
  Future<List<TokenBalance>> getAllTokenBalances(
      {required String walletAddress}) async {
    Map<String, double> balances = {};

    try {
      // 1. ETH 잔액 조회
      final ethBalance = await getEthBalance(walletAddress);
      // Wei를 ETH로 변환 (18 자리 소수점)
      balances['ETH'] = ethBalance / BigInt.from(10).pow(18);

      // 2. 각 ERC-20 토큰 잔액 조회
      for (var token in TokenData.ethTokens) {
        if (token.symbol != "ETH") {
          final rawBalance = await getTokenBalance(
            address: walletAddress,
            info: token,
          );

          balances[token.symbol] = rawBalance.balance;
        }
      }

      List<TokenBalance> items = [];

      for (var item in TokenData.ethTokens) {
        items.add(
          TokenBalance.fromInfo(
            item,
            walletAddress,
            balances[item.symbol] ?? 0,
          ),
        );
      }

      return items;
    } catch (e) {
      debugPrint('Error getting all balances: $e');
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
