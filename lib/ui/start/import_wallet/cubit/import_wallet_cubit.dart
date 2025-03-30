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

part 'import_wallet_state.dart';

class ImportWalletCubit extends Cubit<ImportWalletState> {
  final AppBloc appBloc;
  final ApiRepository apiRepository;

  ImportWalletCubit({
    required this.appBloc,
    required this.apiRepository,
  }) : super(const ImportWalletState());
  final WalletService _walletService = WalletService();

  updateMnimonic(String value) {
    emit(state.copyWith(mnemonic: value));
  }

  // 이 니모닉에 닉네임 세팅해야할 니모닉 주소 있는지 확인
  Future<Planet?> getRequiredNicknamePlanet() async {
    try {
      emit(state.copyWith(status: ScreenStatus.loading));
      var planet = await apiRepository.getRequiredNicknamePlanet(
        mnemonic: state.mnemonic,
        onAppInitialize: () {
          appBloc.add(AppInitialize());
          emit(state.copyWith(status: ScreenStatus.success));
        },
      );
      return planet;
    } on CustomException catch (err) {
      emit(state.copyWith(status: ScreenStatus.fail, exception: err));
    }
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
