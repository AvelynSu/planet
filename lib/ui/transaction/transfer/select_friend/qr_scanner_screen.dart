import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/custom_image.dart';
import 'package:planet/util/address_validator.dart';

import '../../../../util/app_ui.dart';

class QrScannerScreen extends StatefulWidget {
  final NetworkType networkType;

  const QrScannerScreen({
    super.key,
    required this.networkType,
  });

  static Future<String?> push(
    BuildContext context, {
    required NetworkType networkType,
  }) async {
    return await AppUi.push(
        context,
        QrScannerScreen(
          networkType: networkType,
        ));
  }

  @override
  State<QrScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _screenOpened = false;
  bool _torchEnabled = false;
  bool _frontCamera = false;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      isTransparentAppbar: true,
      onBack: () {
        Navigator.pop(context);
      },
      // suffix: Row(
      //   children: [
      //     // 플래시 토글 버튼
      //     IconButton(
      //       icon: Icon(
      //         _torchEnabled ? Icons.flash_on : Icons.flash_off,
      //         color: _torchEnabled ? Colors.yellow : Colors.white,
      //       ),
      //       onPressed: () {
      //         setState(() {
      //           _torchEnabled = !_torchEnabled;
      //           cameraController.toggleTorch();
      //         });
      //       },
      //     ),
      //     // 카메라 전환 버튼
      //     IconButton(
      //       icon: Icon(
      //         _frontCamera ? Icons.camera_front : Icons.camera_rear,
      //       ),
      //       onPressed: () {
      //         setState(() {
      //           _frontCamera = !_frontCamera;
      //           cameraController.switchCamera();
      //         });
      //       },
      //     ),
      //   ],
      // ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _foundBarcode,
          ),
          Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: CustomImage(
                path: "icons/img_qr.svg",
                width: double.infinity,
              ),
            ),
            Text(
              errMsg,
              style: fontR(14, color: primary),
            ),
          ]),
        ],
      ),
    );
  }

  String errMsg = "";

  void _foundBarcode(BarcodeCapture capture) {
    // 중복 스캔 방지
    if (_screenOpened) return;

    final List<Barcode> barcodes = capture.barcodes;
    // QR 코드가 여러 개 인식될 수 있으므로 리스트로 반환됨

    for (final barcode in barcodes) {
      // 결과 처리
      debugPrint('Barcode found! ${barcode.rawValue}');
      _screenOpened = true;
      print(barcode.rawValue);

      if (AddressValidator.isValidAddress(
          widget.networkType, barcode.rawValue ?? "")) {
        Navigator.pop(context, barcode.rawValue);
      } else {
        errMsg = AppLocalizations.of(context)!
            .invalid_address_format(widget.networkType.title(context));
        setState(() {});
      }
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ResultScreen(
      //       value: barcode.rawValue ?? '알 수 없는 값',
      //       onScanAgain: () {
      //         setState(() {
      //           _screenOpened = false;
      //         });
      //       },
      //     ),
      //   ),
      // );
      break; // 첫 번째 QR 코드만 처리
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
