import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/ui/common/custom_image.dart';
import 'package:planet/ui/common/default_button.dart';

import '../../../enum/screen_status.dart';
import '../util/app_ui.dart';
import 'cubit/sample_cubit.dart';

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
      create: (BuildContext context) => SampleCubit(),
      child: BlocListener<SampleCubit, SampleState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<SampleCubit, SampleState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: CustomColors.current.background,
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
                            CustomImage(
                              path: "icons/ic_planet_logo.png",
                              width: 180,
                            ),
                            Text(
                              'Make Your\nOwn Planet',
                              textAlign: TextAlign.center,
                              style:
                                  fontR(24, color: Colors.white, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        DefaultButton(
                          title: "Create Wallet",
                          onTap: () {},
                        ),
                        const SizedBox(height: 8),
                        DefaultButton(
                          title: "Import Another Planet",
                          onTap: () {},
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
