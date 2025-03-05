import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/generate_planet.dart';
import 'package:planet/ui/common/plannet_background_frame.dart';
import 'package:planet/ui/common/skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../enum/screen_status.dart';
import '../../custom_theme.dart';
import '../../util/app_ui.dart';
import '../../util/bold_generator.dart';
import '../common/copy_component.dart';
import '../common/planet_address_bottom_sheet.dart';
import 'cubit/planets_cubit.dart';

class PlanetsScreen extends StatefulWidget {
  const PlanetsScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const PlanetsScreen());
  }

  @override
  State<PlanetsScreen> createState() => _PlanetsScreenState();
}

class _PlanetsScreenState extends State<PlanetsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => PlanetsCubit(
        apiRepository: context.read<ApiRepository>(),
      )..initialize(),
      child: BlocListener<PlanetsCubit, PlanetsState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<PlanetsCubit, PlanetsState>(
          builder: (context, state) {
            return PlanetBackgroundFrame(
              scale: 3.2,
              topPadding: 60,
              data: state.planet.name.isEmpty
                  ? "shift.function"
                  : state.planet.name,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: AppUi.statusBarHeight(context) + 52,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: hPadding),
                    child: BoldMsgGenerator.toRichText(
                      text: AppLocalizations.of(context)?.explore_friends_planets ?? '',
                      boldStyle:
                          fontB(28, color: C.current.mainText, height: 2),
                      style: fontL(28, color: C.current.mainText),
                    ),
                  ),
                  Expanded(
                    child: state.planet.name.isEmpty
                        ? _isLoading()
                        : CarouselSlider(
                            options: CarouselOptions(
                              onPageChanged: (i, _) {
                                context
                                    .read<PlanetsCubit>()
                                    .onPageUpdate(state.planets[i]);
                              },
                              enlargeCenterPage: true,
                              viewportFraction: 0.7,
                              height: MediaQuery.of(context).size.height,
                            ),
                            items: state.planets.map(
                              (e) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                      alignment: Alignment.center,
                                      child: _card(e),
                                    );
                                  },
                                );
                              },
                            ).toList(),
                          ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _card(Planet e) {
    return BounceButton(
      hasHaptic: true,
      onTap: () {
        PlanetAddressBottomSheet.show(context, planet: e);
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        height: 360,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: C.color(C.current.sub01.withValues(alpha: 0.2),
                C.current.onBackground.withValues(alpha: 0.15)),
          ),
          color: C.color(
            C.current.background.withValues(alpha: 0.3),
            C.current.onBackground.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlanetComponent(data: e.name, size: 180),
            Container(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Text(
                e.name,
                style: fontR(24, color: C.current.mainText),
              ),
            ),
            CopyComponent(
              planet: e,
              onSuccess: () {
                PlanetAddressBottomSheet.show(context, planet: e);
              },
            ),
          ],
        ),
      ),
    );
  }

  _isLoading() {
    return CarouselSlider(
      options: CarouselOptions(
        enlargeCenterPage: true,
        viewportFraction: 0.7,
        height: MediaQuery.of(context).size.height,
      ),
      items: List.generate(
        5,
        (e) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                alignment: Alignment.center,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: 360,
                  width: double.infinity,
                  decoration: const BoxDecoration(),
                  child: const Skeleton(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              );
            },
          );
        },
      ).toList(),
    );
  }
}
