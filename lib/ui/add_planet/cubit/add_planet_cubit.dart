import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/util/app_util.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';
import '../../../bloc/app/app_event.dart';
import '../../../service/local_storage_service.dart';
import '../../../service/wallet/wallet_service.dart';

part 'add_planet_state.dart';

List<Planet> _planets = [];

class AddPlanetCubit extends Cubit<AddPlanetState> {
  final AppBloc appBloc;
  final ApiRepository apiRepository;
  final NetworkType networkType;

  AddPlanetCubit({
    required this.appBloc,
    required this.apiRepository,
    required this.networkType,
  }) : super(const AddPlanetState());

  initialize() async {
    // 전체 닉네임 불러오기
    var alreadyNickname = await apiRepository.getAllNickName();
    var randomNickname = AppUtil.getRandomNickname(alreadyNickname);

    emit(state.copyWith(
      nickname: randomNickname,
      status: ScreenStatus.loaded,
    ));
  }

  updateValue(String text) {
    emit(state.copyWith(nickname: text, status: ScreenStatus.loaded));
  }

  onCreatePlanet() async {
    // 닉네임 빈값이면 생성 x
    if (state.nickname.isEmpty) {
      return;
    }
    emit(state.copyWith(status: ScreenStatus.loading));

    var currentPlanet = (appBloc.state as AppLoaded).currentPlanet;

    // 사용가능한 닉네임인지 보기
    var enablePlanetName = await apiRepository.enablePlanetName(state.nickname);

    if (enablePlanetName) {
      var walletService = WalletService();

      var planets = (appBloc.state as AppLoaded)
          .myPlanets
          .where((e) => e.networkType == networkType)
          .toList();

      // todo : 비트코인같은거 처음 할때는 인덱스 없어서 그 경우에 대비해야함

      var parent = planets.where((e) => e.pathIdx == 0).firstOrNull;

      List<Planet> childs =
          parent != null ? await apiRepository.getChildPlanets(parent) : [];
      var idx = 0;
      var planet = Planet(
        networkType: networkType,
        mnemonic: currentPlanet.mnemonic,
        name: state.nickname,
        createdAt: DateTime.now(),
        parentsAddress: parent?.address ?? "",
        isCurrent: true,
        pathIdx: idx,
      );

      if (childs.isNotEmpty) {
        for (var item in childs) {
          if (item.pathIdx >= idx) {
            idx = item.pathIdx + 1;
          }
        }
      }

      // 이더리움 하위의 지갑 만들기
      var address = await walletService.generateHDAddress(
          networkType, currentPlanet.mnemonic, idx);

      planet = planet.copyWith(address: address, pathIdx: idx);

      // 플래닛 fb에 저장
      await apiRepository.addPlanet(planet);

      // 로컬에 저장
      await LocalStorageService.saveMnemonics([planet],
          isCurrentAddress: planet.address);

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
    return super.close();
  }
}
