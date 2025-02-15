import 'dart:math';

import 'package:bip32/bip32.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';
import '../../../service/wallet/wallet_service.dart';

part 'create_wallet_state.dart';

class CreateWalletCubit extends Cubit<CreateWalletState> {
  CreateWalletCubit() : super(const CreateWalletState());
  final WalletService _walletService = WalletService();

  initialize() {
    var mnemonic = _walletService.generateMnemonic();
    emit(state.copyWith(mnemonic: mnemonic));
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
