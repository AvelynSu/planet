import 'package:equatable/equatable.dart';
import 'package:planet/model/planet_dto.dart';

class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
}

// 홈화면 진입 전 : 로그인 타입 선택 전, 로그인 이후
class AppUnInitialized extends AppState {
  final bool requiredSign;
  final bool requiredFirstPlanetNickname;

  const AppUnInitialized({
    this.requiredSign = false,
    this.requiredFirstPlanetNickname = false,
  }) : super();

  static AppUnInitialized get sign => const AppUnInitialized(
        requiredSign: true,
      );

  static AppUnInitialized get planetName =>
      const AppUnInitialized(requiredFirstPlanetNickname: true);

  @override
  List<Object?> get props => [
        requiredSign,
        requiredFirstPlanetNickname,
      ];
}

class AppLoaded extends AppState {
  final List<PlanetDto> planets;

  const AppLoaded({
    this.planets = const [],
  });

  static const empty = AppLoaded();

  AppLoaded copyWith({
    List<PlanetDto>? planets,
  }) {
    return AppLoaded(
      planets: planets ?? this.planets,
    );
  }

  @override
  List<Object?> get props => [
        planets,
      ];
}

class AppLoading extends AppState {}

class AppErr extends AppState {
  final String? err;

  const AppErr({this.err});

  @override
  List<Object?> get props => [err];
}
