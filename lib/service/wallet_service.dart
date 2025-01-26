import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class WalletService {
  // 니모닉 생성
  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  // 니모닉으로부터 시드 생성
  Uint8List mnemonicToSeed(String mnemonic) {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception("Invalid mnemonic phrase");
    }
    return bip39.mnemonicToSeed(mnemonic);
  }

  // 시드 -> 개인키
  EthPrivateKey seedToPrivateKey(Uint8List seed) {
    return EthPrivateKey.fromHex(bytesToHex(seed));
  }

  // 개인키 -> 공개키
  String privateKeyToPublicKey(EthPrivateKey privateKey) {
    final publicKeyBytes = privateKey.publicKey.getEncoded();

    // 1바이트를 제거하고 마지막 64바이트만 사용 (앞의 1바이트(압축 여부를 나타내는 값) 제거)
    final publicKey = bytesToHex(publicKeyBytes.sublist(1));
    return publicKey;
  }

  // 공개키 -> 지갑 주소
  String publicKeyToAddress(String publicKey) {
    final publicKeyBytes = hexToBytes(publicKey);
    final address =
        bytesToHex(keccak256(publicKeyBytes).sublist(12), include0x: true);
    return address;
  }
}
