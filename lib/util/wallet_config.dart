import 'package:planet/enum/network_type.dart';

enum Environment {
  dev,
  prod;

  factory Environment.fromJson(String? item) {
    switch (item) {
      case "dev":
        return dev;
      case "prod":
        return prod;
    }
    return prod;
  }
}

class WalletConfig {
  static Environment env = Environment.prod;

  final String ethRpcUrl;
  final String bitcoinApiUrl;
  final String blockCypherToken;
  final String solanaRpcUrl;
  final String bscRpcUrl;

  WalletConfig({
    this.ethRpcUrl = "",
    this.bitcoinApiUrl = "",
    this.blockCypherToken = "",
    this.solanaRpcUrl = "",
    this.bscRpcUrl = "",
  });

  static WalletConfig config = WalletConfig();

  factory WalletConfig.fromJson(Map<String, dynamic> json) {
    return WalletConfig(
      ethRpcUrl: json['ethRpcUrl'] ?? '',
      bscRpcUrl: json['bscRpcUrl'] ?? '',
      bitcoinApiUrl: json['bitcoinApiUrl'] ?? '',
      blockCypherToken: json['blockCypherToken'] ?? '',
      solanaRpcUrl: json['solanaRpcUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ethRpcUrl': ethRpcUrl,
      'bscRpcUrl': bscRpcUrl,
      'bitcoinApiUrl': bitcoinApiUrl,
      'blockCypherToken': blockCypherToken,
      'solanaRpcUrl': solanaRpcUrl,
    };
  }

  // 블록체인 타입에 따른 RPC URL을 반환하는 헬퍼 메서드
  String getRpcUrlForNetwork(String networkType) {
    switch (networkType.toLowerCase()) {
      case "ethereum":
        return ethRpcUrl;
      case "solana":
        return solanaRpcUrl;
      default:
        return ethRpcUrl;
    }
  }

  int? chainId(NetworkType type) {
    switch (type) {
      case NetworkType.ethereum:
        return env == Environment.prod ? 1 : 5; // 메인넷: 1, Goerli 테스트넷: 5
      case NetworkType.bitcoin:
        return env == Environment.prod ? 0 : 1; // 메인넷: 0, 테스트넷: 1
      case NetworkType.solana:
        return env == Environment.prod ? 101 : 103; // 메인넷: 101, 테스트넷: 103
      case NetworkType.bsc:
        return env == Environment.prod ? 56 : 97; // 메인넷: 56, 테스트넷: 97
    }
  }

  // 블록체인 타입에 따른 WebSocket URL을 반환하는 헬퍼 메서드 (sol만 필요함)
  String getWsUrlForNetwork(String networkType) {
    switch (networkType.toLowerCase()) {
      case "ethereum":
        return "";
      case "solana":
        return solanaRpcUrl.replaceFirst('https://', 'wss://');
      default:
        return "";
    }
  }
}
