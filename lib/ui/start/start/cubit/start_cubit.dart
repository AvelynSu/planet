import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';

part 'start_state.dart';

class StartCubit extends Cubit<StartState> {
  StartCubit() : super(const StartState());

  initialize() async {}

  @override
  Future<void> close() {
    // TODO: implement close
    return super.close();
  }
}
