part of 'sample_cubit.dart';

class SampleState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  const SampleState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
  });

  SampleState copyWith({
    ScreenStatus? status,
    CustomException? exception,
  }) {
    return SampleState(
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
