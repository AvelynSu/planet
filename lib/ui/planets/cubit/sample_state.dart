part of 'sample_cubit.dart';

class PlanetsState extends Equatable {
  final ScreenStatus status;
  final List<Planet> planets;

  final Planet planet;
  final CustomException exception;

  const PlanetsState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
    this.planet = Planet.empty,
    this.planets = const [],
  });

  PlanetsState copyWith({
    ScreenStatus? status,
    CustomException? exception,
    Planet? planet,
    List<Planet>? planets,
  }) {
    return PlanetsState(
      status: status ?? this.status,
      exception: exception ?? this.exception,
      planets: planets ?? this.planets,
      planet: planet ?? this.planet,
    );
  }

  @override
  List<Object?> get props => [
        status,
        exception,
        planets,
        planet,
      ];
}
