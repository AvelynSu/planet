import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/generate_planet.dart';
import 'package:planet/util/app_ui.dart';

import '../../custom_theme.dart';
import '../../enum/network_type.dart';
import '../../service/local_storage_service.dart';
import '../add_planet/add_planet_screen.dart';
import '../common/custom_image.dart';
import '../common/default_dialog.dart';

class PlanetListSettingScreen extends StatefulWidget {
  const PlanetListSettingScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(
      context,
      PlanetListSettingScreen(),
      rootNavigator: true,
    );
  }

  @override
  State<PlanetListSettingScreen> createState() =>
      _PlanetListSettingScreenState();
}

class _PlanetListSettingScreenState extends State<PlanetListSettingScreen> {
  List<Planet> planets = [];
  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    planets = (context.read<AppBloc>().state as AppLoaded).myPlanets;
    subscription = context.read<AppBloc>().stream.listen((e) {
      planets = (e as AppLoaded).myPlanets;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      onBack: () {
        Navigator.pop(context);
      },
      suffix: CustomImage(
        width: 32,
        color: Colors.white,
        path: "icons/ic_plus.svg",
        onTap: () {
          // todo : 최대 20개.=

          var planet = planets
              .where((e) => e.networkType == NetworkType.ethereum)
              .length;

          if (planet < 10) {
            AddPlanetScreen.push(context, networkType: NetworkType.ethereum);
          } else {
            DefaultDialog.showTimerDialog(context,
                description: "네트워크별 최대 10개 생성할 수 있습니다.");
          }
        },
      ),
      body: Column(
        children: [
          ...planets.map(
            (e) => BounceButton(
              child: _item(e),
              onTap: () async {
                await LocalStorageService.saveMnemonics([],
                    isCurrentAddress: e.address);
                context.read<AppBloc>().add(AppUpdate(updateBalance: true));
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  _item(Planet planet) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              PlanetComonent(
                data: planet.name,
                size: 30,
              ),
              const SizedBox(width: 14),
              Text(
                planet.name,
                style: fontR(16, color: C.current.mainText),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                planet.networkType?.title ?? "",
                style: fontR(14, color: C.current.sub01),
              ),
              CustomImage(
                width: 20,
                path: "icons/ic_small_arrow.svg",
                color: C.current.sub01,
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
