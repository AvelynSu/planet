import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/bloc.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/repository/fb_repository.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';

part 'planets_state.dart';

class PlanetsCubit extends Cubit<PlanetsState> {
  final AppBloc appBloc;
  final ApiRepository apiRepository;

  PlanetsCubit({
    required this.appBloc,
    required this.apiRepository,
  }) : super(const PlanetsState());

  initialize() async {
    var appState = appBloc.state as AppLoaded;

    if (appState.others.isNotEmpty) {
      emit(state.copyWith(
          planet: appState.others.first, planets: appState.others));
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    var planets = await apiRepository.getAllPlanetForTest();
    appBloc.add(AppUpdate(
      others: planets,
      updatePlanets: false,
    ));
    emit(state.copyWith(planets: planets, planet: planets.first));
  }

  onPageUpdate(Planet planet) {
    emit(state.copyWith(planet: planet));
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
