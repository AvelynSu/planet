import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/service/local_storage_service.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/custom_image.dart';
import 'package:planet/ui/common/default_dialog.dart';
import 'package:planet/ui/util/app_constant.dart';
import 'package:planet/ui/util/bold_generator.dart';

import '../../../enum/screen_status.dart';
import '../common/setting_row_tile.dart';
import '../util/app_ui.dart';
import 'cubit/sample_cubit.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const MyScreen());
  }

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool isDark = true;

  @override
  void initState() {
    isDark = SharedPrefsUtil.getBool(AppConstant.spThemeMode) ?? true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => MyCubit(),
      child: BlocListener<MyCubit, MyState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<MyCubit, MyState>(
          builder: (context, state) {
            var appState = context.read<AppBloc>().state as AppLoaded;

            return Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: AppUi.statusBarHeight(context) + 60,
                  ),
                  BoldMsgGenerator.toRichText(
                    text: "You're on\n*${appState.current.name}*",
                    textAlign: TextAlign.center,
                    style: fontR(24, color: Colors.white, height: 1.5),
                    boldStyle: fontB(24, color: Colors.white),
                  ),
                  const SizedBox(height: 60),
                  Row(
                    children: [
                      Expanded(
                        child: _verticalTile(
                          onTap: () {},
                          title: appState.current.name,
                          iconPath: "icons/ic_qr_image.png",
                        ),
                      ),
                      Expanded(
                        child: _verticalTile(
                          onTap: () {},
                          title: appState.current.name,
                          iconPath: "icons/ic_qr_image.png",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Column(
                    children: [
                      SettingRowTile(onTap: () {}, title: "Announcements"),
                      SettingRowTile(onTap: () {}, title: "FAQ"),
                      SettingRowTile(
                          onTap: () {}, title: "Currency", subText: "USD"),
                      SettingRowTile(
                        onTap: () {},
                        title: "Theme Setting",
                        child: Row(
                          children: [
                            ...[ThemeMode.dark, ThemeMode.light].map((e) {
                              bool isSelected =
                                  e == ThemeMode.dark ? isDark : !isDark;
                              Color color = e == ThemeMode.dark
                                  ? Colors.black
                                  : Colors.white;
                              Color borderColor = e == ThemeMode.dark
                                  ? const Color(0xff5C5964)
                                  : Colors.transparent;
                              return BounceButton(
                                onTap: () {
                                  setThemeTheme(e);
                                },
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: color,
                                    border: Border.all(
                                      color: isSelected ? primary : borderColor,
                                    ),
                                  ),
                                ),
                              );
                            })
                          ],
                        ),
                      ),
                      SettingRowTile(
                        onTap: () {},
                        title: "Version",
                        showArrow: false,
                        subText: "1.0.0",
                      ),
                      SettingRowTile(
                        onTap: () async {
                          var result = await DefaultDialog.show(
                            context,
                            description:
                                "니모닉을 백업 하셨나요?\n니모닉 확인 후 로그아웃 할 수 있습니다.",
                          );
                          context.read<AppBloc>().add(AppSignOut());
                        },
                        title: "Sign Out",
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  setThemeTheme(ThemeMode mode) async {
    await SharedPrefsUtil.setBool(
        AppConstant.spThemeMode, mode == ThemeMode.dark);
    isDark = mode == ThemeMode.dark;
    CustomThemeMode.change(mode);
    setState(() {});
  }

  _verticalTile({
    required Function onTap,
    required String title,
    required String iconPath,
  }) {
    return BounceButton(
      onTap: () {
        onTap();
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            CustomImage(
              path: iconPath,
              width: 40,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: fontR(13, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
