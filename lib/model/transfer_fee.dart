import 'dart:math';

import 'package:web3dart/web3dart.dart';

class TransferFee {
  final BigInt gasPrice; // 가스 단위 가격
  final BigInt gasLimit; // 최대 사용 가능한 가스량
  final BigInt estimatedFee; // 예상 총 수수료 (gasPrice * gasLimit)

  TransferFee({
    required this.gasPrice,
    required this.gasLimit,
    required this.estimatedFee,
  });

  // Wei 단위의 수수료를 ETH 단위로 변환
  double get feeInEth => estimatedFee / BigInt.from(pow(10, 18));

  // 사용자 표시용 포맷팅
  String get formatted => '${feeInEth.toStringAsFixed(8)} ETH';

  String get feeToEth {
    final ethValue = EtherAmount.fromBigInt(EtherUnit.wei, estimatedFee)
        .getValueInUnit(EtherUnit.ether);
    return ethValue.toStringAsFixed(8);
  }
}
