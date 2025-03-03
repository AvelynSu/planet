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
  static Environment env = Environment.dev; // 개발 환경으로 변경

  final String rpcUrl;
  final int chainId; // 1: mainnet, 5: goerli testnet
  final String etherscanApiKey;
  final String bitcoinApiUrl;
  final String blockCypherToken;
  final String etherscanApiUrl;
  static final WalletConfig _instance = WalletConfig._internal();

  factory WalletConfig() => _instance;

  WalletConfig._internal()
      : rpcUrl = env == Environment.prod
            ? 'https://mainnet.infura.io/v3/e2e92d65ad42465e880c01edc6969cba'
            : "https://mainnet.infura.io/v3/e2e92d65ad42465e880c01edc6969cba",
        // Goerli 테스트넷
        chainId = env == Environment.prod ? 1 : 1,
        // Goerli는 chainId 5
        bitcoinApiUrl = env == Environment.prod
            ? "https://api.blockcypher.com/v1/btc/main"
            : "https://api.blockcypher.com/v1/bcy/test",
        blockCypherToken = env == Environment.prod
            ? "b0bce5d62dba4e308ec307c1f9b92f78"
            : "b0bce5d62dba4e308ec307c1f9b92f78",
        // 이더스캔 키
        etherscanApiKey = env == Environment.prod
            ? '1YJEHHTZGD5I3I8IMI4TG8AJD8Z6NCGABF'
            : "1YJEHHTZGD5I3I8IMI4TG8AJD8Z6NCGABF",
        etherscanApiUrl =
            env == Environment.prod ? "api.etherscan.io" : "api.etherscan.io";
}
