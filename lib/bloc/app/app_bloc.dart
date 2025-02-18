import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/service/local_storage_service.dart';

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
        var current = planets.where((e) => e.isCurrent).firstOrNull;

        await Future.delayed(const Duration(seconds: 3));

        yield AppLoaded(
          planets: planets,
          current: current ?? planets.first,
        );
      }
    }

    // await userRepository.signOut();
  }

  Stream<AppState> mapAppUpdateToState(AppUpdate event) async* {
    try {
      var localPlanets = await LocalStorageService.getLocalPlanets();
      var planets = await apiRepository.getPlanetByLocalInfo(localPlanets);
      var current = planets.where((e) => e.isCurrent).firstOrNull;

      yield AppLoaded(
        planets: planets,
        current: current ?? planets.first,
      );
    } catch (_) {}
  }

  Stream<AppState> mapAppSignOutToState(AppSignOut event) async* {
    await apiRepository.signOut();
    add(AppInitialize());
  }
}
