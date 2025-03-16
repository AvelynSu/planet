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
  final String wsUrl;
  final String alchemyApiKey;
  final int chainId;
  final String bitcoinApiUrl;
  final String blockCypherToken;
  final String solanaRpcUrl;
  static final WalletConfig _instance = WalletConfig._internal();

  factory WalletConfig() => _instance;

  WalletConfig._internal()
      : ethRpcUrl = env == Environment.prod
            ? 'https://eth-mainnet.g.alchemy.com/v2/AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI'
            : 'https://eth-mainnet.g.alchemy.com/v2/AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI',
        wsUrl = env == Environment.prod
            ? 'wss://eth-mainnet.g.alchemy.com/v2/AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI'
            : 'wss://eth-mainnet.g.alchemy.com/v2/AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI',
        alchemyApiKey = 'AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI',
        chainId = env == Environment.prod ? 1 : 1,
        bitcoinApiUrl = env == Environment.prod
            ? "https://api.blockcypher.com/v1/btc/main"
            : "https://api.blockcypher.com/v1/bcy/test",
        blockCypherToken = env == Environment.prod
            ? "b0bce5d62dba4e308ec307c1f9b92f78"
            : "b0bce5d62dba4e308ec307c1f9b92f78",
        solanaRpcUrl = env == Environment.prod
            ? "https://solana-mainnet.g.alchemy.com/v2/AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI"
            : "https://solana-mainnet.g.alchemy.com/v2/AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI";

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

  // 블록체인 타입에 따른 WebSocket URL을 반환하는 헬퍼 메서드
  String getWsUrlForNetwork(String networkType) {
    switch (networkType.toLowerCase()) {
      case "ethereum":
        return wsUrl;
      case "solana":
        return solanaRpcUrl.replaceFirst('https://', 'wss://');
      default:
        return wsUrl;
    }
  }
}
