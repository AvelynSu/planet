import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/repository/fb_repository.dart';

import '../../../../enum/screen_status.dart';
import '../../../../model/custom_exception.dart';

part 'sample_state.dart';

class SelectFriendsCubit extends Cubit<SelectFriendsState> {
  final ApiRepository apiRepository;
  final AppBloc appBloc;

  SelectFriendsCubit({
    required this.apiRepository,
    required this.appBloc,
  }) : super(const SelectFriendsState());

  initialize() async {
    var appState = appBloc.state as AppLoaded;
    var planets = await apiRepository.getAllPlanetForTest();

    planets =
        planets.where((e) => e.address != appState.current.address).toList();

    emit(state.copyWith(planets: planets));
  }

  onUpdateSearchValue(String value) {
    emit(state.copyWith(searchText: value));
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
