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

class AppUpdate extends AppEvent {
  final bool updateBalance;
  final TokenInfo updateBalanceToken;
  final Planet isCurrentPlanet;

  AppUpdate({
    this.updateBalance = false,
    this.updateBalanceToken = TokenInfo.empty,
    this.isCurrentPlanet = Planet.empty,
  });

  @override
  List<Object?> get props => [
        updateBalance,
        updateBalanceToken,
        isCurrentPlanet,
      ];
}

class AppSignOut extends AppEvent {}
