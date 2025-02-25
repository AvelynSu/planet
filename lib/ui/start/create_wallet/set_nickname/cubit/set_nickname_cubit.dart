import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/service/local_storage_service.dart';
import 'package:planet/service/wallet/wallet_service.dart';

import '../../../../../enum/screen_status.dart';
import '../../../../../model/custom_exception.dart';
import '../../../../../util/data/planet_name_data.dart';

part 'set_nickname_state.dart';

class SetNicknameCubit extends Cubit<SetNicknameState> {
  final AppBloc appBloc;
  final Planet planet;
  final ApiRepository apiRepository;

  SetNicknameCubit({
    required this.appBloc,
    required this.planet,
    required this.apiRepository,
  }) : super(const SetNicknameState());

  initialize() async {
    var allNickName = await apiRepository.getAllNickName();

    var planet =
        Data.planetNames[Random().nextInt(Data.planetNames.length - 1)];
    planet = planet.replaceAll(" ", "").toLowerCase();
    var idx = Random().nextInt(10000);

    while (!allNickName.contains("$planet$idx")) {
      idx = Random().nextInt(10000);
      break;
    }

    emit(state.copyWith(
      nickname: "$planet${idx}",
      status: ScreenStatus.loaded,
    ));
  }

  updateValue(String text) {
    emit(state.copyWith(nickname: text, status: ScreenStatus.loaded));
  }

  onCreatePlanet() async {
    if (state.nickname.isEmpty) {
      return;
    }
    emit(state.copyWith(status: ScreenStatus.loading));

    var enablePlanet = await apiRepository.enablePlanetName(state.nickname);
    if (enablePlanet) {
      var address = await WalletService()
          .generateHDAddress(NetworkType.ethereum, planet.mnemonic, 0);
      var _planet = planet.copyWith(
        networkType: NetworkType.ethereum,
        address: address,
        mnemonic: planet.mnemonic,
        name: state.nickname,
        createdAt: DateTime.now(),
        isCurrent: true,
      );
      await apiRepository.addPlanet(_planet);
      await LocalStorageService.saveMnemonics([_planet]);
      appBloc.add(AppInitialize());
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
