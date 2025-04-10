import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:planet/custom_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!kIsWeb)
              Container(
                height: 150,
                width: 150,
                child: Gif(
                  image: AssetImage("assets/icons/planet.gif"),
                  height: 150,
                  width: 150,
                  alignment: Alignment.center,
                  duration: const Duration(seconds: 3),
                  autostart: Autostart.loop,
                ),
              ),
            Text(
              "Planet Wallet",
              style: fontR(24, color: C.current.mainText, isIalic: true),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
