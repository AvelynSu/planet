import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../enum/network_type.dart';

class HDWalletService {
  // 니모닉 생성
  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  Future<String> generateHDAddress(
      NetworkType network, String mnemonic, int index) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception("Invalid mnemonic phrase");
    }

    // 니모닉으로부터 시드 생성
    final seed = bip39.mnemonicToSeed(mnemonic);
    // index 로 경로 생성
    final path = network.getDerivationPath(index);

    switch (network) {
      case NetworkType.ethereum:
        return _generateEthereumAddress(seed, path);
      case NetworkType.bitcoin:
        return _generateBitcoinAddress(seed, path);
      case NetworkType.solana:
        return _generateSolanaAddress(seed, path);
    }
  }

  // 이더리움 주소 생성
  Future<String> _generateEthereumAddress(Uint8List seed, String path) async {
    // 2-1. seed로부터 HD 노드 생성 (seed -> master)
    final bip32.BIP32 node = bip32.BIP32.fromSeed(seed);
    // 2-2. 경로에 따른 자식 키 생성 (master -> child)
    final child = node.derivePath(path);

    // 2. 프라이빗 키 생성 : Uint8List를 hex string으로 변환 후 private key 생성
    final privateKey = EthPrivateKey.fromHex(bytesToHex(child.privateKey!));

    // 3. 공개키 생성 (이 과정은 EthPrivateKey 클래스 내부에서 자동으로 처리됨)
    // privateKey.publicKey

    // 4. 주소 생성 (공개키로부터 - 이것도 내부적으로 처리됨)
    final address = privateKey.address;

    return address.hex;
  }

  // 비트코인 주소 생성
  Future<String> _generateBitcoinAddress(Uint8List seed, String path) async {
    return "";
  }

  // 솔라나 주소 생성
  Future<String> _generateSolanaAddress(Uint8List seed, String path) async {
    return "";
  }

// 1 니모닉 -> 시드
// 2 시드 -> 개인키 (hd: seed -> master node -> child node -> private key)
// 3 개인키 -> 공개키
// 4 공개키 -> 지갑 주소
}
