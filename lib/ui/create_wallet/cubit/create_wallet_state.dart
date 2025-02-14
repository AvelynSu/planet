part of 'create_wallet_cubit.dart';

class CreateWalletState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  final List<NetworkType> networkType;
  final String mnemonic;

  final int page;

  const CreateWalletState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
    this.networkType = const [],
    this.mnemonic = "",
    this.page = 0,
  });

  CreateWalletState copyWith({
    ScreenStatus? status,
    List<NetworkType>? networkType,
    String? mnemonic,
    int? page,
    CustomException? exception,
  }) {
    return CreateWalletState(
      status: status ?? this.status,
      mnemonic: mnemonic ?? this.mnemonic,
      page: page ?? this.page,
      networkType: networkType ?? this.networkType,
      exception: exception ?? this.exception,
    );
  }

  @override
  List<Object?> get props => [
        status,
        mnemonic,
        page,
        networkType,
        exception,
      ];
}
