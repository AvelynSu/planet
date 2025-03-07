import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/model/planet.dart';

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
        appBloc.stream.listen((state) => _update(state as AppLoaded));
  }

  late StreamSubscription _subscription;

  _update(AppLoaded appState) {
    emit(
      state.copyWith(
        balances: appState.balances,
        planet: appState.current,
        status: appState.isLoading ? ScreenStatus.loading : ScreenStatus.loaded,
      ),
    );
  }

  initialize() async {
    emit(state.copyWith(status: ScreenStatus.loading));
    _update(appBloc.state as AppLoaded);

    // var current = appBloc.state as AppLoaded;
    // if ()

    // 홈화면 눌러서 돌아올때마다 업데이트해줘야 하므로
    // appBloc.add(AppUpdate(updateBalance: true));
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
