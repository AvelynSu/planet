part of 'transfer_cubit.dart';

class TokenTransferState extends Equatable {
  final ScreenStatus status;

  final TokenBalance balance;

  final CustomException? exception;
  final String recipientAddress;
  final String amount;
  final Map<GasPriority, TransferFee> gasFees;
  final GasPriority selectedGasPriority;
  final bool useCustomGas;
  final TransferFee? customGasFee;

  const TokenTransferState({
    this.status = ScreenStatus.loading,
    this.balance = TokenBalance.empty,
    this.recipientAddress = '',
    this.amount = '',
    this.gasFees = const {},
    this.selectedGasPriority = GasPriority.medium,
    this.useCustomGas = false,
    this.customGasFee,
    this.exception,
  });

  bool get isValidateAddress {
    // Basic Ethereum address validation
    return recipientAddress.startsWith('0x') && recipientAddress.length == 42;
  }

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

  bool get isFormValid => isValidateAddress && isValidateAmount;

  TokenTransferState copyWith({
    ScreenStatus? status,
    CustomException? exception,
    TokenBalance? balance,
    String? recipientAddress,
    String? amount,
    Map<GasPriority, TransferFee>? gasFees,
    GasPriority? selectedGasPriority,
    bool? useCustomGas,
    TransferFee? customGasFee,
  }) {
    return TokenTransferState(
      status: status ?? this.status,
      recipientAddress: recipientAddress ?? this.recipientAddress,
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
        recipientAddress,
        amount,
        gasFees,
        selectedGasPriority,
        useCustomGas,
        customGasFee,
        exception,
      ];
}
