import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:gif/gif.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Gif(
              width: 100,
              height: 100,
              image: AssetImage("assets/icons/planet.gif"),
              // controller: _controller,
              // // if duration and fps is null, original gif fps will be used.
              // //fps: 30,
              duration: const Duration(seconds: 3),
              autostart: Autostart.loop,
              // placeholder: (context) => const Text('Loading...'),
              // onFetchCompleted: () {
              //   _controller.reset();
              //   _controller.forward();
              // },
            ),
            const SizedBox(height: 24),
            Text(
              "Version Update",
              style: fontR(20, color: C.current.mainText),
            ),
            const SizedBox(height: 12),
            Text(
              "A new Planet Wallet version\nupdate is now available.",
              textAlign: TextAlign.center,
              style: fontM(16, color: C.current.mainText),
            ),
            const SizedBox(height: 28),
            DefaultButton(
              title: "Update",
              isReverse: true,
              onTap: () {
                launchAppStore();
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> launchAppStore() async {
    final String appId;
    final Uri url;

    if (Platform.isAndroid) {
      // Android - Play Store
      appId = 'com.shiftfn.planet'; // 앱의 패키지 이름으로 변경
      url = Uri.parse('https://play.google.com/store/apps/details?id=$appId');
    } else if (Platform.isIOS) {
      // iOS - App Store
      appId = '1475617245'; // 앱의 App Store ID로 변경
      url = Uri.parse('https://apps.apple.com/app/id$appId');
    } else {
      // 지원하지 않는 플랫폼
      return;
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw '스토어를 열 수 없습니다: $url';
    }
  }
}
