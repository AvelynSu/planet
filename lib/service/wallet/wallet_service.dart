import 'dart:convert';
import 'dart:typed_data';

import 'package:base58check/base58check.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:crypto/crypto.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:planet/model/custom_exception.dart';
import 'package:planet/ui/util/wallet_config.dart';
import 'package:solana/solana.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../../enum/network_type.dart';
import '../../model/planet_dto.dart';

// 지갑을 만들고, 복구할때 사용하는 서비스
class WalletService {
  // 니모닉 생성
  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  Future<String> generateHDAddress(
      NetworkType network, String mnemonic, int index) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw const CustomException(errType: ExceptionType.invalidMnemonicPhrase);
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

  Future<Credentials> getCredentialsFromMnemonic(
    String mnemonic,
    NetworkType type,
    int idx,
  ) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw const CustomException(errType: ExceptionType.invalidMnemonicPhrase);
    }

    // 니모닉으로부터 시드 생성
    final seed = bip39.mnemonicToSeed(mnemonic);

    // 이더리움 경로 (첫 번째 계정 - index 0)
    final path = "m/44'/60'/0'/0/$idx";

    // HD 노드 생성
    final bip32.BIP32 node = bip32.BIP32.fromSeed(seed);

    // 경로에 따른 자식 키 생성
    final child = node.derivePath(path);

    // 프라이빗 키 생성
    final privateKey = EthPrivateKey.fromHex(bytesToHex(child.privateKey!));

    return privateKey;
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
    final path = "m/44'/60'/0'/0/$idx";
    final node = bip32.BIP32.fromSeed(seed);
    final child = node.derivePath(path);

    // private key를 16진수 문자열로 변환
    final privateKeyHex = bytesToHex(child.privateKey!);

    // 0x 접두사 추가 (선택사항)
    return "0x$privateKeyHex";
  }

  /// 주소 생성 ----------------------------------------------------------------------

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
    // 2-1. seed로부터 HD 노드 생성 (seed -> master)
    final node = bip32.BIP32.fromSeed(seed);
    // 2-2. 경로에 따른 자식 키 생성 (master -> child)
    final child = node.derivePath(path);

    // 3. 개인키 -> 공개키 (child.publicKey가 공개키)
    // 4. 공개키 -> 지갑 주소
    // 4-1. 공개키 해시 생성 (RIPEMD160(SHA256(공개키)))
    final publicKeyHash = _hash160(child.publicKey);

    // 4-2. Base58Check 인코딩으로 최종 주소 생성
    const version = 0x00; // mainnet P2PKH address version
    final payload = Base58CheckPayload(version, publicKeyHash);
    final codec = Base58CheckCodec.bitcoin();
    final address = codec.encode(payload);

    return address;
  }

  // RIPEMD160(SHA256(input)) 해시 생성
  List<int> _hash160(Uint8List input) {
    final sha256Hash = sha256.convert(input).bytes;
    final hash160 = sha256.convert(sha256Hash).bytes;
    return hash160.sublist(0, 20); // 앞의 20바이트만 사용
  }

  // 솔라나 주소 생성
  Future<String> _generateSolanaAddress(Uint8List seed, String path) async {
    // 1. 니모닉 -> 시드 (이미 파라미터로 받음)

    // 2. 시드 -> 개인키 (HD 월렛: seed -> master node -> child node -> private key)
    final keyData = await ED25519_HD_KEY.derivePath(path, seed);

    // 3. 개인키 -> 공개키 & 4. 공개키 -> 지갑 주소
    // Ed25519HDKeyPair가 개인키로부터 공개키를 생성하고, 이를 솔라나 주소 형식으로 변환
    final keyPair = await Ed25519HDKeyPair.fromPrivateKeyBytes(
      privateKey: keyData.key,
    );

    return keyPair.address;
  }

// 1 니모닉 -> 시드
// 2 시드 -> 개인키 (hd: seed -> master node -> child node -> private key)
// 3 개인키 -> 공개키
// 4 공개키 -> 지갑 주소

  /// 주소 복구 ----------------------------------------------------------------------
// HD 월렛의 주소 복구 기능
// - 하나의 니모닉에서 여러 개의 주소가 생성될 수 있음
// - 생성된 주소들 중 실제 사용된 주소를 찾아내는 과정
  Future<List<PlanetDto>> recoverAddresses(
    NetworkType network,
    String mnemonic,
    int testLastIdx, // 지갑 생성/복구 테스트용 라스트 인덱스 넣기
  ) async {
    List<PlanetDto> foundPlanets = [];

    for (var i = 0; i < testLastIdx; i++) {
      final address = await generateHDAddress(network, mnemonic, i);
      foundPlanets.add(PlanetDto(
        id: "",
        networkType: network,
        name: "",
        address: address,
        mnemonic: mnemonic,
      ));
    }

    // int emptyAddressCount = 0; // 연속으로 발견된 빈 주소의 수
    // int index = 0; // 주소 생성 인덱스
    // // 연속으로 20개의 빈 주소가 나올 때까지 주소 탐색
    // // - HD 월렛 표준에서 권장하는 방식
    // // - 사용자가 20개의 주소를 건너뛰고 사용할 가능성은 매우 낮다고 가정 (HD월렛 관행)
    // while (emptyAddressCount < 20) {
    //   // 현재 인덱스로 주소 생성
    //   final address = await generateHDAddress(network, mnemonic, index);
    //
    //   // 생성된 주소의 블록체인 활동 내역 확인
    //   // - 잔액이 있거나
    //   // - 트랜잭션 내역이 있는 경우
    //   final hasActivity = await checkAddressActivity(network, address);
    //
    //   if (hasActivity) {
    //     foundAddresses.add(address); // 활동 내역이 있는 주소 저장
    //     emptyAddressCount = 0; // 빈 주소 카운터 리셋
    //   } else {
    //     emptyAddressCount++; // 빈 주소 카운트 증가
    //   }
    //
    //   index++; // 다음 인덱스로 이동
    // }

    // 발견된 모든 활성 주소 반환
    return foundPlanets;
  }

  // 블록체인 상태 확인
  Future<bool> checkAddressActivity(NetworkType network, String address) async {
    switch (network) {
      case NetworkType.ethereum:
        return _checkEthereumActivity(address);
      case NetworkType.bitcoin:
        return _checkBitcoinActivity(address);
      case NetworkType.solana:
        return _checkSolanaActivity(address);
    }
  }

  // 이더리움 활동 확인
  Future<bool> _checkEthereumActivity(String address) async {
    // Web3Client 설정 필요
    final client = Web3Client(WalletConfig().rpcUrl, http.Client());

    try {
      // 잔액 확인
      final balance = await client.getBalance(EthereumAddress.fromHex(address));
      // 트랜잭션 수 확인
      final transactionCount =
          await client.getTransactionCount(EthereumAddress.fromHex(address));

      return balance.getInWei > BigInt.zero || transactionCount > 0;
    } catch (e) {
      debugPrint('Error checking Ethereum activity: $e');
      return false;
    } finally {
      client.dispose();
    }
  }

  // 비트코인 활동 확인
  Future<bool> _checkBitcoinActivity(String address) async {
    try {
      // Blockstream API 사용
      final response = await http
          .get(Uri.parse('https://blockstream.info/api/address/$address'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // chain_stats.tx_count로 트랜잭션 수 확인
        return data['chain_stats']['tx_count'] > 0;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking Bitcoin activity: $e');
      return false;
    }
  }

  // 솔라나 활동 확인
  Future<bool> _checkSolanaActivity(String address) async {
    try {
      final client = SolanaClient(
        rpcUrl: Uri.parse('YOUR_SOLANA_RPC_URL'),
        websocketUrl: Uri.parse('YOUR_SOLANA_WS_URL'),
      );

      final balance = await client.rpcClient.getBalance(address);
      final transactions =
          await client.rpcClient.getSignaturesForAddress(address);

      return balance.value > 0 || transactions.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking Solana activity: $e');
      return false;
    }
  }
}
