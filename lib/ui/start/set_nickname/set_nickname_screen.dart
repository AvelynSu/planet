import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/generate_planet/generate_planet.dart';
import 'package:planet/ui/common/plannet_background_frame.dart';
import 'package:planet/ui/start/set_nickname/cubit/set_nickname_cubit.dart';

import '../../../../enum/screen_status.dart';
import '../../util/app_ui.dart';

class SetNicknameScreen extends StatefulWidget {
  const SetNicknameScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const SetNicknameScreen());
  }

  @override
  State<SetNicknameScreen> createState() => _SetNicknameScreenState();
}

class _SetNicknameScreenState extends State<SetNicknameScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SetNicknameCubit(),
      child: BlocListener<SetNicknameCubit, SetNicknameState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<SetNicknameCubit, SetNicknameState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: PlanetBackgroundFrame(
                data: state.nickname,
                body: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 160),
                        child: PlanetWidget(
                          data: state.nickname,
                          size: 172,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
