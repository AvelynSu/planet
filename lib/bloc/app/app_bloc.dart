import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/repository/fb_repository.dart';

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

    // await userRepository.signOut();
  }

  Stream<AppState> mapAppUpdateToState(AppUpdate event) async* {
    try {
      var user = await userRepository.getUser();

      yield AppLoaded(
        user: user,
        subjects: subjects,
        store: store,
      );
    } catch (err) {
      debugPrint(err);
    }
  }

  Stream<AppState> mapAppSignOutToState(AppSignOut event) async* {
    await apiRepository.signOut();

    add(AppInitialize());
  }
}
