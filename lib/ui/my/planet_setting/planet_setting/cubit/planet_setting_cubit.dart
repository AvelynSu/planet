import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/repository/fb_repository.dart';

import '../../../../../enum/screen_status.dart';
import '../../../../../model/custom_exception.dart';

part 'planet_setting_state.dart';

class PlanetSettingCubit extends Cubit<PlanetSettingState> {
  final ApiRepository apiRepository;
  final AppBloc appBloc;

  late StreamSubscription subscription;

  PlanetSettingCubit({
    required this.apiRepository,
    required this.appBloc,
  }) : super(const PlanetSettingState()) {
    subscription = appBloc.stream.listen((state) {
      update();
    });
  }

  update() {
    var appState = appBloc.state as AppLoaded;
    emit(state.copyWith(
        planet: appState.currentPlanet, status: ScreenStatus.loaded));
  }

  initialize() async {
    var appState = appBloc.state as AppLoaded;
    emit(state.copyWith(
        planet: appState.currentPlanet, status: ScreenStatus.loaded));
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
