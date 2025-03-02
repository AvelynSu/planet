import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/repository/fb_repository.dart';

import '../../../../enum/screen_status.dart';
import '../../../../util/app_ui.dart';
import '../../common/planet_nickname_frame.dart';
import 'cubit/set_nickname_cubit.dart';

class SetNicknameScreen extends StatefulWidget {
  final Planet planet;

  const SetNicknameScreen({
    super.key,
    required this.planet,
  });

  static push(
    BuildContext context, {
    required Planet planet,
  }) {
    AppUi.push(context, SetNicknameScreen(planet: planet));
  }

  @override
  State<SetNicknameScreen> createState() => _SetNicknameScreenState();
}

class _SetNicknameScreenState extends State<SetNicknameScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SetNicknameCubit(
        appBloc: context.read<AppBloc>(),
        apiRepository: context.read<ApiRepository>(),
        planet: widget.planet,
      )..initialize(),
      child: BlocListener<SetNicknameCubit, SetNicknameState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {
            Navigator.pop(context);
          }
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<SetNicknameCubit, SetNicknameState>(
          builder: (context, state) {
            var cubit = context.read<SetNicknameCubit>();

            return state.status != ScreenStatus.initial
                ? PlanetNicknameFrame(
                    status: state.status,
                    exception: state.exception,
                    nickname: state.nickname,
                    onUpdateValue: (value) {
                      cubit.updateValue(value);
                    },
                    onComplete: () {
                      cubit.onCreatePlanet();
                    },
                  )
                : Container();
          },
        ),
      ),
    );
  }
}
