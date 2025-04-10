import 'package:equatable/equatable.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/model/token_info.dart';

class AppEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppInitialize extends AppEvent {
  AppInitialize();

  @override
  List<Object?> get props => [];
}

// 차라리 수정이 필요한건 그 자리에서 수정하고,
// 이거는 그거를 반영하는 용도로만 사용하는게 좋을듯 ?
class AppUpdate extends AppEvent {
  final bool updateBalance;
  final TokenInfo updateBalanceToken;
  final bool updatePlanets;
  final bool updatePrice;
  final Planet? currentPlanet;
  final List<Planet>? others;

  AppUpdate({
    this.updateBalance = false,
    this.updateBalanceToken = TokenInfo.empty,
    this.updatePlanets = true,
    this.updatePrice = false,
    this.currentPlanet,
    this.others,
  });

  @override
  List<Object?> get props => [
        updateBalance,
        updateBalanceToken,
        updatePlanets,
        updatePrice,
        currentPlanet,
        others,
      ];
}

class AppSignOut extends AppEvent {}

class AppDelete extends AppEvent {
  final List<Planet> planets;

  AppDelete(this.planets);
}
