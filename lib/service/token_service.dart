import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import '../model/token_info.dart';

class TokenService {
  final Web3Client web3client;

  TokenService({
    required String rpcUrl, // 이더리움 노드 RPC URL
  }) : web3client = Web3Client(rpcUrl, http.Client());

  // 거래내역이 있는 월렛 가져오기
  Future<List<TokenInfo>> getWalletTokens(String walletAddress) async {
    const apiKey = '1YJEHHTZGD5I3I8IMI4TG8AJD8Z6NCGABF';
    final url = 'https://api.etherscan.io/api' +
        '?module=account' +
        '&action=tokentx' /* 토큰 거래 내역*/ +
        '&address=$walletAddress' +
        '&apikey=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    // 중복 제거를 위한 Set
    final Set<String> tokenAddresses = {};

    // 거래 내역에서 토큰 주소 추출
    for (var tx in data['result']) {
      tokenAddresses.add(tx['contractAddress']);
    }

    // 각 토큰의 정보 조회
    List<TokenInfo> tokens = [];
    for (var address in tokenAddresses) {
      tokens.add(await getTokenInfo(address));
    }

    return tokens;
  }

  Future<TokenInfo> getTokenInfo(String contractAddress) async {
    // ERC-20 토큰 기본 ABI (symbol, name, decimals 함수 포함)
    const String erc20Abi = '''[
    {
      "constant": true,
      "inputs": [],
      "name": "symbol",
      "outputs": [{"name": "", "type": "string"}],
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "name",
      "outputs": [{"name": "", "type": "string"}],
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "decimals",
      "outputs": [{"name": "", "type": "uint8"}],
      "type": "function"
    }
  ]''';

    try {
      // 컨트랙트 인스턴스 생성
      final contract = DeployedContract(
        ContractAbi.fromJson(erc20Abi, 'ERC20'),
        EthereumAddress.fromHex(contractAddress),
      );

      // symbol 조회
      final symbolResult = await web3client.call(
        contract: contract,
        function: contract.function('symbol'),
        params: [],
      );

      // name 조회
      final nameResult = await web3client.call(
        contract: contract,
        function: contract.function('name'),
        params: [],
      );

      // decimals 조회
      final decimalsResult = await web3client.call(
        contract: contract,
        function: contract.function('decimals'),
        params: [],
      );

      // BigInt를 int로 변환
      final decimals = (decimalsResult.first as BigInt).toInt();

      return TokenInfo(
        symbol: symbolResult.first.toString(),
        name: nameResult.first.toString(),
        address: contractAddress,
        decimals: decimals,
      );
    } catch (e) {
      print('Error getting token info: $e');
      throw Exception('Failed to get token info');
    }
  }

  void dispose() {
    web3client.dispose();
  }
}
