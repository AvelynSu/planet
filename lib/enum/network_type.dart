enum NetworkType {
  ethereum,
  bitcoin,
  solana;

  String get coinType {
    switch (this) {
      case NetworkType.ethereum:
        return "60";
      case NetworkType.bitcoin:
        return "0";
      case NetworkType.solana:
        return "501";
    }
  }

  factory NetworkType.fromJson(String key) {
    switch (key) {
      case "ethereum":
        return NetworkType.ethereum;
      case "bitcoin":
        return NetworkType.bitcoin;
      case "solana":
        return NetworkType.solana;
    }
    return NetworkType.ethereum;
  }

  String get symbol {
    switch (this) {
      case NetworkType.ethereum:
        return "ETH";
      case NetworkType.bitcoin:
        return "BTC";
      case NetworkType.solana:
        return "SOL";
    }
  }

  String get title {
    switch (this) {
      case NetworkType.ethereum:
        return "ETHEREUM";
      case NetworkType.bitcoin:
        return "BITCOIN";
      case NetworkType.solana:
        return "SOLANA";
    }
  }

  String getDerivationPath(int addressIndex) {
    if (this == NetworkType.solana) {
      return "m/44'/$coinType'/0'/0'/$addressIndex'";
    } else {
      return "m/44'/$coinType'/0'/0/$addressIndex";
    }
  }

//  계층 구조: m/purpose'/coin_type'/account'/change/address_index
//  purpose: 보통 44를 사용 (BIP44 표준)
//  coin_type: 네트워크별 coinType 으로 미리 지정해둠
//  account: 사용자의 계정 번호 (우리는 특별히 유저구분 없으니까 일단은 모두 0으로)
//  change: external(0) 또는 internal(1) chain (internal 은 내부용인데.. 일단은 사용하지 않기로. 뭔지 모르겠음)
//  address_index: 주소의 인덱스
}
