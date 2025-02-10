import 'package:flutter/material.dart';

import '../../generate_planet/generate_planet.dart';

class PlanetBackgroundFrame extends StatefulWidget {
  final String data;
  final Widget body;

  const PlanetBackgroundFrame({
    super.key,
    required this.data,
    required this.body,
  });

  @override
  State<PlanetBackgroundFrame> createState() => _PlanetBackgroundFrameState();
}

class _PlanetBackgroundFrameState extends State<PlanetBackgroundFrame> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          /// 뒷배경 백그라운드
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Transform.scale(
                scale: 3.3,
                child: PlanetWidget(
                  data: widget.data,
                  size: 172,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 300),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ],
          ),

          /// 실제 바디
          widget.body,
        ],
      ),
    );
  }
}
