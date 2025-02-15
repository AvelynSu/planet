import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/generate_planet/generate_planet.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/custom_image.dart';
import 'package:planet/ui/common/line_text_field.dart';
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
  late TextEditingController _controller;
  String userInput = "";

  String text = "";
  int idx = 0;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            return PlanetBackgroundFrame(
              data: text,
              scale: 3.8,
              topPadding: 80,
              body: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 150),
                      Text(
                        'My Planet is',
                        style: fontB(28, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      LinedField(
                        hintBorderColor: Colors.transparent,
                        controller: _controller,
                        hintText: "Enter Planet Name",
                        align: TextAlign.center,
                        style: fontR(22, color: primary),
                        onChange: (value) {
                          text = value;
                          userInput = value;
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 100),
                      Container(
                        child: PlanetWidget(
                          data: text,
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
                              String baseText = userInput;

                              if (regex.hasMatch(baseText)) {
                                baseText = baseText.replaceAll(regex, '');
                              }

                              text = "$baseText${Random().nextInt(2000) + 1}";
                              _controller.text = text;
                              setState(() {});
                            },
                            iconPath: "icons/ic_refresh.svg",
                          ),
                          const SizedBox(width: 30),
                          _button(
                            onTap: () {},
                            iconPath: "icons/ic_check.svg",
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
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
