import 'package:equatable/equatable.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/model/token_balance.dart';

class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
}

// 홈화면 진입 전 : 로그인 타입 선택 전, 로그인 이후
class AppUnInitialized extends AppState {
  final bool requiredSign;

  const AppUnInitialized({
    this.requiredSign = false,
  }) : super();

  static AppUnInitialized get sign => const AppUnInitialized(
        requiredSign: true,
      );

  @override
  List<Object?> get props => [
        requiredSign,
      ];
}

class AppLoaded extends AppState {
  /// 지갑 전체 목록을 보여주기 위함 (유저가 수시로 확인할 수 있는 내용)
  // 내 플래닛 전체
  final List<Planet> myPlanets;

  /// 앱에서 메인으로 보여주는 지갑
  // 현재 앱에서 다루는 플래닛 (1개를 메인으로 보여줌)
  final Planet currentPlanet;

  // currentPlanet 하위의 토큰들 자산
  final List<TokenBalance> currentTokens;

  const AppLoaded({
    this.myPlanets = const [],
    this.currentPlanet = Planet.empty,
    this.currentTokens = const [],
  });

  static const empty = AppLoaded();

  AppLoaded copyWith({
    List<Planet>? planets,
    Planet? current,
    List<TokenBalance>? balance,
  }) {
    return AppLoaded(
      myPlanets: planets ?? this.myPlanets,
      currentPlanet: current ?? this.currentPlanet,
      currentTokens: balance ?? this.currentTokens,
    );
  }

  @override
  List<Object?> get props => [
        myPlanets,
        currentPlanet,
        currentTokens,
      ];
}

class AppLoading extends AppState {}

class AppErr extends AppState {
  final String? err;

  const AppErr({this.err});

  @override
  List<Object?> get props => [err];
}
