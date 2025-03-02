import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/custom_bottom_sheet_header.dart';
import 'package:planet/ui/common/default_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../custom_theme.dart';
import '../../util/app_ui.dart';
import '../../util/data/token_data.dart';
import '../transaction/transfer/transfer/transfer_screen.dart';
import '../transaction/transfer/transfer_amount_input/transfer_amount_input_screen.dart';
import 'copy_component.dart';
import 'generate_planet.dart';

class PlanetAddressBottomSheet extends StatefulWidget {
  final Planet planet;

  const PlanetAddressBottomSheet({
    super.key,
    required this.planet,
  });

  static Future<void> show(
    BuildContext context, {
    required Planet planet,
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
  Uint8List? planetImage;
  final GlobalKey planetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _capturePlanetImage();
    });
  }

  Future<void> _capturePlanetImage() async {
    Uint8List? imageData = await captureWidgetAsImage(planetKey);
    if (imageData != null) {
      setState(() {
        planetImage = imageData;
      });
    }
  }

  Future<Uint8List?> captureWidgetAsImage(GlobalKey globalKey,
      {double pixelRatio = 3.0}) async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing widget as image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var current = (context.read<AppBloc>().state as AppLoaded).current;

    return Stack(children: [
      // 숨겨진 PlanetWidget (이미지 변환용)
      Positioned(
        top: -9999, // 화면에 표시되지 않도록 함
        left: -9999,
        child: RepaintBoundary(
          key: planetKey,
          child: Container(
            width: 50,
            height: 50,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
            child: PlanetComonent(
              data: widget.planet.name,
              size: 60, // 원하는 크기
            ),
          ),
        ),
      ),
      Container(
        width: double.infinity,
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                        planetImage != null ? MemoryImage(planetImage!) : null,
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
                          onTap: () async {
                            await Clipboard.setData(
                                ClipboardData(text: widget.planet.address));
                            DefaultDialog.showTimerDialog(context,
                                description: "Success Copy");
                          },
                        ),
                      ),
                      if (current.address != widget.planet.address)
                        const SizedBox(width: 12),
                      if (current.address != widget.planet.address)
                        Expanded(
                          child: _button(
                            title: "Send",
                            onTap: () {
                              var info = TokenData.ethTokens
                                  .where((e) => e.symbol == "ETH")
                                  .first;

                              /// 물량 입력하기
                              TransferAmountInputScreen.push(
                                context,
                                tokenInfo: info,
                                toPlanet: widget.planet,
                                onSelect: (amount) {
                                  print(amount);

                                  /// 가스비 설정
                                  TransferScreen.push(
                                    context,
                                    info: info,
                                    amount: amount,
                                    toPlanet: widget.planet,
                                  );
                                },
                              );
                            },
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
      ),
    ]);
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
