part of 'start_cubit.dart';

class StartState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  const StartState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
  });

  StartState copyWith({
    ScreenStatus? status,
    CustomException? exception,
  }) {
    return StartState(
      status: status ?? this.status,
      exception: exception ?? this.exception,
    );
  }

  @override
  List<Object?> get props => [
        status,
        exception,
      ];
}
