part of 'sample_cubit.dart';

class MyState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  const MyState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
  });

  MyState copyWith({
    ScreenStatus? status,
    CustomException? exception,
  }) {
    return MyState(
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
