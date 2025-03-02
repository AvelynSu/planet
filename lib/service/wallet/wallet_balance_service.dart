import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:planet/model/token_balance.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/util/app_util.dart';
import 'package:planet/util/data/token_abi.dart';
import 'package:web3dart/web3dart.dart';

import '../../enum/network_type.dart';
import '../../util/data/token_data.dart';
import '../../util/wallet_config.dart';

class WalletBalanceService {
  final Map<NetworkType, BlockchainBalanceService> _services = {};

  WalletBalanceService() {
    _services[NetworkType.ethereum] = EthereumBalanceService();
    _services[NetworkType.bitcoin] = BitcoinBalanceService();
  }

  Future<TokenBalance> getTokenBalance({
    required String address,
    required TokenInfo info,
    required NetworkType networkType,
  }) {
    return _services[networkType]!.getTokenBalance(
      address: address,
      info: info,
    );
  }

  Future<List<TokenBalance>> getAllTokenBalances({
    required String walletAddress,
    required NetworkType networkType,
  }) {
    return _services[networkType]!.getAllTokenBalances(
      walletAddress: walletAddress,
    );
  }

  void dispose() {
    for (var service in _services.values) {
      service.dispose();
    }
  }
}

/// -------------------
abstract class BlockchainBalanceService {
  Future<TokenBalance> getTokenBalance({
    required String address,
    required TokenInfo info,
  });

  Future<List<TokenBalance>> getAllTokenBalances({
    required String walletAddress,
  });

  void dispose();
}

class EthereumBalanceService implements BlockchainBalanceService {
  final Web3Client web3client;

  EthereumBalanceService()
      : web3client = Web3Client(WalletConfig().rpcUrl, http.Client());

  _hexToAddress(String address) {
    return EthereumAddress.fromHex(address);
  }

  /// 특정 토큰 1개의 잔액 조회
  @override
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
  @override
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

class BitcoinBalanceService implements BlockchainBalanceService {
  final String _apiBaseUrl;
  final http.Client _httpClient;

  BitcoinBalanceService({String? apiBaseUrl})
      : _apiBaseUrl = apiBaseUrl ?? WalletConfig().bitcoinApiUrl,
        _httpClient = http.Client();

  @override
  Future<TokenBalance> getTokenBalance({
    required String address,
    required TokenInfo info,
  }) async {
    try {
      // BTC는 네이티브 토큰이므로 기본적으로 처리
      if (info.symbol == "BTC") {
        final response = await _httpClient.get(
          Uri.parse('$_apiBaseUrl/addrs/$address'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode != 200) {
          throw Exception(
              'Failed to fetch Bitcoin balance: ${response.statusCode}');
        }

        final data = json.decode(response.body);

        // API 응답에서 잔액 추출 (satoshi 단위로 가정)
        final int satoshiBalance = data['balance'] ?? 0;
        // final_balance 는 미확정까지 포함

        // satoshi를 BTC로 변환 (1 BTC = 100,000,000 satoshi)
        final double btcBalance = satoshiBalance / 100000000;

        return TokenBalance(
          address: address,
          info: info,
          balance: btcBalance,
        );
      }
      // BTC 기반 토큰 (예: Omni Layer 토큰, Liquid 자산 등) - 필요하다면 확장
      else {
        throw Exception('${info.symbol} is not supported on Bitcoin network');
      }
    } catch (e) {
      debugPrint('Error getting Bitcoin balance: $e');
      throw Exception('Failed to get Bitcoin balance: $e');
    }
  }

  @override
  Future<List<TokenBalance>> getAllTokenBalances({
    required String walletAddress,
  }) async {
    try {
      // BTC만 가져오는 방식으로 간소화
      final TokenInfo btcInfo = TokenData.bitToken;

      final btcBalance = await getTokenBalance(
        address: walletAddress,
        info: btcInfo,
      );

      return [btcBalance];

      // 나중에 Omni USDT 등이 필요하면 추가할 수 있음
    } catch (e) {
      debugPrint('Error getting Bitcoin balance: $e');
      throw Exception('Failed to get Bitcoin balance');
    }
  }

  /// UTXO(미사용 트랜잭션 출력) 목록 가져오기
  /// 필요할 경우 사용
  Future<List<Map<String, dynamic>>> getUTXOs(String address) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_apiBaseUrl/address/$address/utxo'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch Bitcoin UTXOs: ${response.statusCode}');
      }

      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Error getting Bitcoin UTXOs: $e');
      throw Exception('Failed to get Bitcoin UTXOs: $e');
    }
  }

  /// 트랜잭션 상세 조회
  /// 필요할 경우 사용
  Future<Map<String, dynamic>> getTransaction(String txid) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_apiBaseUrl/tx/$txid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch transaction: ${response.statusCode}');
      }

      return json.decode(response.body);
    } catch (e) {
      debugPrint('Error getting transaction: $e');
      throw Exception('Failed to get transaction: $e');
    }
  }

  @override
  void dispose() {
    _httpClient.close();
  }
}
