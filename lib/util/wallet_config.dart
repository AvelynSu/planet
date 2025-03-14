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

  final String rpcUrl;
  final String alchemyApiKey; // Alchemy API 키 추가
  final int chainId;
  final String etherscanApiKey;
  final String bitcoinApiUrl;
  final String blockCypherToken;
  final String etherscanApiUrl;
  static final WalletConfig _instance = WalletConfig._internal();

  factory WalletConfig() => _instance;

  WalletConfig._internal()
      : rpcUrl = env == Environment.prod
            ? 'https://eth-mainnet.g.alchemy.com/v2/AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI'
            : 'https://eth-mainnet.g.alchemy.com/v2/AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI',
        alchemyApiKey = 'AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI',
        chainId = env == Environment.prod ? 1 : 1,
        bitcoinApiUrl = env == Environment.prod
            ? "https://api.blockcypher.com/v1/btc/main"
            : "https://api.blockcypher.com/v1/bcy/test",
        blockCypherToken = env == Environment.prod
            ? "b0bce5d62dba4e308ec307c1f9b92f78"
            : "b0bce5d62dba4e308ec307c1f9b92f78",
        etherscanApiKey = env == Environment.prod
            ? '1YJEHHTZGD5I3I8IMI4TG8AJD8Z6NCGABF'
            : "1YJEHHTZGD5I3I8IMI4TG8AJD8Z6NCGABF",
        etherscanApiUrl =
            env == Environment.prod ? "api.etherscan.io" : "api.etherscan.io";
}
