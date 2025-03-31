import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/repository/fb_repository.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';

part 'change_nickname_state.dart';

class ChangeNicknameCubit extends Cubit<ChangeNicknameState> {
  final AppBloc appBloc;
  final Planet planet;
  final ApiRepository apiRepository;

  ChangeNicknameCubit({
    required this.appBloc,
    required this.planet,
    required this.apiRepository,
  }) : super(const ChangeNicknameState());

  initialize() async {
    emit(state.copyWith(status: ScreenStatus.initial));
    await Future.delayed(Duration(milliseconds: 100));
    emit(state.copyWith(
      nickname: planet.name,
      planet: planet,
      status: ScreenStatus.loaded,
    ));
  }

  updateValue(String name) {
    emit(state.copyWith(nickname: name, status: ScreenStatus.loaded));
  }

  onUpdateName() async {
    if (state.nickname.isEmpty) {
      return;
    }
    emit(state.copyWith(status: ScreenStatus.loading));

    var enablePlanet = await apiRepository.enablePlanetName(state.nickname);
    if (enablePlanet) {
      var updatePlanet = await apiRepository.updatePlanetName(
          planet, planet.name, state.nickname);
      appBloc.add(AppUpdate(updatePlanets: true, updateBalance: false));
      emit(state.copyWith(status: ScreenStatus.success));
    } else {
      emit(
        state.copyWith(
          status: ScreenStatus.fail,
          exception:
              CustomException(errType: ExceptionType.planetNameDuplicate),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    // TODO: implement close
    return super.close();
  }
}
