import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/generate_planet/generate_planet.dart';
import 'package:planet/mock_data.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/common/default_dialog.dart';
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
  String text = "ShiftFunction";
  int idx = 0;

  List<Words> wordItems = [];

  @override
  void initState() {
    wordItems = words.map((e) => Words.fromJson(e)).toList();
    super.initState();
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
            return Scaffold(
              backgroundColor: Colors.black,
              body: PlanetBackgroundFrame(
                data: text,
                body: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 200),
                          child: PlanetWidget(
                            data: text,
                            size: 172,
                          ),
                        ),
                        const SizedBox(height: 60),
                        LinedField(
                          hintText: "Enter Planet Name",
                          align: TextAlign.center,
                          onChange: (value) {
                            text = value;
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 40),
                        DefaultButton(
                          title: "Planet Wallet",
                          color: Colors.white.withValues(alpha: 0.2),
                          textColor: Colors.white,
                          onTap: () {
                            var item = wordItems[
                                Random().nextInt(wordItems.length - 1)];
                            DefaultDialog.show(
                              context,
                              title: item.author,
                              description: item.text,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
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
