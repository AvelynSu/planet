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
    // 전체 닉네임 불러오기
    var allNickName = await apiRepository.getAllNickName();

    // 플래닛 랜덤 네임 설정
    var planet =
        Data.planetNames[Random().nextInt(Data.planetNames.length - 1)];
    planet = planet.replaceAll(" ", "").toLowerCase();
    var idx = Random().nextInt(10000);

    // fb에 없는 이름 나올때까지 생성
    while (!allNickName.contains("$planet$idx")) {
      idx = Random().nextInt(10000);
      break;
    }

    emit(state.copyWith(
      nickname: "$planet$idx",
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

    // 사용가능한 닉네임인지 보기
    var enablePlanetName = await apiRepository.enablePlanetName(state.nickname);
    if (enablePlanetName) {
      var walletService = WalletService();
      // 이더리움 하위의 0 지갑 만들기
      var address = await walletService.generateHDAddress(
          NetworkType.ethereum, planet.mnemonic, 0);
      var _planet = planet.copyWith(
          networkType: NetworkType.ethereum,
          address: address,
          mnemonic: planet.mnemonic,
          name: state.nickname,
          createdAt: DateTime.now(),
          isCurrent: true,
          pathIdx: 0);

      // 플래닛 fb에 저장
      await apiRepository.addPlanet(_planet);

      // 로컬에 저장
      await LocalStorageService.saveMnemonics([_planet]);

      /// todo : 여기에 다른 지갑 0~20 찾아야함 or parnets planet 으로
      /// (0~20보다 plarents planet 이 나아보임) 왜냐면 우리는 꼭 닉네임 설정해줘야 쓸 수 있기 때문에

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
