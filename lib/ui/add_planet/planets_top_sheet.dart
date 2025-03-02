import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/ui/add_planet/add_planet_screen.dart';
import 'package:planet/ui/add_planet/planets_list_setting_screen.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/generate_planet.dart';
import 'package:planet/ui/common/small_round_button.dart';

import '../../custom_theme.dart';
import '../../service/local_storage_service.dart';
import '../common/custom_image.dart';
import '../common/top_sheet.dart';

class PlanetsTopSheet extends StatefulWidget {
  const PlanetsTopSheet({super.key});

  static show(BuildContext context) {
    showTopSheet(context, const PlanetsTopSheet());
  }

  @override
  State<PlanetsTopSheet> createState() => _PlanetsTopSheetState();
}

class _PlanetsTopSheetState extends State<PlanetsTopSheet> {
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
    return Column(
      children: [
        const SizedBox(height: 12),
        ...planets.map((e) {
          if (e.isDeleted) {
            return Container();
          }
          return BounceButton(
            child: _item(e),
            onTap: () async {
              await LocalStorageService.saveMnemonics([],
                  isCurrentAddress: e.address);
              context.read<AppBloc>().add(AppUpdate(updateBalance: true));
              Navigator.pop(context);
            },
          );
        }),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 32),
            SmallRoundButton(
              backgroundColor: C.current.sub02,
              onTap: () {
                AddPlanetScreen.push(context,
                    networkType: NetworkType.ethereum);
              },
              iconPath: "icons/ic_planet.svg",
              title: "Add New Planet",
            ),
            CustomImage(
              onTap: () {
                Navigator.pop(context);
                PlanetListSettingScreen.push(context);
              },
              path: "icons/ic_setting.svg",
              width: 32,
              color: C.current.sub01,
            )
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  _item(Planet planet) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
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
