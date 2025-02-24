part of 'transfer_cubit.dart';

class TokenTransferState extends Equatable {
  final ScreenStatus status;
  final CustomException? exception;

  final TokenBalance balance;

  final Planet toPlanet;
  final String amount;

  final bool useCustomGas;
  final Map<GasPriority, TransferFee> gasFees;
  final GasPriority selectedGasPriority;
  final TransferFee? customGasFee;

  const TokenTransferState({
    this.status = ScreenStatus.loading,
    this.balance = TokenBalance.empty,
    this.toPlanet = Planet.empty,
    this.amount = '',
    this.gasFees = const {},
    this.selectedGasPriority = GasPriority.medium,
    this.useCustomGas = false,
    this.customGasFee,
    this.exception,
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

  bool get isFormValid => isValidateAmount;

  TokenTransferState copyWith({
    ScreenStatus? status,
    CustomException? exception,
    TokenBalance? balance,
    Planet? toPlanet,
    String? amount,
    Map<GasPriority, TransferFee>? gasFees,
    GasPriority? selectedGasPriority,
    bool? useCustomGas,
    TransferFee? customGasFee,
  }) {
    return TokenTransferState(
      status: status ?? this.status,
      toPlanet: toPlanet ?? this.toPlanet,
      balance: balance ?? this.balance,
      amount: amount ?? this.amount,
      gasFees: gasFees ?? this.gasFees,
      selectedGasPriority: selectedGasPriority ?? this.selectedGasPriority,
      useCustomGas: useCustomGas ?? this.useCustomGas,
      customGasFee: customGasFee ?? this.customGasFee,
      exception: exception ?? this.exception,
    );
  }

  @override
  List<Object?> get props => [
        status,
        toPlanet,
        amount,
        gasFees,
        selectedGasPriority,
        useCustomGas,
        customGasFee,
        exception,
      ];
}
