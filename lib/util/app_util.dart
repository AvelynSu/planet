import 'dart:math';
import 'dart:typed_data';

import 'package:planet/enum/network_type.dart';
import 'package:planet/util/app_constant.dart';
import 'package:web3dart/credentials.dart';

import '../enum/gas_priority.dart';
import '../service/local_storage_service.dart';
import 'data/planet_name_data.dart';

class AppUtil {
  static Uint8List hexToUint8List(String hex) {
    // 16진수 문자열에서 '0x' 접두사 제거
    hex = hex.replaceFirst('0x', '');

    // 홀수 길이일 경우 앞에 0 추가
    if (hex.length % 2 != 0) {
      hex = '0$hex';
    }

    return Uint8List.fromList(List.generate(hex.length ~/ 2,
        (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)));
  }

  // 가스 우선순위별 비율 상수 정의 (비트코인에서는 수수료 우선순위)
  static Map<GasPriority, double> feePriority(NetworkType type) {
    switch (type) {
      case NetworkType.ethereum:
        return {
          GasPriority.slow: 0.8, // 80%
          GasPriority.medium: 1.0, // 100%
          GasPriority.fast: 1.2, // 120%
        };
      case NetworkType.bitcoin:
        return {
          GasPriority.slow: 0.5, // 50% - 경제적
          GasPriority.medium: 1.0, // 100% - 표준
          GasPriority.fast: 2.0, // 200% - 빠름
        };
      case NetworkType.solana:
        // 고정됨
        return {
          GasPriority.slow: 1, // 기본
          GasPriority.medium: 1, // 중간
          GasPriority.fast: 2, // 빠름
        };
      case NetworkType.bsc:
        return {
          GasPriority.slow: 0.5, // 50% - 경제적
          GasPriority.medium: 1.0, // 100% - 표준
          GasPriority.fast: 2.0, // 200% - 빠름
        };
    }
  }

  static String bytesToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  static Credentials getEthCredentials(String privateKey) {
    return EthPrivateKey.fromHex(privateKey);
  }

  /// double 배율을 BigInt에 안전하게 적용하는 헬퍼 메서드
  static BigInt adjustFeeByPercentage(BigInt basePrice, double percentage) {
    final scaledMultiplier = (percentage * 100).round();
    return basePrice * BigInt.from(scaledMultiplier) ~/ BigInt.from(100);
  }

  /// BigInt 값을 decimals를 고려하여 double로 변환 // ex 1000000000000000000,18 -> 1.0
  static double bigIntToDecimal(BigInt value, int decimals) {
    final divisor = BigInt.from(10).pow(decimals);
    final wholeNumber = value ~/ divisor;
    final fraction = value % divisor;
    final fractionalPart = fraction.toDouble() / divisor.toDouble();
    return wholeNumber.toDouble() + fractionalPart;
  }

  static EthereumAddress hexToEthereumAddress(String address) {
    if (!isValidEthereumAddress(address)) {
      throw Exception('Invalid Ethereum address format');
    }
    return EthereumAddress.fromHex(address);
  }

  static String tokenToCurrency(double tokenPrice) {
    String curreny = SharedPrefsUtil.getString(AppConstant.currency) ?? "usd";
    curreny = curreny.toLowerCase();
    if (curreny == "krw") {
      return "${(AppUtil.formatNumberWithComma(tokenPrice.round()))} 원";
    } else if (curreny == "usd") {
      return "\$${tokenPrice.toStringAsFixed(2)}";
    }
    return "";
  }

  static bool isUpdateRequired(String currentVersion, String latestVersion) {
    // 버전 문자열에서 숫자 부분만 추출
    List<int> currentParts = currentVersion
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();

    List<int> latestParts = latestVersion
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();

    // 각 버전 부분의 길이를 맞춤
    while (currentParts.length < latestParts.length) {
      currentParts.add(0);
    }

    while (latestParts.length < currentParts.length) {
      latestParts.add(0);
    }

    // 버전 비교
    for (int i = 0; i < currentParts.length; i++) {
      if (latestParts[i] > currentParts[i]) {
        return true; // 업데이트 필요
      } else if (latestParts[i] < currentParts[i]) {
        return false; // 현재 버전이 더 높음
      }
    }

    return false; // 버전이 동일함
  }

  static String getRandomNickname(List<String> alreadyNickname) {
    var planet =
        Data.planetNames[Random().nextInt(Data.planetNames.length - 1)];
    planet = planet.replaceAll(" ", "").toLowerCase();
    var idx = Random().nextInt(10000);

    // fb에 없는 이름 나올때까지 생성
    while (!alreadyNickname.contains("$planet$idx")) {
      idx = Random().nextInt(10000);
      break;
    }

    return "$planet$idx";
  }

  /// Wei 단위를 ETH 단위로 변환 (1 ETH = 10^18 Wei)
  static double weiToEth(BigInt wei, {int decimals = 18}) {
    return bigIntToDecimal(wei, decimals);
  }

  static double lamportsToSol(int lamports, int decimals) {
    final divisor = pow(10, decimals).toInt();
    return lamports / divisor;
  }

  /// satoshi를 BTC로 변환
  static double satoshiToBtc(int satoshi) {
    const int _SATOSHI_PER_BTC = 100000000; // 8 decimals for BTC
    return satoshi / _SATOSHI_PER_BTC;
  }

  // wei or satoshi
  static BigInt valueToRaw(String amount, NetworkType network,
      {int? tokenDecimals}) {
    // Handle empty input
    if (amount.isEmpty) {
      return BigInt.zero;
    }

    try {
      // Parse the amount to double first
      final double parsedAmount = double.parse(amount);

      switch (network) {
        case NetworkType.bitcoin:
          // Convert to Satoshi (1 BTC = 10^8 Satoshi)
          return BigInt.from(parsedAmount * pow(10, 8));

        case NetworkType.solana:
          if (tokenDecimals != null) {
            // SPL 토큰인 경우, 토큰별 소수점 자릿수 사용 (Trump = 6자리)
            return BigInt.from(parsedAmount * pow(10, tokenDecimals));
          } else {
            // 네이티브 SOL인 경우 (9자리)
            return BigInt.from(parsedAmount * pow(10, 9));
          }

        case NetworkType.ethereum:
        case NetworkType.bsc:
          if (tokenDecimals != null) {
            // ERC-20 토큰인 경우, 토큰별 소수점 자릿수 사용
            return BigInt.from(parsedAmount * pow(10, tokenDecimals));
          } else {
            // 네이티브 ETH인 경우 (18자리)
            return BigInt.from(parsedAmount * pow(10, 18));
          }
      }
    } catch (e) {
      print('Error converting amount: $e');
      return BigInt.zero;
    }
  }

  static bool isValidEthereumAddress(String address) {
    try {
      if (address.isEmpty) {
        return false;
      }

      if (!address.startsWith('0x')) {
        return false;
      }

      if (address.length != 42) {
        return false;
      }

      final hex = address.substring(2); // 0x 제외
      final hexRegExp = RegExp(r'^[0-9a-fA-F]+$');

      return hexRegExp.hasMatch(hex);
    } catch (e) {
      return false;
    }
  }

  /// Formats a crypto amount with appropriate decimal places
  static String formatAmount(String amount, {int maxDecimals = 8}) {
    try {
      final double value = double.parse(amount);

      // If the value is a whole number, display without decimals
      if (value == value.toInt()) {
        return value.toInt().toString();
      }

      // Format with specified number of decimals
      final String formatted = value.toStringAsFixed(maxDecimals);

      // Remove trailing zeros
      if (formatted.contains('.')) {
        final String trimmed = formatted.replaceAll(RegExp(r'0+$'), '');
        return trimmed.endsWith('.')
            ? trimmed.substring(0, trimmed.length - 1)
            : trimmed;
      }

      return formatted;
    } catch (e) {
      return amount;
    }
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }

  static String shortenWalletAddress(String address) {
    if (address.length <= 15) {
      // 너무 짧은 주소는 전체 표시
      return address;
    }

    String firstPart = address.substring(0, 5); // 앞 10자리
    String lastPart = address.substring(address.length - 5); // 뒤 5자리

    return '$firstPart...$lastPart';
  }

  static String formatNumberWithComma(int number) {
    String formattedNumber = number.toString();
    String result = '';

    while (formattedNumber.length > 3) {
      result =
          ',${formattedNumber.substring(formattedNumber.length - 3)}$result';
      formattedNumber =
          formattedNumber.substring(0, formattedNumber.length - 3);
    }

    result = formattedNumber + result;
    return result;
  }

  static int getTextLine(String text) {
    if (text.contains('\n')) {
      return text.split('\n').length;
    } else {
      return 1;
    }
  }

  /// BSC 자격증명 생성
  static EthPrivateKey getBscCredentials(String privateKey) {
    return EthPrivateKey.fromHex(privateKey);
  }

  /// BSC 주소 변환
  static EthereumAddress hexToBscAddress(String address) {
    return EthereumAddress.fromHex(address);
  }
}
