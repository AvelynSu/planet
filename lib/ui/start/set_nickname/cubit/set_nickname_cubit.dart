import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';

part 'set_nickname_state.dart';

class SetNicknameCubit extends Cubit<SetNicknameState> {
  SetNicknameCubit() : super(const SetNicknameState());

  initialize() async {}

  @override
  Future<void> close() {
    // TODO: implement close
    return super.close();
  }
}
