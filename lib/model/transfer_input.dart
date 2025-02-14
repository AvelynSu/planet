import '../enum/gas_priority.dart';

class TransferInput {
  final String toAddress; // 받는 사람 주소
  final double amount; // 보낼 금액
  final GasPriority gasPriority; // 가스비 우선순위 선택
  TransferInput(
    this.toAddress,
    this.amount,
    this.gasPriority,
  );
}
