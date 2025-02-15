import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/model/planet_dto.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';

part 'sample_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AppBloc appBloc;

  HomeCubit({
    required this.appBloc,
  }) : super(const HomeState());

  initialize() async {
    var current = (appBloc.state as AppLoaded).current;
    emit(state.copyWith(planet: current));
  }

  @override
  Future<void> close() {
    // TODO: implement close
    return super.close();
  }
}
