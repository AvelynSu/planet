import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/model/planet.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';

part 'my_state.dart';

class MyCubit extends Cubit<MyState> {
  final AppBloc appBloc;

  MyCubit({
    required this.appBloc,
  }) : super(const MyState()) {
    subscription = appBloc.stream.listen((e) => update(e));
  }

  late StreamSubscription subscription;

  update(AppState appState) {
    if (appState is AppLoaded) {
      emit(state.copyWith(planet: appState.current));
    }
  }

  initialize() async {
    var appState = (appBloc.state as AppLoaded);
    emit(state.copyWith(planet: appState.current));
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
