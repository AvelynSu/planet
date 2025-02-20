import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/model/token_balance.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/service/local_storage_service.dart';
import 'package:planet/service/wallet/wallet_balance_service.dart';

import 'bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final ApiRepository apiRepository;

  AppBloc({
    required this.apiRepository,
  }) : super(AppLoading());

  @override
  Stream<AppState> mapEventToState(event) async* {
    if (event is AppInitialize) {
      yield* mapAppInitializeToState(event);
    } else if (event is AppUpdate) {
      yield* mapAppUpdateToState(event);
    } else if (event is AppSignOut) {
      yield* mapAppSignOutToState(event);
    }
  }

  Stream<AppState> mapAppInitializeToState(AppInitialize event) async* {
    yield AppLoading();
    FirebaseAnalytics.instance.logAppOpen();
    // await LocalStorageService.clearMnemonics();
    var localPlanets = await LocalStorageService.getLocalPlanets();

    if (localPlanets.isEmpty) {
      yield AppUnInitialized.sign;
    } else {
      if (localPlanets.length == 1 && localPlanets.first.name.isEmpty) {
        yield AppUnInitialized.planetName;
      } else {
        var planets = await apiRepository.getPlanetByLocalInfo(localPlanets);
        var current =
            planets.where((e) => e.isCurrent).firstOrNull ?? planets.first;
        var updateBalance = await WalletBalanceService()
            .getAllTokenBalances(walletAddress: current.address);

        yield AppLoaded(
          planets: planets,
          balance: updateBalance,
          current: current,
        );
      }
    }

    // await userRepository.signOut();
  }

  Stream<AppState> mapAppUpdateToState(AppUpdate event) async* {
    try {
      var localPlanets = await LocalStorageService.getLocalPlanets();
      var planets = await apiRepository.getPlanetByLocalInfo(localPlanets);
      var current =
          planets.where((e) => e.isCurrent).firstOrNull ?? planets.first;

      List<TokenBalance> updateBalance = (state as AppLoaded).balance;
      if (event.updateBalance) {
        updateBalance = await WalletBalanceService()
            .getAllTokenBalances(walletAddress: current.address);
      }

      yield AppLoaded(
        planets: planets,
        balance: updateBalance,
        current: current ?? planets.first,
      );
    } catch (err) {
      print(err);
    }
  }

  Stream<AppState> mapAppSignOutToState(AppSignOut event) async* {
    await apiRepository.signOut();
    add(AppInitialize());
  }
}
