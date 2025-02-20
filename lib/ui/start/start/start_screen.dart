import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gif/gif.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/import_wallet/import_wallet_screen.dart';
import 'package:planet/ui/start/start/cubit/start_cubit.dart';

import '../../../../enum/screen_status.dart';
import '../../create_wallet/create_wallet_screen.dart';
import '../../util/app_ui.dart';

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

                            // CustomImage(
                            //   path: "icons/ic_planet_logo.png",
                            //   width: 180,
                            // ),
                            Text(
                              'Make Your\nOwn Planet',
                              textAlign: TextAlign.center,
                              style: fontR(28,
                                  color: Colors.white,
                                  height: 1.4,
                                  isIalic: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        DefaultButton(
                          color: Colors.white,
                          textColor: Colors.black,
                          title: "Create Wallet",
                          onTap: () {
                            CreateWalletScreen.push(context);
                          },
                        ),
                        const SizedBox(height: 12),
                        DefaultButton(
                          borderColor: Colors.white.withValues(alpha: 0.3),
                          title: "Import Another Planet",
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
