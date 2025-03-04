import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/custom_image.dart';

import '../../../../util/app_ui.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  static Future<String?> push(BuildContext context) async {
    return await AppUi.push(context, const QrScannerScreen());
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: CustomImage(
              path: "icons/img_qr.svg",
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

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
      Navigator.pop(context, barcode.rawValue);
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
