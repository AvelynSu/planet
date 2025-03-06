import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gif/gif.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/common/small_round_button.dart';
import 'package:planet/ui/start/start/cubit/start_cubit.dart';

import '../../../../enum/screen_status.dart';
import '../../../service/global_service.dart';
import '../../../service/local_storage_service.dart';
import '../../../util/app_constant.dart';
import '../../../util/app_ui.dart';
import '../../../util/data/planet_name_data.dart';
import '../../my/change_locale_bottom_sheet.dart';
import '../create_wallet/create_wallet_screen.dart';
import '../import_wallet/import_wallet_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const StartScreen());
  }

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    var setting = context.watch<GlobalService>();
    return BlocProvider(
      create: (BuildContext context) => StartCubit(),
      child: BlocListener<StartCubit, StartState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<StartCubit, StartState>(
          builder: (context, state) {
            var localeKey =
                SharedPrefsUtil.getString(AppConstant.locale) ?? "en";

            var locale =
                Data.locale.where((e) => e.key == localeKey).firstOrNull;

            return Scaffold(
              backgroundColor: C.current.background,
              body: Container(
                padding: EdgeInsets.symmetric(horizontal: hPadding),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Gif(
                              image: AssetImage("assets/icons/planet.gif"),
                              width: 200,
                              duration: const Duration(seconds: 3),
                              autostart: Autostart.loop,
                            ),
                            Text(
                              AppLocalizations.of(context)?.start_tagline ?? '',
                              textAlign: TextAlign.center,
                              style: fontR(28,
                                  color: Colors.white,
                                  height: 1.4,
                                  isIalic: true),
                            ),
                            Container(
                              height: 36,
                              margin: EdgeInsets.only(top: 24),
                              child: SmallRoundButton(
                                onTap: () async {
                                  await ChangeLocaleBottomSheet.show(context);
                                  setState(() {});
                                },
                                isIconLeft: false,
                                iconRotate: pi / 2,
                                iconSize: 16,
                                iconColor:
                                    C.current.mainText.withValues(alpha: 0.5),
                                iconPath: "icons/ic_small_arrow.svg",
                                title: " ${locale?.title ?? ""} ",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        DefaultButton(
                          title: AppLocalizations.of(context)
                                  ?.start_create_planet ??
                              '',
                          onTap: () {
                            CreateWalletScreen.push(context);
                          },
                        ),
                        const SizedBox(height: 12),
                        DefaultButton(
                          isReverse: true,
                          title: AppLocalizations.of(context)
                                  ?.start_import_planet ??
                              '',
                          onTap: () {
                            ImportWalletScreen.push(context);
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: AppUi.bottomPadding(context) + 100,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
