import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:planet/model/token_balance.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/util/app_util.dart';
import 'package:planet/util/data/token_abi.dart';
import 'package:web3dart/web3dart.dart';

import '../../util/data/token_data.dart';
import '../../util/wallet_config.dart';

class WalletBalanceService {
  final Web3Client web3client;

  WalletBalanceService()
      : web3client = Web3Client(WalletConfig().rpcUrl, http.Client());

  _hexToAddress(String address) {
    return EthereumAddress.fromHex(address);
  }

  /// 특정 토큰 1개의 잔액 조회
  Future<TokenBalance> getTokenBalance({
    required String address, // 잔액을 조회할 지갑 주소
    required TokenInfo info, // 토큰 정보
  }) async {
    try {
      // ETH(네이티브 토큰)인 경우
      if (info.symbol == "ETH") {
        final balance = await web3client.getBalance(_hexToAddress(address));
        var value = AppUtil.weiToEth(balance.getInWei);
        return TokenBalance(address: address, info: info, balance: value);
      }
      // ERC-20 토큰인 경우
      else {
        // 1. 컨트랙트 인스턴스 생성
        final contract = DeployedContract(
          ContractAbi.fromJson(TokenAbi.ERC20, 'ERC20'), // ABI와 컨트랙트 이름
          _hexToAddress(info.address), // 토큰 컨트랙트 주소
        );

        // 2. balanceOf 함수 레퍼런스 가져오기
        final balanceFunction = contract.function('balanceOf');

        // 3. balanceOf 함수 호출
        final result = await web3client.call(
          contract: contract,
          function: balanceFunction,
          params: [_hexToAddress(address)],
        );

        var rawBalance = result.first as BigInt;
        // 토큰의 decimals에 따라 변환
        final actualBalance = AppUtil.rawToActual(rawBalance, info.decimals);

        return TokenBalance.fromInfo(info, address, actualBalance);
      }
    } catch (e) {
      debugPrint('Error getting ${info.symbol} balance: $e');
      throw Exception('Failed to get ${info.symbol} balance');
    }
  }

  /// 지갑의 모든 지원 토큰 잔액 조회
  Future<List<TokenBalance>> getAllTokenBalances(
      {required String walletAddress}) async {
    try {
      // 모든 토큰에 대한 Future 생성
      final futures = TokenData.ethTokens
          .map((token) => getTokenBalance(address: walletAddress, info: token));

      // 병렬로 실행
      final balances = await Future.wait(futures);
      return balances;
    } catch (e) {
      debugPrint('Error getting all balances: $e');
      throw Exception('Failed to get all balances');
    }
  }

  /// 서비스 종료 시 리소스 해제
  void dispose() {
    web3client.dispose();
  }
}
