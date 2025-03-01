import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/repository/fb_repository.dart';

import '../../../../bloc/app/app_event.dart';
import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';
import '../../../../service/local_storage_service.dart';
import '../../../../service/wallet/wallet_service.dart';

part 'import_wallet_state.dart';

class ImportWalletCubit extends Cubit<ImportWalletState> {
  final AppBloc appBloc;
  final ApiRepository apiRepository;

  ImportWalletCubit({
    required this.appBloc,
    required this.apiRepository,
  }) : super(const ImportWalletState());
  final WalletService _walletService = WalletService();

  String getTestValue() {
    return _walletService.generateMnemonic();
  }

  updateMnimonic(String value) {
    emit(state.copyWith(mnemonic: value));
  }

  Future<Planet> getAddress() async {
    try {
      emit(state.copyWith(status: ScreenStatus.loading));

      // 니모닉으로 주소 불러오기 시작은 path 무조건 0
      var address = await _walletService.generateHDAddress(
          NetworkType.ethereum, state.mnemonic, 0);

      // fb에서 등록된 지갑인지 가져오기
      var planet = await apiRepository.getPlanetByAddress(address);
      if (planet == Planet.empty) {
        // 등록된 지갑이 아니면 빈 Planet 생성
        planet = Planet(
          networkType: NetworkType.ethereum,
          address: address,
          mnemonic: state.mnemonic,
        );
      } else {
        // 등록된 행성이면 로컬에 저장하고 앱 시작
        planet = planet.copyWith(mnemonic: state.mnemonic);

        /// todo : 여기에 다른 지갑 0~20 찾아야함 or parnets planet 으로
        /// (0~20보다 plarents planet 이 나아보임) 왜냐면 우리는 꼭 닉네임 설정해줘야 쓸 수 있기 때문에

        List<Planet> childs = await apiRepository.getChildPlanets(planet);
        childs =
            childs.map((e) => e.copyWith(mnemonic: state.mnemonic)).toList();

        await LocalStorageService.saveMnemonics(childs);

        appBloc.add(AppInitialize());
        emit(state.copyWith(status: ScreenStatus.success));
      }

      return planet;
    } on CustomException catch (err) {
      emit(state.copyWith(status: ScreenStatus.fail, exception: err));
    }
    return Planet.empty;
  }

  /// 네트워크 타입 선택
  onSelectNetworkType(NetworkType type) {}

  /// 페이지 업데이트
  // 0 : 니모닉 보여주기
  // 1 : 니모닉 맞춰보기
  // 2 : 네트워크 타입 설정
  updatePage(int page) {
    emit(state.copyWith(page: max(0, min(2, page))));
  }
}
