import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/custom_image.dart';

import '../../../../enum/screen_status.dart';
import '../../../util/app_ui.dart';
import '../../common/planet_nickname_frame.dart';
import 'cubit/change_nickname_cubit.dart';

class ChangeNicknameScreen extends StatefulWidget {
  final Planet planet;

  const ChangeNicknameScreen({
    super.key,
    required this.planet,
  });

  static push(
    BuildContext context, {
    required Planet planet,
  }) {
    AppUi.push(context, ChangeNicknameScreen(planet: planet));
  }

  @override
  State<ChangeNicknameScreen> createState() => _ChangeNicknameScreenState();
}

class _ChangeNicknameScreenState extends State<ChangeNicknameScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ChangeNicknameCubit(
        appBloc: context.read<AppBloc>(),
        apiRepository: context.read<ApiRepository>(),
        planet: widget.planet,
      )..initialize(),
      child: BlocListener<ChangeNicknameCubit, ChangeNicknameState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {
            Navigator.pop(context);
          }
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<ChangeNicknameCubit, ChangeNicknameState>(
          builder: (context, state) {
            var cubit = context.read<ChangeNicknameCubit>();

            return state.status != ScreenStatus.initial
                ? PlanetNicknameFrame(
                    title: AppLocalizations.of(context)
                            ?.change_planet_name_title ??
                        '',
                    status: state.status,
                    exception: state.exception,
                    nickname: state.nickname,
                    onUpdateValue: (value) {
                      cubit.updateValue(value);
                    },
                    onComplete: () {
                      cubit.onUpdateName();
                    },
                  )
                : Container();
          },
        ),
      ),
    );
  }

  _button({
    required Function onTap,
    required String iconPath,
  }) {
    return BounceButton(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: const Color(0xff111117),
          border: Border.all(color: const Color(0xff1E1E28)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: CustomImage(
          path: iconPath,
          width: 40,
        ),
      ),
    );
  }
}
