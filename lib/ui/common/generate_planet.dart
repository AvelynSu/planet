import 'dart:convert';
import 'dart:math' show sqrt, pow, pi, cos, sin;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class PlanetComponent extends StatelessWidget {
  final String data;
  final double size;
  late final Uint8List hash;

  static const List<Color> colors = [
    Color(0xFFFFFD00),
    Color(0xFFFEB900),
    Color(0xFFEFA288),
    Color(0xFFEEA5B0),
    Color(0xFFFF99D6),
    Color(0xFFDD9278),
    Color(0xFFFC8F79),
    Color(0xFFE45641),
    Color(0xFFE62D38),
    Color(0xFFF94A62),
    Color(0xFFEB526F),
    Color(0xFFFF54B0),
    Color(0xFFFA198C),
    Color(0xFFC5147D),
    Color(0xFFE1A9E8),
    Color(0xFF9B5FE5),
    Color(0xFF7C00C7),
    Color(0xFF531CB3),
    Color(0xFFCCFF66),
    Color(0xFF00E291),
    Color(0xFF35D1BF),
    Color(0xFF028A81),
    Color(0xFF0A3748),
    Color(0xFF4F51B3),
    Color(0xFF1D00FF),
    Color(0xFF090080),
    Color(0xFF0A104D),
    Color(0xFF575756),
  ];
  static const List<Color> bitcoinColors = [
    Color(0xFFF7931A), // 비트코인 오렌지
    Color(0xFFFFAB2E), // 밝은 오렌지
    Color(0xFFFFD700), // 골드
    Color(0xFFFFE55C), // 밝은 골드
    Color(0xFFCC9900), // 어두운 골드
    Color(0xFFEFD8A4), // 밝은 황갈색
    Color(0xFFD1A75C), // 황동색
    Color(0xFFAB8428), // 브론즈
    Color(0xFF8B6914), // 어두운 황금색
    Color(0xFF7E5109), // 앰버
    Color(0xFF654321), // 어두운 브라운
    Color(0xFFAD6F33), // 구리색
    Color(0xFFCF7F00), // 황갈색
    Color(0xFFB34700), // 구릿빛 오렌지
    Color(0xFFDAAA00), // 사파이어 옐로우
    Color(0xFFDAA520), // 골든로드
    Color(0xFFCD853F), // 페루
    Color(0xFFD2B48C), // 탄
    Color(0xFFBDB76B), // 다크카키
    Color(0xFF8B4513), // 새들 브라운
    Color(0xFF493424), // 다크 브라운
    Color(0xFF332211), // 짙은 갈색
    Color(0xFF211A0E), // 거의 검은색
    Color(0xFF554433), // 중간 갈색
    Color(0xFF473826), // 푸른빛 갈색
    Color(0xFF2D2011), // 초콜릿
    Color(0xFF513F32), // 호두색
    Color(0xFF664228), // 시에나
  ];

  static const List<Color> solanaColors = [
    Color(0xFF00FFBD), // 솔라나 그린
    Color(0xFF00C2FF), // 솔라나 블루
    Color(0xFF9945FF), // 솔라나 퍼플
    Color(0xFF14F195), // 밝은 민트
    Color(0xFF00E4C5), // 아쿠아마린
    Color(0xFF00D2FF), // 밝은 시안
    Color(0xFF19B6FF), // 스카이 블루
    Color(0xFF0072FF), // 브라이트 블루
    Color(0xFF7B61FF), // 연보라
    Color(0xFFAB71FF), // 라일락
    Color(0xFF7957FB), // 중간 퍼플
    Color(0xFF6647D7), // 라벤더
    Color(0xFF5636C5), // 인디고
    Color(0xFF4C26B6), // 바이올렛
    Color(0xFF3A1D8C), // 다크 퍼플
    Color(0xFF2C1675), // 진한 자주색
    Color(0xFF05C2BD), // 터키 청록색
    Color(0xFF08A5D1), // 페리윙클
    Color(0xFF0090EA), // 코발트 블루
    Color(0xFF2B77E5), // 로얄 블루
    Color(0xFF00BDAC), // 비취색
    Color(0xFF29B4A4), // 열대 청록색
    Color(0xFF287AB8), // 스틸 블루
    Color(0xFF21113A), // 딥 퍼플
    Color(0xFF1A0A46), // 어두운 자주색
    Color(0xFF142339), // 네이비 블루
    Color(0xFF001F3F), // 미드나이트
    Color(0xFF0F172A), // 진한 네이비
  ];
  static const List<int> patterns = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  PlanetComponent({
    super.key,
    required this.data,
    this.size = 700,
  }) {
    hash = _generateHash(data);
  }

  Uint8List _generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PlanetPainter(
          hash: hash,
          size: size,
        ),
      ),
    );
  }
}

class _PlanetPainter extends CustomPainter {
  final Uint8List hash;
  final double size;

  _PlanetPainter({
    required this.hash,
    required this.size,
  });

  int _getValueFromByte(int input, int range) {
    if (range == 0) return 0;
    final inputInt = input & 0xFF;
    final percent = 256 / range;

    for (var i = 0; i < range; i++) {
      if ((i * percent) < inputInt && inputInt < ((i + 1) * percent)) {
        return i;
      }
    }
    return 0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Circle Clip
    final path = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.height / 2,
      ));
    canvas.clipPath(path);

    // Mask Circle
    final visible = _getValueFromByte(hash[24], 10) <= 5;
    if (visible) {
      final outlineRadius = 30.0 + _getValueFromByte(hash[25], 90) * 0.5;
      final degree = _getValueFromByte(hash[26], 360);
      final scale = 60.0 + _getValueFromByte(hash[27], 80) * 0.5;
      _drawMaskCircle(canvas, size, outlineRadius, degree * 1.0, scale);
    }

    // Main Pattern
    final pattern = PlanetComponent
        .patterns[_getValueFromByte(hash[0], PlanetComponent.patterns.length)];
    final colorCode = PlanetComponent
        .colors[_getValueFromByte(hash[1], PlanetComponent.colors.length)];
    _drawMain(canvas, size, pattern, colorCode);

    // Circle 1
    final visible1 = _getValueFromByte(hash[8], 10) <= 9;
    if (visible1) {
      final outlineRadius = 90.0 + _getValueFromByte(hash[9], 40) * 0.5;
      final degree = _getValueFromByte(hash[10], 360);
      final scale = 90.0 + _getValueFromByte(hash[11], 40) * 0.5;
      final colorCode = PlanetComponent
          .colors[_getValueFromByte(hash[12], PlanetComponent.colors.length)];
      _drawCircle(canvas, size, outlineRadius, degree * 1.0, scale, colorCode);
    }

    // Circle 2
    final visible2 = _getValueFromByte(hash[16], 10) <= 7;
    if (visible2) {
      final outlineRadius = 90.0 + _getValueFromByte(hash[17], 40) * 0.5;
      final degree = _getValueFromByte(hash[18], 360);
      final scale = 90.0 + _getValueFromByte(hash[19], 40) * 0.5;
      final colorCode = PlanetComponent
          .colors[_getValueFromByte(hash[20], PlanetComponent.colors.length)];
      _drawCircle(canvas, size, outlineRadius, degree * 1.0, scale, colorCode);
    }
  }

  void _drawMaskCircle(Canvas canvas, Size size, double outlineRadius,
      double degree, double scale) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = scale / 100.0 * (size.width / 2);
    final angleOffset = outlineRadius / 100.0 * (size.width / 2);

    final background = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final circlePath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(centerX + angleOffset * cos(degree * pi / 180.0),
            centerY + angleOffset * sin(degree * pi / 180.0)),
        radius: radius,
      ));

    final maskPath =
        Path.combine(PathOperation.difference, background, circlePath);
    canvas.clipPath(maskPath);
  }

  void _drawCircle(Canvas canvas, Size size, double outlineRadius,
      double degree, double scale, Color colorCode) {
    final paint = Paint()..color = colorCode;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = scale / 100.0 * (size.width / 2);
    final angleOffset = outlineRadius / 100.0 * (size.width / 2);

    canvas.drawCircle(
        Offset(centerX + angleOffset * cos(degree * pi / 180.0),
            centerY + angleOffset * sin(degree * pi / 180.0)),
        radius,
        paint);
  }

  void _drawMain(Canvas canvas, Size size, int pattern, Color colorCode) {
    final paint = Paint()..color = colorCode;

    switch (pattern) {
      case 0: // None (단색)
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
        break;

      case 1: // Wave
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = size.height / 42;

        final waveWidth = size.width / 16;
        final waveHeight = size.height / 42;
        final waveCount = (size.width / waveWidth).ceil();
        final pathCount = (size.height / waveHeight).ceil();

        for (var j = 0; j < pathCount + 1; j++) {
          final pointY = j * waveHeight * 2;
          var path = Path();
          path.moveTo(-waveWidth, pointY + waveHeight);

          for (var i = 0; i < waveCount + 1; i++) {
            path.quadraticBezierTo(
                (i * waveWidth * 4) + waveWidth * 0,
                pointY - waveHeight + waveHeight / 2.0,
                (i * waveWidth * 4) + waveWidth * 1,
                pointY + waveHeight / 2.0);
            path.quadraticBezierTo(
                (i * waveWidth * 4) + waveWidth * 2,
                pointY + waveHeight + waveHeight / 2.0,
                (i * waveWidth * 4) + waveWidth * 3,
                pointY + waveHeight / 2.0);
          }
          canvas.drawPath(path, paint);
        }
        break;

      case 2: // Diamond
        final pathWidth = sqrt(pow(size.width, 2) + pow(size.height, 2)) / 42.0;
        final centerX = size.width / 2.0;
        final centerY = size.height / 2.0;

        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = pathWidth;

        for (var i = 0; i < 14; i++) {
          final multi = i == 0 ? 1 : (i * 3);
          final path = Path()
            ..moveTo(centerX, centerY - pathWidth * multi)
            ..lineTo(centerX + pathWidth * multi, centerY)
            ..lineTo(centerX, centerY + pathWidth * multi)
            ..lineTo(centerX - pathWidth * multi, centerY)
            ..close();

          if (i == 0) {
            paint.style = PaintingStyle.fill;
            canvas.drawPath(path, paint);
            paint.style = PaintingStyle.stroke;
          } else {
            canvas.drawPath(path, paint);
          }
        }
        break;

      case 3: // Vertical Stripe
        paint.style = PaintingStyle.stroke;
        final pathWidth = size.width / 56;
        paint.strokeWidth = pathWidth * 2;

        for (var i = 0; i < 28; i++) {
          canvas.drawLine(Offset(pathWidth * (i * 4 + 1), 0),
              Offset(pathWidth * (i * 4 + 1), size.height), paint);
        }
        break;

      case 4: // Stripe twist
        paint.style = PaintingStyle.stroke;
        final pathWidth = size.width / 56;
        paint.strokeWidth = pathWidth * 2;

        for (var i = 0; i < 28; i++) {
          canvas.drawLine(Offset(pathWidth * (i * 4 + 1), 0),
              Offset(pathWidth * (i * 4 + 1), size.height / 2.0), paint);
          canvas.drawLine(Offset(pathWidth * (i * 4 + 3), size.height / 2.0),
              Offset(pathWidth * (i * 4 + 3), size.height), paint);
        }
        break;

      case 5: // Diagonal
        final pathWidth = sqrt(pow(size.width, 2) + pow(size.height, 2)) / 42.0;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = pathWidth;

        for (var i = 0; i < 24; i++) {
          final path = Path()
            ..moveTo(
                size.width + pathWidth - ((i - 12) * 3) * pathWidth, -pathWidth)
            ..lineTo(0 - pathWidth - ((i - 12) * 3) * pathWidth,
                size.height + pathWidth);
          canvas.drawPath(path, paint);
        }
        break;

      case 6: // Check
        paint.style = PaintingStyle.fill;
        final boxWidth = size.width / 24.0;

        for (var j = 0; j < 12; j++) {
          for (var i = 0; i < 12; i++) {
            canvas.drawRect(
                Rect.fromLTWH(
                    boxWidth * (i * 2), boxWidth * (j * 2), boxWidth, boxWidth),
                paint);
            canvas.drawRect(
                Rect.fromLTWH(boxWidth * (i * 2 + 1), boxWidth * (j * 2 + 1),
                    boxWidth, boxWidth),
                paint);
          }
        }
        break;

      case 7: // Check pattern with border
        paint.style = PaintingStyle.stroke;
        final patternWidth = size.width / 32.0;
        final patternHeight = size.height / 32.0;
        final patternDiagonal = sqrt(pow(patternWidth, 2));

        for (var j = 0; j < 20; j++) {
          for (var i = 0; i < 16; i++) {
            final topPath = Path()
              ..moveTo(patternWidth * (i * 2),
                  patternHeight * (j * 2) - patternHeight / 2.0)
              ..lineTo(
                  patternWidth * (i * 2 + 1),
                  patternHeight * (j * 2) -
                      patternHeight / 2.0 +
                      patternDiagonal)
              ..lineTo(
                  patternWidth * (i * 2 + 1),
                  patternHeight * (j * 2) -
                      patternHeight / 2.0 +
                      patternHeight +
                      patternDiagonal)
              ..lineTo(patternWidth * (i * 2),
                  patternHeight * (j * 2) - patternHeight / 2.0 + patternHeight)
              ..close();

            paint.style = PaintingStyle.fill;
            canvas.drawPath(topPath, paint);

            final bottomPath = Path()
              ..moveTo(
                  patternWidth * (i * 2 + 1),
                  patternHeight * (j * 2) -
                      patternHeight / 2.0 +
                      patternHeight +
                      patternDiagonal)
              ..lineTo(patternWidth * (i * 2 + 2),
                  patternHeight * (j * 2) - patternHeight / 2.0 + patternHeight)
              ..lineTo(
                  patternWidth * (i * 2 + 2),
                  patternHeight * (j * 2) -
                      patternHeight / 2.0 +
                      patternHeight +
                      patternHeight)
              ..lineTo(
                  patternWidth * (i * 2 + 1),
                  patternHeight * (j * 2) -
                      patternHeight / 2.0 +
                      patternHeight +
                      patternHeight +
                      patternDiagonal)
              ..close();

            paint.style = PaintingStyle.stroke;
            canvas.drawPath(bottomPath, paint);
          }
        }
        break;

      case 8: // Grill
        paint.style = PaintingStyle.fill;
        final pathWidth = (size.width / 16.0) * 3.0 / 5.0;
        final gapWidth = (size.width / 16.0) * 2.0 / 5.0;

        for (var j = 0; j < 18; j++) {
          for (var i = 0; i < 18; i++) {
            final path1 = Path()
              ..moveTo(
                  (gapWidth * (i + 1)) +
                      (pathWidth * i) +
                      ((pathWidth / 2.0) * 1) -
                      gapWidth / 2.0,
                  ((pathWidth / 2.0) * -1) + (gapWidth + pathWidth) * j)
              ..lineTo(
                  (gapWidth * (i + 1)) +
                      (pathWidth * i) +
                      ((pathWidth / 2.0) * 2) -
                      gapWidth / 2.0,
                  ((pathWidth / 2.0) * 0) + (gapWidth + pathWidth) * j)
              ..lineTo(
                  (gapWidth * (i + 1)) +
                      (pathWidth * i) +
                      ((pathWidth / 2.0) * 1) -
                      gapWidth / 2.0,
                  ((pathWidth / 2.0) * 1) + (gapWidth + pathWidth) * j)
              ..lineTo(
                  (gapWidth * (i + 1)) +
                      (pathWidth * i) +
                      ((pathWidth / 2.0) * 0) -
                      gapWidth / 2.0,
                  ((pathWidth / 2.0) * 0) + (gapWidth + pathWidth) * j)
              ..close();
            canvas.drawPath(path1, paint);

            final path2 = Path()
              ..moveTo(
                  (gapWidth * (i + 1)) +
                      (pathWidth * i) +
                      ((pathWidth / 2.0) * 1) -
                      gapWidth -
                      pathWidth / 2.0,
                  (gapWidth / 2.0 + pathWidth / 2.0) +
                      ((pathWidth / 2.0) * -1) +
                      (gapWidth + pathWidth) * j)
              ..lineTo(
                  (gapWidth * (i + 1)) +
                      (pathWidth * i) +
                      ((pathWidth / 2.0) * 2) -
                      gapWidth -
                      pathWidth / 2.0,
                  (gapWidth / 2.0 + pathWidth / 2.0) +
                      ((pathWidth / 2.0) * 0) +
                      (gapWidth + pathWidth) * j)
              ..lineTo(
                  (gapWidth * (i + 1)) +
                      (pathWidth * i) +
                      ((pathWidth / 2.0) * 1) -
                      gapWidth -
                      pathWidth / 2.0,
                  (gapWidth / 2.0 + pathWidth / 2.0) +
                      ((pathWidth / 2.0) * 1) +
                      (gapWidth + pathWidth) * j)
              ..lineTo(
                  (gapWidth * (i + 1)) +
                      (pathWidth * i) +
                      ((pathWidth / 2.0) * 0) -
                      gapWidth -
                      pathWidth / 2.0,
                  (gapWidth / 2.0 + pathWidth / 2.0) +
                      ((pathWidth / 2.0) * 0) +
                      (gapWidth + pathWidth) * j)
              ..close();
            canvas.drawPath(path2, paint);
          }
        }
        break;

      case 9: // Half
        final pathWidth = sqrt(pow(size.width, 2) + pow(size.height, 2)) / 42.0;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = pathWidth;

        for (var i = 0; i < 13; i++) {
          final path = Path()
            ..moveTo(
                size.width +
                    pathWidth +
                    ((i - 12) * 3) * pathWidth -
                    pathWidth * 2,
                -pathWidth)
            ..lineTo(0 - pathWidth + ((i - 12) * 3) * pathWidth - pathWidth * 2,
                size.height + pathWidth);
          canvas.drawPath(path, paint);
        }

        paint.style = PaintingStyle.fill;
        final fillPath = Path()
          ..moveTo(size.width, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(fillPath, paint);
        break;

      case 10: // Zigzag
        paint.style = PaintingStyle.fill;
        final patternWidth = size.width / 16.0;
        final patternHeight = size.height / 16.0;

        for (var i = 0; i < 8; i++) {
          for (var row = 0; row < 4; row++) {
            final baseY = (patternHeight * 4) * row;

            // First zigzag
            final zigzag1 = Path()
              ..moveTo((patternWidth * 2 * i) + patternWidth * 1,
                  baseY + patternHeight * 0)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 2,
                  baseY + patternHeight * 0)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 1,
                  baseY + patternHeight * 1)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 2,
                  baseY + patternHeight * 2)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 1,
                  baseY + patternHeight * 3)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 2,
                  baseY + patternHeight * 4)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 1,
                  baseY + patternHeight * 4)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 0,
                  baseY + patternHeight * 3)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 1,
                  baseY + patternHeight * 2)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 0,
                  baseY + patternHeight * 1)
              ..close();
            canvas.drawPath(zigzag1, paint);

            // Second zigzag
            final zigzag2 = Path()
              ..moveTo((patternWidth * 2 * i) + patternWidth * 0,
                  baseY + patternHeight * 0)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 1,
                  baseY + patternHeight * 0)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 2,
                  baseY + patternHeight * 1)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 1,
                  baseY + patternHeight * 2)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 2,
                  baseY + patternHeight * 3)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 1,
                  baseY + patternHeight * 4)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 0,
                  baseY + patternHeight * 4)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 1,
                  baseY + patternHeight * 3)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 0,
                  baseY + patternHeight * 2)
              ..lineTo((patternWidth * 2 * i) + patternWidth * 1,
                  baseY + patternHeight * 1)
              ..close();
            canvas.drawPath(zigzag2, paint);
          }
        }
        break;

      case 11: // Triangle
        paint.style = PaintingStyle.fill;
        final patternWidth = size.width / 12.0;

        for (var j = 0; j < 12; j++) {
          for (var i = 0; i < 12; i++) {
            final trianglePath = Path()
              ..moveTo(patternWidth * i, patternWidth * j)
              ..lineTo(patternWidth * (i + 1), patternWidth * j)
              ..lineTo(patternWidth * i, patternWidth * (j + 1))
              ..close();
            canvas.drawPath(trianglePath, paint);
          }
        }
        break;

      case 12: // Horizontal Stripe
        paint.style = PaintingStyle.stroke;
        final pathWidth = size.width / 56;
        paint.strokeWidth = pathWidth * 2;

        for (var i = 0; i < 28; i++) {
          canvas.drawLine(Offset(0, pathWidth * (i * 4 + 1)),
              Offset(size.width, pathWidth * (i * 4 + 1)), paint);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(_PlanetPainter oldDelegate) => true;
}
