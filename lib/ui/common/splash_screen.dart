import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Gif(
            image: AssetImage("assets/icons/planet_gif.gif"),
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
        ],
      ),
    );
  }
}
