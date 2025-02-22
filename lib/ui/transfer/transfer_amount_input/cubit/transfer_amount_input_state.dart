part of 'transfer_amount_input_cubit.dart';

class TransferAmountInputState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  final TokenBalance balance;
  final String amount;

  const TransferAmountInputState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
    this.balance = TokenBalance.empty,
    this.amount = "",
  });

  bool get isValidateAmount {
    if (amount.isEmpty) {
      return false;
    }

    try {
      final double inputAmount = double.parse(amount);
      final double availableBalance = balance.balance;

      return inputAmount > 0 && inputAmount <= availableBalance;
    } catch (e) {
      return false;
    }
  }

  TransferAmountInputState copyWith({
    ScreenStatus? status,
    CustomException? exception,
    TokenBalance? balance,
    String? amount,
  }) {
    return TransferAmountInputState(
      status: status ?? this.status,
      exception: exception ?? this.exception,
      balance: balance ?? this.balance,
      amount: amount ?? this.amount,
    );
  }

  @override
  List<Object?> get props => [
        status,
        exception,
        balance,
        amount,
      ];
}
