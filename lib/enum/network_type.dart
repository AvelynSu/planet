import 'package:flutter/cupertino.dart';
import 'package:planet/l10n/app_localizations.dart';

import '../util/wallet_config.dart';

enum NetworkType {
  ethereum,
  bitcoin,
  solana,
  bsc;

  String get coinType {
    switch (this) {
      case NetworkType.ethereum:
        return "60";
      case NetworkType.bitcoin:
        // WalletConfig에서 환경 설정 확인
        final isMainnet = WalletConfig.env == Environment.prod;
        return isMainnet ? "0" : "1";
      case NetworkType.solana:
        return "501";
      case NetworkType.bsc:
        return "56";
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
      case "bsc":
        return NetworkType.bsc;
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
      case NetworkType.bsc:
        return "BNB";
    }
  }

  String get icon {
    switch (this) {
      case NetworkType.ethereum:
        return "icons/ic_ethereum.png";
      case NetworkType.bitcoin:
        return "icons/ic_bitcoin.png";
      case NetworkType.solana:
        return "icons/ic_solana.png";
      case NetworkType.bsc:
        return "icons/ic_bsc.png";
    }
  }

  String title(BuildContext context) {
    switch (this) {
      case NetworkType.ethereum:
        return AppLocalizations.of(context)!.ethereum;
      case NetworkType.bitcoin:
        return AppLocalizations.of(context)!.bitcoin;
      case NetworkType.solana:
        return AppLocalizations.of(context)!.solana;
      case NetworkType.bsc:
        return AppLocalizations.of(context)!.bnb_smart_chain;
    }
  }

  String getDerivationPath(int addressIndex) {
    int coinType;

    switch (this) {
      case NetworkType.solana:
        coinType = 501;
        return "m/44'/$coinType'/0'/0'/$addressIndex'";
      case NetworkType.ethereum:
        coinType = 60;
        return "m/44'/$coinType'/0'/0/$addressIndex";
      case NetworkType.bitcoin:
        coinType = WalletConfig.env == Environment.prod ? 0 : 1;
        return "m/44'/$coinType'/0'/0/$addressIndex";
      case NetworkType.bsc:
        coinType = 56;
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
