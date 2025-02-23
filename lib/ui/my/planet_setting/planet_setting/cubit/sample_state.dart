part of 'sample_cubit.dart';

class PlanetSettingState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  final PlanetDto planetDto;

  const PlanetSettingState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
    this.planetDto = PlanetDto.empty,
  });

  PlanetSettingState copyWith({
    ScreenStatus? status,
    CustomException? exception,
    PlanetDto? planetDto,
  }) {
    return PlanetSettingState(
      status: status ?? this.status,
      exception: exception ?? this.exception,
      planetDto: planetDto ?? this.planetDto,
    );
  }

  @override
  List<Object?> get props => [
        status,
        exception,
        planetDto,
      ];
}
