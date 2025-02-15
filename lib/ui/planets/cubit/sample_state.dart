part of 'sample_cubit.dart';

class PlanetsState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  const PlanetsState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
  });

  PlanetsState copyWith({
    ScreenStatus? status,
    CustomException? exception,
  }) {
    return PlanetsState(
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
