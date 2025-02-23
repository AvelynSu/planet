part of 'sample_cubit.dart';

class MyState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;
  final PlanetDto planetDto;

  const MyState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
    this.planetDto = PlanetDto.empty,
  });

  MyState copyWith({
    ScreenStatus? status,
    CustomException? exception,
    PlanetDto? planetDto,
  }) {
    return MyState(
        status: status ?? this.status,
        exception: exception ?? this.exception,
        planetDto: planetDto ?? this.planetDto);
  }

  @override
  List<Object?> get props => [
        status,
        exception,
        planetDto,
      ];
}
