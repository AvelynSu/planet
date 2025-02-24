import 'package:flutter/cupertino.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/ui/common/generate_planet.dart';

import '../../../util/app_util.dart';

class TransferProfileComponent extends StatelessWidget {
  final Planet planet;
  final double size;
  final bool isSimpleMode;
  final bool enableAddress;
  final bool enablePlanet;

  const TransferProfileComponent({
    super.key,
    required this.planet,
    this.isSimpleMode = false,
    this.enableAddress = true,
    this.enablePlanet = true,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (isSimpleMode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PlanetWidget(
            data: planet.name,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            planet.name,
            style: fontR(18, color: C.current.mainText),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (enablePlanet)
          Container(
            margin: EdgeInsets.only(right: 12 * (size / 40)),
            child: PlanetWidget(
              data: planet.name,
              size: size,
            ),
          ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              planet.name,
              style: fontR(18, color: C.current.mainText),
            ),
            if (enableAddress)
              Container(
                margin: const EdgeInsets.only(top: 4),
                child: Text(
                  AppUtil.shortenWalletAddress(planet.address),
                  style: fontR(14, color: C.current.sub01),
                ),
              ),
          ],
        )
      ],
    );
  }
}
