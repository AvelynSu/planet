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
import '../../../../service/wallet/wallet_service.dart';

part 'create_wallet_state.dart';

class CreateWalletCubit extends Cubit<CreateWalletState> {
  final AppBloc appBloc;
  final ApiRepository apiRepository;

  CreateWalletCubit({
    required this.appBloc,
    required this.apiRepository,
  }) : super(const CreateWalletState());
  final WalletService _walletService = WalletService();

  initialize() {
    var mnemonic = _walletService.generateMnemonic();
    emit(state.copyWith(mnemonic: mnemonic));
  }

  updateNetworkType(NetworkType networkType) {
    emit(state.copyWith(networkType: networkType));
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

  Future<Planet?> onGetRequiredPlanet() async {
    emit(state.copyWith(status: ScreenStatus.loading));
    var planet = await apiRepository.getRequiredNicknamePlanet(
      mnemonic: state.mnemonic,
      onAppInitialize: () {
        appBloc.add(AppInitialize());
      },
    );
    emit(state.copyWith(status: ScreenStatus.loaded));
    return planet;
  }
}
