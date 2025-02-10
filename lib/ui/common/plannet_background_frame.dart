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
              /// 행성크게
              Transform.scale(
                scale: 3.3,
                child: Container(
                  margin: const EdgeInsets.only(top: 50),
                  child: PlanetWidget(
                    data: widget.data,
                    size: 172,
                  ),
                ),
              ),

              /// 화면을 꽉 채워주는 그레디언트
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.5, 1],
                    colors: [
                      Colors.black,
                      Colors.black.withValues(alpha: 0.7),
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
