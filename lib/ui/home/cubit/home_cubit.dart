import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/service/wallet/wallet_balance_service.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';
import '../../../model/token_balance.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AppBloc appBloc;

  HomeCubit({
    required this.appBloc,
  }) : super(const HomeState());

  initialize() async {
    emit(state.copyWith(status: ScreenStatus.loading));
    var current = (appBloc.state as AppLoaded).current;
    emit(state.copyWith(planet: current));
    WalletBalanceService service = WalletBalanceService();

    var balances = await service.getAllTokenBalances(
      walletAddress: current.address,
    );

    emit(state.copyWith(
      planet: current,
      balances: balances,
      status: ScreenStatus.loaded,
    ));
  }

  @override
  Future<void> close() {
    // TODO: implement close
    return super.close();
  }
}
