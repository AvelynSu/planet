part of 'planet_setting_cubit.dart';

class PlanetSettingState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  final Planet planet;

  const PlanetSettingState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
    this.planet = Planet.empty,
  });

  PlanetSettingState copyWith({
    ScreenStatus? status,
    CustomException? exception,
    Planet? planet,
  }) {
    return PlanetSettingState(
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
