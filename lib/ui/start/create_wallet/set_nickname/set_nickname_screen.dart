import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/custom_image.dart';
import 'package:planet/ui/common/generate_planet.dart';
import 'package:planet/ui/common/line_text_field.dart';
import 'package:planet/ui/common/plannet_background_frame.dart';

import '../../../../enum/screen_status.dart';
import '../../../../util/app_ui.dart';
import 'cubit/set_nickname_cubit.dart';

class SetNicknameScreen extends StatefulWidget {
  final PlanetDto planetDto;

  const SetNicknameScreen({
    super.key,
    required this.planetDto,
  });

  static push(
    BuildContext context, {
    required PlanetDto planetDto,
  }) {
    AppUi.push(context, SetNicknameScreen(planetDto: planetDto),
        enablePushAnimation: false, enablePopAnimation: false);
  }

  @override
  State<SetNicknameScreen> createState() => _SetNicknameScreenState();
}

class _SetNicknameScreenState extends State<SetNicknameScreen> {
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
  }

  bool showGuidMsg = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SetNicknameCubit(
        appBloc: context.read<AppBloc>(),
        apiRepository: context.read<ApiRepository>(),
        planetDto: widget.planetDto,
      )..initialize(),
      child: BlocListener<SetNicknameCubit, SetNicknameState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.loaded) {
            if (_controller == null) {
              _controller = TextEditingController();
              _controller?.text = state.nickname;
              setState(() {});
            }
          }

          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {
            Navigator.pop(context);
          }
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<SetNicknameCubit, SetNicknameState>(
          builder: (context, state) {
            var cubit = context.read<SetNicknameCubit>();
            return BaseScaffold(
              onLoading: state.status == ScreenStatus.loading,
              body: PlanetBackgroundFrame(
                data: state.nickname,
                scale: 3.8,
                topPadding: 80,
                body: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SingleChildScrollView(
                    child: state.status != ScreenStatus.initial
                        ? Column(
                            children: [
                              const SizedBox(height: 150),
                              Text(
                                'My Planet is',
                                style: fontB(28,
                                    color: Colors.white, isIalic: true),
                              ),
                              const SizedBox(height: 12),
                              LinedField(
                                hintBorderColor: Colors.transparent,
                                inputFormatters: [
                                  TextInputFormatter.withFunction(
                                      (oldValue, newValue) {
                                    final lowerCaseText =
                                        newValue.text.toLowerCase();
                                    final regExp = RegExp(r'^[a-z0-9._]*$');

                                    if (regExp.hasMatch(lowerCaseText)) {
                                      return TextEditingValue(
                                        text: lowerCaseText,
                                        selection: newValue.selection,
                                      );
                                    }
                                    return oldValue;
                                  }),
                                ],
                                controller: _controller,
                                initialValue: state.nickname,
                                hintText: "Enter Planet Name",
                                align: TextAlign.center,
                                style: fontR(22, color: primary),
                                onChange: (value) {
                                  cubit.updateValue(value);
                                },
                              ),
                              if (showGuidMsg &&
                                  state.status != ScreenStatus.fail)
                                Container(
                                  margin: EdgeInsets.only(top: 4),
                                  child: Text(
                                    "You can change your planet name",
                                    style: fontR(14, color: C.current.sub01),
                                  ),
                                ),
                              if (state.status == ScreenStatus.fail)
                                Container(
                                  margin: EdgeInsets.only(top: 12),
                                  child: Text(
                                    state.exception.errMsg ?? "",
                                    style: fontR(14, color: primary),
                                  ),
                                ),
                              const SizedBox(height: 100),
                              Container(
                                child: PlanetWidget(
                                  data: state.nickname,
                                  size: 200,
                                ),
                              ),
                              const SizedBox(height: 80),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _button(
                                    onTap: () {
                                      RegExp regex = RegExp(r'\d+$');
                                      String baseText = state.nickname;

                                      if (regex.hasMatch(baseText)) {
                                        baseText =
                                            baseText.replaceAll(regex, '');
                                      }

                                      String updateNickname =
                                          "$baseText${Random().nextInt(2000) + 1}";
                                      cubit.updateValue(updateNickname);
                                      _controller?.text = updateNickname;
                                      setState(() {});
                                    },
                                    iconPath: "icons/ic_refresh.svg",
                                  ),
                                  const SizedBox(width: 30),
                                  _button(
                                    onTap: () {
                                      cubit.onCreatePlanet();
                                    },
                                    iconPath: "icons/ic_check.svg",
                                  ),
                                ],
                              ),
                              const SizedBox(height: 60),
                            ],
                          )
                        : Container(),
                  ),
                ),
              ),
            );
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
