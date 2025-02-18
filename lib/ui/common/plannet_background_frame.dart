import 'package:flutter/material.dart';

import '../../custom_theme.dart';
import 'generate_planet.dart';

class PlanetBackgroundFrame extends StatefulWidget {
  final String data;
  final Widget body;
  final double topPadding;
  final double scale;

  const PlanetBackgroundFrame({
    super.key,
    required this.data,
    required this.body,
    this.scale = 3.3,
    this.topPadding = 50,
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
                scale: widget.scale,
                child: Container(
                  margin: EdgeInsets.only(top: widget.topPadding),
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
                    stops: [(CustomThemeMode.isLight ? 0.35 : 0.3), 1],
                    colors: [
                      C.current.background,
                      C.current.background.withValues(
                          alpha: CustomThemeMode.isLight ? 0.82 : 0.7),
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
