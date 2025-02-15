import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/ui/common/copy_component.dart';
import 'package:planet/ui/common/generate_planet.dart';
import 'package:planet/ui/common/plannet_background_frame.dart';

import '../../../enum/screen_status.dart';
import '../util/app_ui.dart';
import 'cubit/sample_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const HomeScreen());
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => HomeCubit(
        appBloc: context.read<AppBloc>(),
      )..initialize(),
      child: BlocListener<HomeCubit, HomeState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return PlanetBackgroundFrame(
              scale: 3.2,
              topPadding: 50,
              data: state.data,
              body: Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: AppUi.statusBarHeight(context),
                    ),
                    Container(height: 68),

                    /// 플래닛 이름
                    Column(
                      children: [
                        PlanetWidget(
                          data: state.data,
                          size: 160,
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 20, bottom: 8),
                          child: Text(
                            state.planet.name,
                            style: fontR(
                              24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        CopyComponent(
                          value: state.planet.address,
                        ),
                      ],
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
