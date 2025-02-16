import 'package:flutter/material.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/custom_bottom_sheet_header.dart';
import 'package:planet/ui/util/app_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../custom_theme.dart';
import 'copy_component.dart';

class PlanetAddressBottomSheet extends StatefulWidget {
  final PlanetDto planet;

  const PlanetAddressBottomSheet({
    super.key,
    required this.planet,
  });

  static Future<void> show(
    BuildContext context, {
    required PlanetDto planet,
  }) async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanetAddressBottomSheet(
        planet: planet,
      ),
    );
  }

  @override
  State<PlanetAddressBottomSheet> createState() =>
      _PlanetAddressBottomSheetState();
}

class _PlanetAddressBottomSheetState extends State<PlanetAddressBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              CustomBottomSheetHeader(
                title: widget.planet.networkType?.title ?? "",
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xffEDEDED),
                  ),
                ),
                child: QrImageView(
                  data: widget.planet.address,
                  version: QrVersions.auto,
                  embeddedImage:
                      const AssetImage('assets/icons/ic_qr_image.png'),
                  embeddedImageStyle: const QrEmbeddedImageStyle(
                    size: Size(36, 36),
                  ),
                  size: 180.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 8),
                child: Text(
                  widget.planet.name,
                  style: fontR(
                    24,
                    color: Colors.black,
                  ),
                ),
              ),
              CopyComponent(
                planet: widget.planet,
              ),
              const SizedBox(height: 60),
              Container(
                padding: EdgeInsets.symmetric(horizontal: hPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: _button(
                        title: "Copy",
                        isReverse: true,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _button(
                        title: "Send",
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: AppUi.bottomPadding(context),
              ),
            ],
          )
        ],
      ),
    );
  }

  _button({
    required String title,
    required Function onTap,
    bool isReverse = false,
  }) {
    return BounceButton(
      onTap: () {
        onTap();
      },
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: !isReverse ? Colors.black : Colors.white,
          border: Border.all(
            color: isReverse ? Colors.black : Colors.white,
          ),
        ),
        child: Text(
          title,
          style: fontR(
            18,
            color: isReverse ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
