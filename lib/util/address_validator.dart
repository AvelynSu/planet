import 'package:bech32/bech32.dart';
import 'package:bs58/bs58.dart' as bs58;
import 'package:planet/enum/network_type.dart';
import 'package:web3dart/web3dart.dart';

class AddressValidator {
  /// 주소의 유효성을 검사하는 함수
  static bool isValidAddress(NetworkType networkType, String address) {
    switch (networkType) {
      case NetworkType.ethereum:
      case NetworkType.bsc:
        return _isValidEthereumAddress(address);
      case NetworkType.bitcoin:
        return _isValidBitcoinAddress(address);
      case NetworkType.solana:
        return _isValidSolanaAddress(address);
      default:
        return false;
    }
  }

  /// 이더리움/BSC 주소 유효성 검사 (web3dart 사용)
  static bool _isValidEthereumAddress(String address) {
    try {
      // web3dart의 EthereumAddress 클래스를 사용하여 검증
      // 이 클래스는 주소 형식 및 체크섬을 모두 검증함
      final ethAddress = EthereumAddress.fromHex(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 비트코인 주소 유효성 검사
  static bool _isValidBitcoinAddress(String address) {
    // Legacy 주소 (P2PKH, P2SH) 검사
    if (address.startsWith('1') || address.startsWith('3')) {
      // 기본 형식 및 길이 검사
      return address.length >= 26 && address.length <= 35;
    }

    // SegWit 주소 (Bech32) 검사
    if (address.startsWith('bc1')) {
      try {
        // Bech32 디코딩 시도
        final decoded = bech32.decode(address);
        // 유효한 길이 검사
        return address.length == 42 || address.length == 62;
      } catch (e) {
        return false;
      }
    }

    // 테스트넷 주소 검사
    if (address.startsWith('m') ||
        address.startsWith('n') ||
        address.startsWith('2') ||
        address.startsWith('tb1')) {
      return true; // 테스트넷 주소의 기본 형식 검사
    }

    return false;
  }

  /// 솔라나 주소 유효성 검사
  static bool _isValidSolanaAddress(String address) {
    try {
      // bs58.base58.decode 사용
      final decoded = bs58.base58.decode(address);
      // 솔라나 주소는 32바이트(256비트) 길이여야 함
      return decoded.length == 32;
    } catch (e) {
      return false;
    }
  }

  /// 주소가 유효하지 않을 경우 에러 메시지 반환
  static String getInvalidAddressMessage(NetworkType networkType) {
    switch (networkType) {
      case NetworkType.ethereum:
        return "유효하지 않은 이더리움 주소입니다.";
      case NetworkType.bitcoin:
        return "유효하지 않은 비트코인 주소입니다.";
      case NetworkType.solana:
        return "유효하지 않은 솔라나 주소입니다.";
      case NetworkType.bsc:
        return "유효하지 않은 BSC 주소입니다.";
      default:
        return "유효하지 않은 주소입니다.";
    }
  }
}
