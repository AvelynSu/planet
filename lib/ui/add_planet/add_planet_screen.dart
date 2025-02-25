import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/repository/fb_repository.dart';

import '../../../enum/screen_status.dart';
import '../../custom_theme.dart';
import '../../enum/network_type.dart';
import '../../util/app_ui.dart';
import '../common/base_scaffold.dart';
import '../common/generate_planet.dart';
import '../common/line_text_field.dart';
import '../common/plannet_background_frame.dart';
import '../common/set_nickname_button.dart';
import 'cubit/add_planet_cubit.dart';

class AddPlanetScreen extends StatefulWidget {
  final NetworkType networkType;

  const AddPlanetScreen({
    super.key,
    required this.networkType,
  });

  static push(
    BuildContext context, {
    required NetworkType networkType,
  }) {
    AppUi.push(
        context,
        AddPlanetScreen(
          networkType: networkType,
        ));
  }

  @override
  State<AddPlanetScreen> createState() => _AddPlanetScreenState();
}

class _AddPlanetScreenState extends State<AddPlanetScreen> {
  TextEditingController? _controller;

  bool showGuidMsg = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AddPlanetCubit(
        appBloc: context.read<AppBloc>(),
        networkType: widget.networkType,
        apiRepository: context.read<ApiRepository>(),
      )..initialize(),
      child: BlocListener<AddPlanetCubit, AddPlanetState>(
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
        child: BlocBuilder<AddPlanetCubit, AddPlanetState>(
          builder: (context, state) {
            var cubit = context.read<AddPlanetCubit>();
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
                                child: PlanetComonent(
                                  data: state.nickname,
                                  size: 200,
                                ),
                              ),
                              const SizedBox(height: 80),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SetNicknameButton(
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
                                  SetNicknameButton(
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
}
