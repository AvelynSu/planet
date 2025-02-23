part of 'sample_cubit.dart';

class TokenBalanceState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  final PlanetDto planet;
  final TokenBalance balance;
  final List<TransactionHistory> items;

  const TokenBalanceState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
    this.planet = PlanetDto.empty,
    this.balance = TokenBalance.empty,
    this.items = const [],
  });

  TokenBalanceState copyWith({
    ScreenStatus? status,
    CustomException? exception,
    PlanetDto? planet,
    TokenBalance? balance,
    List<TransactionHistory>? items,
  }) {
    return TokenBalanceState(
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
