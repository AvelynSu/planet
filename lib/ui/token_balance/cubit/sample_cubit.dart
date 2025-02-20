import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/model/token_balance.dart';
import 'package:planet/model/transaction_history.dart';
import 'package:planet/service/wallet/transaction_history_service.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';

part 'sample_state.dart';

class TokenBalanceCubit extends Cubit<TokenBalanceState> {
  final AppBloc appBloc;
  final TokenBalance initialValue;

  StreamSubscription? appSubscription;

  TokenBalanceCubit({
    required this.appBloc,
    required this.initialValue,
  }) : super(const TokenBalanceState()) {
    appSubscription = appBloc.stream.listen((state) => initialize());
  }

  final service = WalletHistoryService();

  initialize() async {
    var appState = appBloc.state as AppLoaded;
    updatePlanet(appState);
  }

  updatePlanet(AppLoaded appState) async {
    emit(state.copyWith(status: ScreenStatus.loading));
    var planet = appState.planets
        .where((e) => e.address == initialValue.address)
        .firstOrNull;

    var history = await service.getSpecificTokenTransactions(
      initialValue.address,
      initialValue.info.address,
    );
    emit(state.copyWith(planet: planet, items: history));
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
