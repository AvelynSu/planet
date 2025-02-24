part of 'my_cubit.dart';

class MyState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;
  final Planet planet;

  const MyState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
    this.planet = Planet.empty,
  });

  MyState copyWith({
    ScreenStatus? status,
    CustomException? exception,
    Planet? planet,
  }) {
    return MyState(
        status: status ?? this.status,
        exception: exception ?? this.exception,
        planet: planet ?? this.planet);
  }

  @override
  List<Object?> get props => [
        status,
        exception,
        planet,
      ];
}
