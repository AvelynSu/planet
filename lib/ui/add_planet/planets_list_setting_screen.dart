import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/custom_toggle.dart';
import 'package:planet/ui/common/generate_planet.dart';
import 'package:planet/util/app_ui.dart';

import '../../custom_theme.dart';
import '../../enum/network_type.dart';
import '../../service/local_storage_service.dart';
import '../common/custom_image.dart';
import '../common/default_dialog.dart';
import 'add_planet_screen.dart';

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
    planets = (context.read<AppBloc>().state as AppLoaded).planets;
    subscription = context.read<AppBloc>().stream.listen((e) {
      planets = (e as AppLoaded).planets;
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
        path: "icons/ic_add_planet.svg",
        onTap: () {
          AddPlanetScreen.push(context, networkType: NetworkType.ethereum);
        },
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'My Planets',
                style: fontR(14, color: C.current.sub01),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...planets.map(
                      (e) => GestureDetector(
                        child: _item(
                          e,
                          onChangeStatus: () async {
                            var result = await DefaultDialog.show(
                              context,
                              description: "Would you like to hide the planet?",
                              onSecondAction: () {},
                            );

                            if (result ?? false) {
                              await context
                                  .read<ApiRepository>()
                                  .hidePlanet(e, !e.isDeleted);
                              context.read<AppBloc>().add(AppUpdate());
                            }
                          },
                        ),
                        onTap: () async {
                          await LocalStorageService.saveMnemonics([],
                              isCurrentAddress: e.address);
                          context
                              .read<AppBloc>()
                              .add(AppUpdate(updateBalance: true));
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _item(
    Planet planet, {
    required Function onChangeStatus,
  }) {
    var current = (context.read<AppBloc>().state as AppLoaded).current;
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              PlanetComponent(
                network: planet.networkType,
                data: planet.name,
                size: 30,
              ),
              const SizedBox(width: 14),
              Text(
                planet.name,
                style: fontR(16, color: C.current.mainText),
              ),
              const SizedBox(width: 8),
              Text(
                planet.networkType?.symbol ?? "",
                style: fontR(14, color: C.current.sub01),
              ),
            ],
          ),
          Row(
            children: [
              (current.address != planet.address)
                  ? GestureDetector(
                      onTap: () {
                        onChangeStatus();
                      },
                      child: CustomToggle(value: !planet.isDeleted),
                    )
                  : Text(
                      'Current',
                      style: fontM(14, color: C.current.sub01),
                    ),
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
