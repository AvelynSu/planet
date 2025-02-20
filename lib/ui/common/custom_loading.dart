import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Container(
        width: 60,
        height: 60,
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Gif(
          width: 42,
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
      ),
    );
  }
}
