part of 'add_planet_cubit.dart';

class AddPlanetState extends Equatable {
  final ScreenStatus status;
  final String nickname;

  final CustomException exception;

  const AddPlanetState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
    this.nickname = "",
  });

  AddPlanetState copyWith({
    ScreenStatus? status,
    CustomException? exception,
    String? nickname,
  }) {
    return AddPlanetState(
      status: status ?? this.status,
      exception: exception ?? this.exception,
      nickname: nickname ?? this.nickname,
    );
  }

  @override
  List<Object?> get props => [
        status,
        exception,
        nickname,
      ];
}
