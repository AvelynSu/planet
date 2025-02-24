import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/repository/fb_repository.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';

part 'sample_state.dart';

List<Planet> _planets = [];

class PlanetsCubit extends Cubit<PlanetsState> {
  final ApiRepository apiRepository;

  PlanetsCubit({
    required this.apiRepository,
  }) : super(const PlanetsState());

  initialize() async {
    if (_planets.isNotEmpty) {
      emit(state.copyWith(planet: _planets.first, planets: _planets));
    }
    var planets = await apiRepository.getAllPlanetForTest();
    _planets = planets;
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
