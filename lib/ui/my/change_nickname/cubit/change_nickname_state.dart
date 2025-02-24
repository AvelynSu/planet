part of 'change_nickname_cubit.dart';

class ChangeNicknameState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  final Planet planet;
  final String nickname;

  const ChangeNicknameState({
    this.status = ScreenStatus.initial,
    this.nickname = "",
    this.planet = Planet.empty,
    this.exception = CustomException.empty,
  });

  ChangeNicknameState copyWith({
    ScreenStatus? status,
    String? nickname,
    Planet? planet,
    CustomException? exception,
  }) {
    return ChangeNicknameState(
      status: status ?? this.status,
      nickname: nickname ?? this.nickname,
      exception: exception ?? this.exception,
      planet: planet ?? this.planet,
    );
  }

  @override
  List<Object?> get props => [
        status,
        nickname,
        exception,
        planet,
      ];
}
