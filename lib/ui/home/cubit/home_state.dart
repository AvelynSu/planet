part of 'home_cubit.dart';

class HomeState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  final List<TokenBalance> balances;

  final Planet planet;

  const HomeState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
    this.planet = Planet.empty,
    this.balances = const [],
  });

  String get data {
    return planet.name;
  }

  HomeState copyWith({
    ScreenStatus? status,
    CustomException? exception,
    Planet? planet,
    List<TokenBalance>? balances,
  }) {
    return HomeState(
      status: status ?? this.status,
      exception: exception ?? this.exception,
      planet: planet ?? this.planet,
      balances: balances ?? this.balances,
    );
  }

  @override
  List<Object?> get props => [
        status,
        exception,
        planet,
        balances,
      ];
}
