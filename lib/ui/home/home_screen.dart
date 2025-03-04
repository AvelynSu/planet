import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:planet/bloc/app/bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/copy_component.dart';
import 'package:planet/ui/common/custom_image.dart';
import 'package:planet/ui/common/generate_planet.dart';
import 'package:planet/ui/common/plannet_background_frame.dart';
import 'package:planet/ui/common/skeleton.dart';
import 'package:planet/ui/home/home_tile.dart';

import '../../../enum/screen_status.dart';
import '../../util/app_ui.dart';
import '../add_planet/planets_top_sheet.dart';
import '../common/planet_address_bottom_sheet.dart';
import '../transaction/transaction_history/token_history_screen.dart';
import 'cubit/home_cubit.dart';

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
              body: RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeCubit>().onUpdate();
                },
                color: C.current.mainText,
                backgroundColor: Colors.transparent,
                displacement: 40,
                strokeWidth: 3,
                child: Stack(
                  children: [
                    Container(
                      height: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: ListView(
                        padding: const EdgeInsets.all(0),
                        children: [
                          SizedBox(height: 52 + AppUi.statusBarHeight(context)),

                          /// 플래닛 이름
                          Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(20),
                                    child: PlanetComponent(
                                      data: state.data,
                                      size: 160,
                                    ),
                                  ),
                                  Lottie.asset("assets/sparkle.json",
                                      width: 200),
                                ],
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(top: 16, bottom: 8),
                                child: Text(
                                  state.planet.name,
                                  style: fontR(
                                    24,
                                    color: C.current.mainText,
                                  ),
                                ),
                              ),
                              CopyComponent(
                                planet: state.planet,
                                onSuccess: () {
                                  PlanetAddressBottomSheet.show(context,
                                      planet: state.planet);
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),
                          if (state.status == ScreenStatus.loading)
                            Column(
                              children: [
                                ...List.generate(5, (e) => Skeleton.homeTile),
                              ],
                            ),
                          ...state.balances.map(
                            (e) => BounceButton(
                              onTap: () {
                                TransactionHistoryScreen.push(context, info: e);
                              },
                              child: HomeTile(item: e),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// 앱바
                    Container(
                      margin:
                          EdgeInsets.only(top: AppUi.statusBarHeight(context)),
                      child: BounceButton(
                        onTap: () {
                          PlanetsTopSheet.show(context);
                        },
                        child: _appBar(state),
                      ),
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

  _planetRow(Planet planet) {
    return Row(
      children: [
        PlanetComponent(
          data: planet.name,
          size: 20,
        ),
        Text(
          planet.name,
          style: fontR(16, color: C.current.mainText),
        ),
      ],
    );
  }

  _appBar(HomeState state) {
    return Container(
      color: Colors.transparent,
      height: 52,
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Container(
          //   // path: "icons/ic_planet.svg",
          //   // color: C.current.sub01,
          //   width: 32,
          // ),
          Text(
            state.planet.networkType?.title ?? "",
            style: fontR(18, color: C.current.onBackground),
          ),
          const SizedBox(width: 4),
          CustomImage(
            width: 20,
            rotate: pi / 2,
            path: "icons/ic_small_arrow.svg",
            color: C.current.onBackground,
          )
        ],
      ),
    );
  }
}
