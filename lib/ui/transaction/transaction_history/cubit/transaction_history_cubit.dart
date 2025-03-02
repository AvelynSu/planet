import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/model/token_balance.dart';
import 'package:planet/model/transaction_history.dart';
import 'package:planet/service/wallet/wallet_transaction/transaction_history_service.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';

part 'transaction_history_state.dart';

class TransactionBalanceCubit extends Cubit<TransactionHistoryState> {
  final AppBloc appBloc;
  final TokenBalance initialValue;

  StreamSubscription? appSubscription;

  TransactionBalanceCubit({
    required this.appBloc,
    required this.initialValue,
  }) : super(const TransactionHistoryState()) {
    appSubscription = appBloc.stream.listen((state) => _update());
  }

  final service = WalletHistoryService();

  _update() async {
    var appState = appBloc.state as AppLoaded;
    var balance = appState.balances
        .where((e) => e.info.symbol == initialValue.info.symbol)
        .first;
    emit(state.copyWith(
      status: ScreenStatus.loaded,
      planet: appState.current,
      balance: balance,
    ));
  }

  initialize() async {
    try {
      if (state.status != ScreenStatus.loading) {
        var appState = appBloc.state as AppLoaded;
        emit(state.copyWith(status: ScreenStatus.loading, items: []));
        var planet = appState.current;
        var history = await service.getSpecificTokenTransactions(
          address: initialValue.address,
          info: initialValue.info,
        );
        emit(state.copyWith(
            planet: planet, balance: initialValue, items: history));

        await Future.delayed(const Duration(milliseconds: 50));
        appBloc.add(AppUpdate(updateBalanceToken: initialValue.info));
      }
    } catch (err) {
      emit(state.copyWith(status: ScreenStatus.loaded, items: []));
    }
  }

  @override
  Future<void> close() {
    appSubscription?.cancel();
    return super.close();
  }
}
