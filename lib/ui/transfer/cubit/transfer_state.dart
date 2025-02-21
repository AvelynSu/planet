part of 'transfer_cubit.dart';

class TokenTransferState extends Equatable {
  final ScreenStatus status;

  final CustomException? exception;
  final String recipientAddress;
  final String amount;
  final Map<GasPriority, TransferFee> gasFees;
  final GasPriority selectedGasPriority;
  final bool useCustomGas;
  final TransferFee? customGasFee;

  const TokenTransferState({
    this.status = ScreenStatus.loading,
    this.recipientAddress = '',
    this.amount = '',
    this.gasFees = const {},
    this.selectedGasPriority = GasPriority.medium,
    this.useCustomGas = false,
    this.customGasFee,
    this.exception,
  });

  TokenTransferState copyWith({
    ScreenStatus? status,
    CustomException? exception,
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
