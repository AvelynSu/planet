import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/service/local_storage_service.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';

part 'change_nickname_state.dart';

class ChangeNicknameCubit extends Cubit<ChangeNicknameState> {
  final AppBloc appBloc;
  final PlanetDto planet;
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
      var updatePlanet =
          await apiRepository.updatePlanet(planet, state.nickname);

      await LocalStorageService.saveMnemonics([updatePlanet]);
      appBloc.add(AppUpdate());
      emit(state.copyWith(status: ScreenStatus.success));
    } else {
      emit(
        state.copyWith(
          status: ScreenStatus.fail,
          exception: CustomException(errMsg: "이미 사용중인 행성이름입니다."),
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
