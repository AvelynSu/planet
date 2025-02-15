import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';

part 'sample_state.dart';

class PlanetsCubit extends Cubit<PlanetsState> {
  PlanetsCubit() : super(const PlanetsState());

  initialize() async {}

  @override
  Future<void> close() {
    // TODO: implement close
    return super.close();
  }
}
