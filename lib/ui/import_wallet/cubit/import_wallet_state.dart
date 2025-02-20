part of 'import_wallet_cubit.dart';

class ImportWalletState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  final List<NetworkType> networkType;
  final String mnemonic;

  final int page;

  const ImportWalletState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
    this.networkType = const [],
    this.mnemonic = "",
    this.page = 0,
  });

  ImportWalletState copyWith({
    ScreenStatus? status,
    List<NetworkType>? networkType,
    String? mnemonic,
    int? page,
    CustomException? exception,
  }) {
    return ImportWalletState(
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
