import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/model/planet_dto.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';
import '../../../model/token_balance.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AppBloc appBloc;

  HomeCubit({
    required this.appBloc,
  }) : super(const HomeState()) {
    _subscription =
        appBloc.stream.listen((state) => updateApp(state as AppLoaded));
  }

  late StreamSubscription _subscription;

  updateApp(AppLoaded appState) {
    emit(state.copyWith(
        balances: appState.balance,
        planet: appState.current,
        status: ScreenStatus.loaded));
  }

  initialize() async {
    emit(state.copyWith(status: ScreenStatus.loading));
    updateApp(appBloc.state as AppLoaded);

    appBloc.add(AppUpdate(updateBalance: true));

    // WalletBalanceService service = WalletBalanceService();
    // var balances = await service.getAllTokenBalances(
    //   walletAddress: current.address,
    // );
  }

  onUpdate() async {
    if (state.status != ScreenStatus.loading) {
      emit(state.copyWith(status: ScreenStatus.loading, balances: []));
      appBloc.add(AppUpdate(updateBalance: true));
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
