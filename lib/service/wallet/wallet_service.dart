import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:convert/convert.dart' show hex;
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:flutter_bitcoin/flutter_bitcoin.dart' as btc;
import 'package:planet/model/custom_exception.dart';
import 'package:planet/util/app_util.dart';
import 'package:planet/util/data/token_data.dart';
import 'package:solana/solana.dart' as sol;
import 'package:solana/solana.dart';

import '../../enum/network_type.dart';
import '../../util/wallet_config.dart';

// 지갑을 만들때 사용하는 클레스
class WalletService {
  /// 니모닉 생성
  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  /// 지갑 주소 생성
  Future<String> generateHDAddress(
      NetworkType network, String mnemonic, int index) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw const CustomException(errType: ExceptionType.invalidMnemonicPhrase);
    }

    // 니모닉으로부터 시드 생성
    final seed = bip39.mnemonicToSeed(mnemonic);
    // index 로 경로 생성
    final derivationPath = network.getDerivationPath(index);

    switch (network) {
      case NetworkType.ethereum:
        return _generateEthereumAddress(seed, derivationPath);
      case NetworkType.bitcoin:
        return _generateBitcoinAddress(seed, derivationPath);
      case NetworkType.solana:
        return _generateSolanaAddress(seed, derivationPath);
    }
  }

  Future<String> getPrivateKeyFromMnemonic(
    String mnemonic,
    NetworkType type,
    int idx,
  ) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw const CustomException(errType: ExceptionType.invalidMnemonicPhrase);
    }

    final seed = bip39.mnemonicToSeed(mnemonic);
    final path = type.getDerivationPath(idx);

    switch (type) {
      case NetworkType.solana:
        final keyData = await ED25519_HD_KEY.derivePath(path, seed);
        return AppUtil.bytesToHex(Uint8List.fromList(keyData.key));
      case NetworkType.bitcoin:
        final node = bip32.BIP32.fromSeed(seed);
        final child = node.derivePath(path);
        return AppUtil.bytesToHex(child.privateKey!);
      case NetworkType.ethereum:
        final node = bip32.BIP32.fromSeed(seed);
        final child = node.derivePath(path);
        final privateKeyHex = AppUtil.bytesToHex(child.privateKey!);
        return "0x$privateKeyHex";
    }
  }

  /// 개인키로부터 키페어 생성
  static Future<sol.Ed25519HDKeyPair> getSolKeyPairByPrivacyKey(
      String privateKey) async {
    try {
      final privateKeyBytes = Uint8List.fromList(hex.decode(privateKey));
      return await sol.Ed25519HDKeyPair.fromPrivateKeyBytes(
        privateKey: privateKeyBytes,
      );
    } catch (e) {
      throw CustomException(errMsg: '개인키 형식이 잘못되었습니다: $e');
    }
  }

  /// 개인키로부터 주소 생성 메서드
  static String getBtcAddressFromPrivateKey(String privateKey) {
    final keyPair =
        btc.ECPair.fromPrivateKey(AppUtil.hexToUint8List(privateKey));
    final network = WalletConfig.env == Environment.prod
        ? btc.bitcoin
        : TokenData.btcTestNet;
    return btc
            .P2PKH(
              data: btc.PaymentData(pubkey: keyPair.publicKey),
              network: network,
            )
            .data
            .address ??
        "";
  }

  /// 주소 생성 ----------------------------------------------------------------------

  /// 이더리움 주소 생성
  Future<String> _generateEthereumAddress(Uint8List seed, String path) async {
    final bip32.BIP32 node = bip32.BIP32.fromSeed(seed);
    final child = node.derivePath(path);

    final uIntToPrivateKey = AppUtil.bytesToHex(child.privateKey!);
    final privateKey = AppUtil.getEthCredentials(uIntToPrivateKey);
    final address = privateKey.address;

    return address.hex;
  }

  /// 비트코인 주소 생성
  Future<String> _generateBitcoinAddress(Uint8List seed, String path) async {
    // HD 지갑에서 키 유도
    final node = bip32.BIP32.fromSeed(seed);
    final child = node.derivePath(path);

    // 환경에 따라 네트워크 선택
    final network = WalletConfig.env == Environment.prod
        ? btc.bitcoin
        : TokenData.btcTestNet;

    // 주소 생성
    final address = btc
        .P2PKH(data: btc.PaymentData(pubkey: child.publicKey), network: network)
        .data
        .address;

    return address ?? "";
  }

  // 솔라나 주소 생성
  Future<String> _generateSolanaAddress(Uint8List seed, String path) async {
    final keyData = await ED25519_HD_KEY.derivePath(path, seed);
    final keyPair =
        await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: keyData.key);
    return keyPair.address;
  }
}
