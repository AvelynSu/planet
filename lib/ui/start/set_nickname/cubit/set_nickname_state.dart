part of 'set_nickname_cubit.dart';

class SetNicknameState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  final String nickname;

  const SetNicknameState({
    this.status = ScreenStatus.initial,
    this.nickname = "shiftfn",
    this.exception = CustomException.empty,
  });

  SetNicknameState copyWith({
    ScreenStatus? status,
    String? nickname,
    CustomException? exception,
  }) {
    return SetNicknameState(
      status: status ?? this.status,
      nickname: nickname ?? this.nickname,
      exception: exception ?? this.exception,
    );
  }

  @override
  List<Object?> get props => [
        status,
        nickname,
        exception,
      ];
}
