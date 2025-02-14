enum _Environment { dev, prod }

class WalletConfig {
  static _Environment _env = _Environment.prod;

  final String rpcUrl;
  final int chainId; // 1: mainnet, 5: goerli testnet
  final String etherscanApiKey;

  static final WalletConfig _instance = WalletConfig._internal();

  factory WalletConfig() => _instance;

  WalletConfig._internal()
      : rpcUrl = _env == _Environment.prod
            ? 'https://mainnet.infura.io/v3/e2e92d65ad42465e880c01edc6969cba'
            : "",
        chainId = _env == _Environment.prod ? 1 : 5,
        etherscanApiKey = _env == _Environment.prod
            ? '1YJEHHTZGD5I3I8IMI4TG8AJD8Z6NCGABF'
            : "";
}
