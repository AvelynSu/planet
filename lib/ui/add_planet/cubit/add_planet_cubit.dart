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

  AddPlanetCubit({
    required this.appBloc,
    required this.apiRepository,
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

  onCreatePlanet(
    NetworkType networkType,
  ) async {
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

      // fb에서 불러온것 중에 부모 행성 찾기
      var parent = planets.where((e) => e.pathIdx == 0).firstOrNull;

      // 부모가 있는 경우 child 가져오기 (인덱스 계산해주기 위함) : 만약 부모가 없으면 무조건 0을 만듦 (비트코인 같은거)
      List<Planet> childs = parent != null
          ? await apiRepository.getChildPlanets(parent.address, networkType)
          : [];
      var idx = 0;

      // 새로운 child 만들기 위한 dto
      var planet = Planet(
        networkType: networkType,
        mnemonic: currentPlanet.mnemonic,
        name: state.nickname,
        createdAt: DateTime.now(),
        parentsAddress: parent?.address ?? "",
        isCurrent: true,
        pathIdx: idx,
      );

      // 이번에 니모닉 몇 번째꺼 해야 하는지
      if (childs.isNotEmpty) {
        for (var item in childs) {
          if (item.pathIdx >= idx) {
            idx = item.pathIdx + 1;
          }
        }
      }

      // 하위의 지갑 만들기
      var address = await walletService.generateHDAddress(
          networkType, currentPlanet.mnemonic, idx);

      planet = planet.copyWith(
        address: address,
        pathIdx: idx,
        parentsAddress: planet.parentsAddress.isEmpty ? address : null,
      );

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
