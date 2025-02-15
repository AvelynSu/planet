part of 'sample_cubit.dart';

class HomeState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  final PlanetDto planet;

  const HomeState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
    this.planet = PlanetDto.empty,
  });

  String get data {
    return planet.name;
  }

  HomeState copyWith({
    ScreenStatus? status,
    CustomException? exception,
    PlanetDto? planet,
  }) {
    return HomeState(
      status: status ?? this.status,
      exception: exception ?? this.exception,
      planet: planet ?? this.planet,
    );
  }

  @override
  List<Object?> get props => [
        status,
        exception,
        planet,
      ];
}
