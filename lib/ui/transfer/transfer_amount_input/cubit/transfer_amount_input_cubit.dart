import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/repository/fb_repository.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';
import '../../../../model/token_balance.dart';

part 'transfer_amount_input_state.dart';

class TransferAmountInputCubit extends Cubit<TransferAmountInputState> {
  final TokenInfo tokenInfo;
  final ApiRepository apiRepository;
  final AppBloc appBloc;

  late StreamSubscription subscription;

  TransferAmountInputCubit({
    required this.tokenInfo,
    required this.apiRepository,
    required this.appBloc,
  }) : super(const TransferAmountInputState()) {
    subscription = appBloc.stream.listen((state) {updateApp();});
  }

  updateApp() {
    var appState = appBloc.state as AppLoaded;
    var balances = appState.balance
        .where((e) => e.info.symbol == tokenInfo.symbol)
        .firstOrNull;
    emit(state.copyWith(
        balance: balances ?? TokenBalance.empty, status: ScreenStatus.loaded));
  }

  initialize() async {
    var appState = appBloc.state as AppLoaded;
    var balances = appState.balance
        .where((e) => e.info.symbol == tokenInfo.symbol)
        .firstOrNull;

    emit(state.copyWith(balance: balances));

    appBloc.add(AppUpdate(updateBalance: true));
  }

  /// 받는 양 업데이트
  void updateAmount(String amount) {
    emit(state.copyWith(amount: amount));
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
