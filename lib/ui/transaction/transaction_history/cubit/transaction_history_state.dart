part of 'transaction_history_cubit.dart';

class TransactionHistoryState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  final Planet planet;
  final TokenBalance balance;
  final List<TransactionHistory> items;

  const TransactionHistoryState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
    this.planet = Planet.empty,
    this.balance = TokenBalance.empty,
    this.items = const [],
  });

  TransactionHistoryState copyWith({
    ScreenStatus? status,
    CustomException? exception,
    Planet? planet,
    TokenBalance? balance,
    List<TransactionHistory>? items,
  }) {
    return TransactionHistoryState(
      status: status ?? this.status,
      exception: exception ?? this.exception,
      planet: planet ?? this.planet,
      balance: balance ?? this.balance,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
        status,
        exception,
        planet,
        balance,
        items,
      ];
}
