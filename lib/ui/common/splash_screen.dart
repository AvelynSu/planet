import 'package:flutter/material.dart';
import 'package:planet/ui/common/plannet_background_frame.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlanetBackgroundFrame(data: "", body: Container()),
    );
  }
}
