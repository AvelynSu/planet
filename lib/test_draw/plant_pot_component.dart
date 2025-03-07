import 'dart:convert';
import 'dart:math' show Random, cos, pi, pow, sin, sqrt;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class PlantPotComponent extends StatelessWidget {
  final String name;
  final double size;
  late final Uint8List hash;

  static const List<Color> potColors = [
    Color(0xFFBF6A3A), // 테라코타
    Color(0xFFE3C0A8), // 라이트 테라코타
    Color(0xFF9C4A31), // 다크 테라코타
    Color(0xFF5D4037), // 브라운
    Color(0xFF795548), // 미디엄 브라운
    Color(0xFFBC8F8F), // 로지 브라운
    Color(0xFFDEB887), // 버릿우드
    Color(0xFFD7CCC8), // 라이트 그레이
    Color(0xFFA1887F), // 그레이 브라운
    Color(0xFF455A64), // 블루 그레이
    Color(0xFF607D8B), // 라이트 블루 그레이
    Color(0xFF006064), // 딥 틸
    Color(0xFF004D40), // 딥 틸 그린
    Color(0xFF1A237E), // 딥 인디고
    Color(0xFF880E4F), // 딥 핑크
  ];

  static const List<Color> flowerColors = [
    Color(0xFFF44336), // 빨강
    Color(0xFFE91E63), // 핑크
    Color(0xFF9C27B0), // 퍼플
    Color(0xFF673AB7), // 딥 퍼플
    Color(0xFF3F51B5), // 인디고
    Color(0xFF2196F3), // 블루
    Color(0xFF03A9F4), // 라이트 블루
    Color(0xFF00BCD4), // 시안
    Color(0xFF009688), // 틸
    Color(0xFF4CAF50), // 그린
    Color(0xFF8BC34A), // 라이트 그린
    Color(0xFFCDDC39), // 라임
    Color(0xFFFFEB3B), // 옐로우
    Color(0xFFFFC107), // 앰버
    Color(0xFFFF9800), // 오렌지
    Color(0xFFFF5722), // 딥 오렌지
    Color(0xFFF5F5DC), // 베이지 (흰색 꽃)
    Color(0xFFFFE4E1), // 미스티 로즈
    Color(0xFFE6E6FA), // 라벤더
    Color(0xFFFFF8DC), // 코넛크림
  ];

  static const List<Color> leafColors = [
    Color(0xFF4CAF50), // 일반 그린
    Color(0xFF388E3C), // 다크 그린
    Color(0xFF8BC34A), // 라이트 그린
    Color(0xFF689F38), // 라임 그린
    Color(0xFF2E7D32), // 포레스트 그린
    Color(0xFF1B5E20), // 딥 그린
    Color(0xFF004D40), // 틸 그린
    Color(0xFF00695C), // 다크 틸
    Color(0xFF33691E), // 올리브 그린
    Color(0xFF558B2F), // 올리브 라이트
  ];

  static const List<int> potPatterns = [0, 1, 2, 3, 4]; // 화분 패턴 유형
  static const List<int> plantTypes = [0, 1, 2, 3, 4]; // 식물 유형

  PlantPotComponent({
    super.key,
    required this.name,
    this.size = 400,
  }) {
    hash = _generateHash(name);
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
      height: size * 1.5, // 화분과 식물을 위한 더 높은 공간
      child: CustomPaint(
        painter: _PlantPotPainter(
          hash: hash,
          size: size,
          name: name,
        ),
      ),
    );
  }
}

class _PlantPotPainter extends CustomPainter {
  final Uint8List hash;
  final double size;
  final String name;

  _PlantPotPainter({
    required this.hash,
    required this.size,
    required this.name,
  });

  int _getValueFromByte(int input, int range) {
    if (range == 0) return 0;
    final inputInt = input & 0xFF;
    final percent = 256 / range;

    for (var i = 0; i < range; i++) {
      if ((i * percent) <= inputInt && inputInt < ((i + 1) * percent)) {
        return i;
      }
    }
    return 0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // 화분 크기와 모양 결정
    final potWidth = size.width * (0.5 + _getValueFromByte(hash[0], 30) / 100);
    final potHeight =
        size.height * (0.25 + _getValueFromByte(hash[1], 15) / 100);
    final potBottomWidth =
        potWidth * (0.7 + _getValueFromByte(hash[2], 20) / 100);
    final potTopRadius = _getValueFromByte(hash[3], 20) / 100;

    // 화분 색상 및 패턴
    final potColor = PlantPotComponent.potColors[
        _getValueFromByte(hash[4], PlantPotComponent.potColors.length)];
    final potPattern = PlantPotComponent.potPatterns[
        _getValueFromByte(hash[5], PlantPotComponent.potPatterns.length)];
    final patternColor = PlantPotComponent.potColors[
        _getValueFromByte(hash[6], PlantPotComponent.potColors.length)];

    // 흙/토양 영역
    final soilHeight = potHeight * (0.1 + _getValueFromByte(hash[7], 10) / 100);

    // 식물 유형, 크기, 색상
    final plantType = PlantPotComponent.plantTypes[
        _getValueFromByte(hash[8], PlantPotComponent.plantTypes.length)];
    final plantHeight =
        size.height * (0.4 + _getValueFromByte(hash[9], 30) / 100);
    final leafColor = PlantPotComponent.leafColors[
        _getValueFromByte(hash[10], PlantPotComponent.leafColors.length)];
    final flowerColor = PlantPotComponent.flowerColors[
        _getValueFromByte(hash[11], PlantPotComponent.flowerColors.length)];

    // 식물의 다양성을 위한 추가 변수들
    final flowerCount = 3 + _getValueFromByte(hash[12], 8);
    final leafSize = size.width * (0.1 + _getValueFromByte(hash[13], 15) / 100);

    // 화분의 위치를 아래쪽으로 설정 (식물이 위로 자랄 공간 확보)
    final potBottom = size.height * 0.9;
    final potTop = potBottom - potHeight;

    // 화분 그리기
    _drawPot(
        canvas,
        Rect.fromLTWH(centerX - potWidth / 2, potTop, potWidth, potHeight),
        potBottomWidth,
        potTopRadius,
        potColor,
        potPattern,
        patternColor);

    // 흙/토양 그리기
    final soilPaint = Paint()..color = Color(0xFF3E2723);
    final soilPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - potWidth * 0.9 / 2, potTop, potWidth * 0.9, soilHeight),
        Radius.circular(potWidth * potTopRadius * 0.9),
      ));
    canvas.drawPath(soilPath, soilPaint);

    // 식물/꽃 그리기
    final plantBase = potTop;
    _drawPlant(canvas, centerX, plantBase, plantType, plantHeight, leafColor,
        flowerColor, flowerCount, leafSize, size);

    // 이름 표시 (옵션)
    _drawNameTag(canvas, centerX, potBottom + size.width * 0.05, name);
  }

  void _drawPot(Canvas canvas, Rect potRect, double bottomWidth,
      double topRadius, Color color, int pattern, Color patternColor) {
    final centerX = potRect.left + potRect.width / 2;
    final potLeft = potRect.left;
    final potRight = potRect.right;
    final potTop = potRect.top;
    final potBottom = potRect.bottom;

    // 화분 바디 패스
    final potPath = Path();

    // 윗부분 (둥근 모서리)
    final topRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(potLeft, potTop, potRect.width, potRect.height * 0.2),
      Radius.circular(potRect.width * topRadius),
    );
    potPath.addRRect(topRRect);

    // 몸통 부분 (사다리꼴)
    final bottomLeft = potRect.left + (potRect.width - bottomWidth) / 2;
    potPath.moveTo(potLeft, potTop + potRect.height * 0.2);
    potPath.lineTo(bottomLeft, potBottom);
    potPath.lineTo(bottomLeft + bottomWidth, potBottom);
    potPath.lineTo(potRight, potTop + potRect.height * 0.2);
    potPath.close();

    // 화분 바디 그리기
    final potPaint = Paint()..color = color;
    canvas.drawPath(potPath, potPaint);

    // 패턴 그리기
    final patternPaint = Paint()
      ..color = patternColor
      ..style = PaintingStyle.fill;

    switch (pattern) {
      case 0: // 패턴 없음 (기본 색상)
        break;

      case 1: // 수평 줄무늬
        final stripeCount = 3 + _getValueFromByte(hash[14], 4);
        final stripeHeight = potRect.height / (stripeCount * 2);

        for (var i = 0; i < stripeCount; i++) {
          canvas.drawRect(
              Rect.fromLTWH(potLeft, potTop + i * stripeHeight * 2,
                  potRect.width, stripeHeight),
              patternPaint);
        }
        break;

      case 2: // 원형 패턴
        final dotRadius = potRect.width * 0.1;
        final dotsPerRow = 3;
        final dotSpacing = potRect.width / dotsPerRow;

        for (var y = 0; y < 2; y++) {
          for (var x = 0; x < dotsPerRow; x++) {
            canvas.drawCircle(
                Offset(potLeft + x * dotSpacing + dotSpacing / 2,
                    potTop + potRect.height * 0.25 + y * dotSpacing * 1.2),
                dotRadius,
                patternPaint);
          }
        }
        break;

      case 3: // 물결 패턴
        final waveCount = 2;
        final waveHeight = potRect.height / 10;
        final wavePaint = Paint()
          ..color = patternColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = waveHeight / 2;

        for (var i = 0; i < waveCount; i++) {
          final y = potTop + potRect.height * 0.3 + i * waveHeight * 3;
          final path = Path();
          path.moveTo(potLeft, y);

          for (var x = 0; x < 4; x++) {
            path.quadraticBezierTo(potLeft + potRect.width * (x + 0.25) / 4,
                y - waveHeight, potLeft + potRect.width * (x + 0.5) / 4, y);
            path.quadraticBezierTo(potLeft + potRect.width * (x + 0.75) / 4,
                y + waveHeight, potLeft + potRect.width * (x + 1) / 4, y);
          }
          canvas.drawPath(path, wavePaint);
        }
        break;

      case 4: // 삼각형 패턴
        final triangleSize = potRect.width * 0.15;
        final trianglesPerRow = 3;
        final triangleSpacing = potRect.width / trianglesPerRow;

        for (var y = 0; y < 2; y++) {
          for (var x = 0; x < trianglesPerRow; x++) {
            final centerX = potLeft + x * triangleSpacing + triangleSpacing / 2;
            final centerY =
                potTop + potRect.height * 0.3 + y * triangleSize * 2;

            final trianglePath = Path();
            trianglePath.moveTo(centerX, centerY - triangleSize);
            trianglePath.lineTo(centerX + triangleSize, centerY + triangleSize);
            trianglePath.lineTo(centerX - triangleSize, centerY + triangleSize);
            trianglePath.close();

            canvas.drawPath(trianglePath, patternPaint);
          }
        }
        break;
    }
  }

  void _drawPlant(
      Canvas canvas,
      double centerX,
      double baseY,
      int plantType,
      double height,
      Color leafColor,
      Color flowerColor,
      int flowerCount,
      double leafSize,
      Size canvasSize) {
    switch (plantType) {
      case 0: // 작은 꽃 여러 개
        _drawStemPlant(canvas, centerX, baseY, height, leafColor, flowerColor,
            flowerCount, leafSize);
        break;

      case 1: // 선인장
        _drawCactus(canvas, centerX, baseY, height, leafColor, flowerColor);
        break;

      case 2: // 다육 식물
        _drawSucculent(canvas, centerX, baseY, height, leafColor, flowerColor);
        break;

      case 3: // 잎이 많은 식물
        _drawLeafyPlant(canvas, centerX, baseY, height, leafColor);
        break;

      case 4: // 큰 꽃 하나
        _drawSingleFlower(
            canvas, centerX, baseY, height, leafColor, flowerColor, leafSize);
        break;
    }
  }

  void _drawStemPlant(
    Canvas canvas,
    double centerX,
    double baseY,
    double height,
    Color leafColor,
    Color flowerColor,
    int flowerCount,
    double leafSize,
  ) {
    final stemPaint = Paint()
      ..color = Color(0xFF7D5A4F)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Random random = Random(_getValueFromByte(hash[15], 1000));

    // 메인 스템
    final stemPath = Path();
    stemPath.moveTo(centerX, baseY);
    stemPath.lineTo(centerX, baseY - height * 0.7);
    canvas.drawPath(stemPath, stemPaint);

    // 잎 그리기
    final leafPaint = Paint()..color = leafColor;
    for (var i = 0; i < 4; i++) {
      final leafY = baseY - height * (0.2 + 0.15 * i);
      final side = i % 2 == 0 ? 1 : -1;

      final leafPath = Path();
      leafPath.moveTo(centerX, leafY);
      leafPath.quadraticBezierTo(centerX + side * leafSize,
          leafY - leafSize / 2, centerX + side * leafSize * 1.2, leafY);

      canvas.drawPath(leafPath, stemPaint);

      // 더 넓은 잎 형태
      final fullLeafPath = Path();
      fullLeafPath.moveTo(centerX, leafY);
      fullLeafPath.quadraticBezierTo(centerX + side * leafSize,
          leafY - leafSize / 2, centerX + side * leafSize * 1.2, leafY);
      fullLeafPath.quadraticBezierTo(
          centerX + side * leafSize, leafY + leafSize / 2, centerX, leafY);
      fullLeafPath.close();

      canvas.drawPath(fullLeafPath, leafPaint);
    }

    // 꽃 그리기
    final flowerPaint = Paint()..color = flowerColor;
    final flowerCenterPaint = Paint()..color = Color(0xFFFFF176);

    for (var i = 0; i < flowerCount; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * height * 0.2;
      final flowerX = centerX + cos(angle) * distance;
      final flowerY = baseY - height * 0.7 - sin(angle) * distance;
      final flowerSize = leafSize * (0.6 + random.nextDouble() * 0.4);

      // 꽃잎
      for (var p = 0; p < 5; p++) {
        final petalAngle = p * (2 * pi / 5);
        final petalPath = Path();
        petalPath.moveTo(flowerX, flowerY);
        petalPath.quadraticBezierTo(
            flowerX + cos(petalAngle) * flowerSize * 0.8,
            flowerY + sin(petalAngle) * flowerSize * 0.8,
            flowerX + cos(petalAngle) * flowerSize,
            flowerY + sin(petalAngle) * flowerSize);
        petalPath.quadraticBezierTo(
            flowerX + cos(petalAngle + 0.35) * flowerSize * 0.8,
            flowerY + sin(petalAngle + 0.35) * flowerSize * 0.8,
            flowerX,
            flowerY);
        canvas.drawPath(petalPath, flowerPaint);
      }

      // 꽃 중앙
      canvas.drawCircle(
          Offset(flowerX, flowerY), flowerSize * 0.25, flowerCenterPaint);
    }
  }

  void _drawCactus(
    Canvas canvas,
    double centerX,
    double baseY,
    double height,
    Color cactusColor,
    Color flowerColor,
  ) {
    final cactusPaint = Paint()..color = cactusColor;
    final thornPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // 메인 줄기
    final mainWidth = height * 0.25;
    final mainPath = Path();
    mainPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - mainWidth / 2, baseY - height, mainWidth, height),
      Radius.circular(mainWidth / 2),
    ));
    canvas.drawPath(mainPath, cactusPaint);

    // 가지
    final branchPath = Path();
    final branchY = baseY - height * 0.6;
    final branchLength = height * 0.4;

    branchPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX, branchY - mainWidth / 2, branchLength, mainWidth),
      Radius.circular(mainWidth / 2),
    ));
    canvas.drawPath(branchPath, cactusPaint);

    // 가시
    final Random random = Random(_getValueFromByte(hash[16], 1000));
    for (var i = 0; i < 15; i++) {
      final thornY = baseY - random.nextDouble() * height * 0.9;
      final side = random.nextBool() ? 1 : -1;

      canvas.drawLine(
          Offset(centerX + side * mainWidth / 2, thornY),
          Offset(centerX + side * (mainWidth / 2 + mainWidth * 0.3), thornY),
          thornPaint);
    }

    // 가지 가시
    for (var i = 0; i < 5; i++) {
      final thornX = centerX +
          random.nextDouble() * branchLength * 0.8 +
          branchLength * 0.1;
      final side = 1;

      canvas.drawLine(
          Offset(thornX, branchY + side * mainWidth / 2),
          Offset(thornX, branchY + side * (mainWidth / 2 + mainWidth * 0.3)),
          thornPaint);
    }

    // 꽃
    if (_getValueFromByte(hash[17], 10) < 6) {
      // 60% 확률로 꽃 표시
      final flowerPaint = Paint()..color = flowerColor;
      final flowerX = centerX + branchLength * 0.8;
      final flowerY = branchY;
      final flowerSize = mainWidth * 0.6;

      for (var p = 0; p < 8; p++) {
        final petalAngle = p * (2 * pi / 8);
        final petalPath = Path();
        petalPath.moveTo(flowerX, flowerY);
        petalPath.quadraticBezierTo(
            flowerX + cos(petalAngle) * flowerSize * 0.6,
            flowerY + sin(petalAngle) * flowerSize * 0.6,
            flowerX + cos(petalAngle) * flowerSize,
            flowerY + sin(petalAngle) * flowerSize);
        petalPath.quadraticBezierTo(
            flowerX + cos(petalAngle + 0.4) * flowerSize * 0.6,
            flowerY + sin(petalAngle + 0.4) * flowerSize * 0.6,
            flowerX,
            flowerY);
        canvas.drawPath(petalPath, flowerPaint);
      }

      final centerPaint = Paint()..color = Colors.yellow;
      canvas.drawCircle(
          Offset(flowerX, flowerY), flowerSize * 0.25, centerPaint);
    }
  }

  void _drawSucculent(
    Canvas canvas,
    double centerX,
    double baseY,
    double height,
    Color leafColor,
    Color accentColor,
  ) {
    final Random random = Random(_getValueFromByte(hash[18], 1000));

    // 다육 식물의 잎 층들
    final leafCount = 5 + _getValueFromByte(hash[19], 5); // 전체 잎 수
    final maxRadius = height * 0.6; // 가장 큰 잎의 길이

    // 하단 잎부터 그리기 (큰 잎)
    for (var ring = 0; ring < 3; ring++) {
      final ringLeafCount = 6 + ring * 2; // 각 링의 잎 개수
      final ringRadius = maxRadius - ring * maxRadius * 0.15; // 링의 반지름
      final yOffset = baseY - ring * height * 0.12; // 수직 위치 조정

      for (var i = 0; i < ringLeafCount; i++) {
        final angle = i * (2 * pi / ringLeafCount);
        final leafLength = ringRadius * (0.85 + random.nextDouble() * 0.3);
        final leafWidth = leafLength * 0.3;

        // 잎 색상 - 가끔 악센트 색상 사용
        final useAccent = random.nextDouble() < 0.15; // 15% 확률로 악센트 색
        final paint = Paint()..color = useAccent ? accentColor : leafColor;

        final leafPath = Path();
        leafPath.moveTo(centerX, yOffset);

        // 잎 만들기 - 타원형 곡선 형태
        final controlX1 = centerX + cos(angle) * leafLength * 0.5;
        final controlY1 = yOffset + sin(angle) * leafLength * 0.3;
        final endX = centerX + cos(angle) * leafLength;
        final endY = yOffset + sin(angle) * leafLength;

        // 잎의 윗부분
        leafPath.quadraticBezierTo(controlX1, controlY1, endX, endY);

        // 잎의 아랫부분
        final controlX2 =
            centerX + cos(angle) * leafLength * 0.5 + sin(angle) * leafWidth;
        final controlY2 =
            yOffset + sin(angle) * leafLength * 0.3 - cos(angle) * leafWidth;
        leafPath.quadraticBezierTo(controlX2, controlY2, centerX, yOffset);

        canvas.drawPath(leafPath, paint);

        // 잎 테두리 (선택적)
        if (useAccent) {
          final borderPaint = Paint()
            ..color = accentColor.withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
          canvas.drawPath(leafPath, borderPaint);
        }
      }
    }

    // 중앙 부분 - 작은 잎들의 클러스터
    final centerRadius = maxRadius * 0.25;
    final centerLeafCount = 6;

    for (var i = 0; i < centerLeafCount; i++) {
      final angle = i * (2 * pi / centerLeafCount) + pi / centerLeafCount;
      final leafLength = centerRadius * (0.7 + random.nextDouble() * 0.3);
      final leafWidth = leafLength * 0.3;

      final paint = Paint()..color = leafColor.withOpacity(0.9);

      final leafPath = Path();
      final yOffset = baseY - height * 0.25;
      leafPath.moveTo(centerX, yOffset);

      final controlX1 = centerX + cos(angle) * leafLength * 0.5;
      final controlY1 = yOffset + sin(angle) * leafLength * 0.3;
      final endX = centerX + cos(angle) * leafLength;
      final endY = yOffset + sin(angle) * leafLength;

      leafPath.quadraticBezierTo(controlX1, controlY1, endX, endY);

      final controlX2 =
          centerX + cos(angle) * leafLength * 0.5 + sin(angle) * leafWidth;
      final controlY2 =
          yOffset + sin(angle) * leafLength * 0.3 - cos(angle) * leafWidth;
      leafPath.quadraticBezierTo(controlX2, controlY2, centerX, yOffset);

      canvas.drawPath(leafPath, paint);
    }
  }

  void _drawLeafyPlant(
    Canvas canvas,
    double centerX,
    double baseY,
    double height,
    Color leafColor,
  ) {
    final stemPaint = Paint()
      ..color = Color(0xFF7D5A4F)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()..color = leafColor;
    final leafDarkPaint = Paint()..color = leafColor.withOpacity(0.7);

    final Random random = Random(_getValueFromByte(hash[20], 1000));

    // 여러 개의 줄기
    final stemCount = 3 + _getValueFromByte(hash[21], 3);

    for (var s = 0; s < stemCount; s++) {
      final stemOffset = (s - stemCount / 2) * (height * 0.15);
      final stemHeight = height * (0.6 + random.nextDouble() * 0.3);
      final stemX = centerX + stemOffset;

      // 줄기 그리기
      final stemPath = Path();
      stemPath.moveTo(stemX, baseY);

      // 약간 구부러진 줄기
      final controlX = stemX + (s % 2 == 0 ? 10 : -10);
      stemPath.quadraticBezierTo(controlX, baseY - stemHeight / 2,
          stemX + random.nextDouble() * 10 - 5, baseY - stemHeight);

      canvas.drawPath(stemPath, stemPaint);

      // 이 줄기에 잎 추가
      final leafCount = 2 + random.nextInt(3);

      for (var l = 0; l < leafCount; l++) {
        final leafY = baseY - stemHeight * (0.3 + l * 0.2);
        final leafSize = height * (0.15 + random.nextDouble() * 0.1);
        final leafSide = (l % 2 == 0) ? 1 : -1;

        // 잎 형태 (넓은 타원형)
        final leafPath = Path();
        final startX = stemX;
        final startY = leafY;
        final tipX = startX + leafSide * leafSize * 1.5;
        final tipY = startY - leafSize * 0.2;

        leafPath.moveTo(startX, startY);

        // 윗 곡선
        leafPath.quadraticBezierTo(
            (startX + tipX) / 2, startY - leafSize / 2, tipX, tipY);

        // 아래 곡선
        leafPath.quadraticBezierTo(
            (startX + tipX) / 2, startY + leafSize / 2, startX, startY);

        // 잎 내부 채우기
        canvas.drawPath(leafPath, leafPaint);

        // 잎맥 (장식)
        final veinPath = Path();
        veinPath.moveTo(startX, startY);
        veinPath.lineTo(tipX, tipY);
        canvas.drawPath(
            veinPath,
            Paint()
              ..color = leafDarkPaint.color
              ..strokeWidth = 1
              ..style = PaintingStyle.stroke);

        // 잎의 2차 잎맥
        for (var v = 0; v < 3; v++) {
          final veinStartX = startX + (tipX - startX) * (0.3 + v * 0.2);
          final veinStartY = startY + (tipY - startY) * (0.3 + v * 0.2);
          final veinLength = (leafSize * 0.5) * (1 - v * 0.2);

          final secondaryVein = Path();
          secondaryVein.moveTo(veinStartX, veinStartY);
          secondaryVein.lineTo(veinStartX + leafSide * veinLength * 0.3,
              veinStartY + (v % 2 == 0 ? 1 : -1) * veinLength * 0.5);

          canvas.drawPath(
              secondaryVein,
              Paint()
                ..color = leafDarkPaint.color
                ..strokeWidth = 0.5
                ..style = PaintingStyle.stroke);
        }
      }
    }
  }

  void _drawSingleFlower(
    Canvas canvas,
    double centerX,
    double baseY,
    double height,
    Color leafColor,
    Color flowerColor,
    double leafSize,
  ) {
    final stemPaint = Paint()
      ..color = Color(0xFF7D5A4F)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()..color = leafColor;
    final Random random = Random(_getValueFromByte(hash[22], 1000));

    // 메인 줄기
    final stemPath = Path();
    stemPath.moveTo(centerX, baseY);

    // 약간 구부러진 줄기
    final stemTopX = centerX + (random.nextDouble() * 20 - 10);
    final stemTopY = baseY - height * 0.75;
    stemPath.quadraticBezierTo(
        centerX + 15, baseY - height * 0.4, stemTopX, stemTopY);

    canvas.drawPath(stemPath, stemPaint);

    // 잎 2-3개 추가
    for (var i = 0; i < 3; i++) {
      final leafY = baseY - height * (0.2 + i * 0.2);
      final side = i % 2 == 0 ? 1 : -1;
      final actualLeafSize = leafSize * (1 + random.nextDouble() * 0.3);

      // 잎 줄기
      final leafStemPath = Path();
      final leafStemX = centerX + (i == 1 ? 5 : 0); // 두번째 잎은 약간 오프셋
      leafStemPath.moveTo(leafStemX, leafY);
      leafStemPath.lineTo(leafStemX + side * actualLeafSize * 0.3,
          leafY - actualLeafSize * 0.1);
      canvas.drawPath(leafStemPath, stemPaint);

      // 잎 형태
      final leafPath = Path();
      final leafBaseX = leafStemX + side * actualLeafSize * 0.3;
      final leafBaseY = leafY - actualLeafSize * 0.1;

      leafPath.moveTo(leafBaseX, leafBaseY);

      // 상단 곡선
      leafPath.quadraticBezierTo(
          leafBaseX + side * actualLeafSize * 0.6,
          leafBaseY - actualLeafSize * 0.3,
          leafBaseX + side * actualLeafSize,
          leafBaseY);

      // 하단 곡선
      leafPath.quadraticBezierTo(leafBaseX + side * actualLeafSize * 0.6,
          leafBaseY + actualLeafSize * 0.4, leafBaseX, leafBaseY);

      canvas.drawPath(leafPath, leafPaint);
    }

    // 큰 꽃 그리기
    final flowerPaint = Paint()..color = flowerColor;
    final flowerPaint2 = Paint()
      ..color = Color.lerp(flowerColor, Colors.white, 0.3)!;
    final flowerCenterPaint = Paint()..color = Color(0xFFFFC107);

    final flowerSize = height * 0.25;
    final flowerX = stemTopX;
    final flowerY = stemTopY;

    // 내부 꽃잎 레이어
    final petalCount = 8 + _getValueFromByte(hash[23], 4);
    for (var p = 0; p < petalCount; p++) {
      final petalAngle = p * (2 * pi / petalCount);
      final petalPath = Path();
      petalPath.moveTo(flowerX, flowerY);

      // 꽃잎 형태
      petalPath.quadraticBezierTo(
          flowerX + cos(petalAngle) * flowerSize * 0.7,
          flowerY + sin(petalAngle) * flowerSize * 0.7,
          flowerX + cos(petalAngle) * flowerSize,
          flowerY + sin(petalAngle) * flowerSize);

      petalPath.quadraticBezierTo(
          flowerX + cos(petalAngle + 0.3) * flowerSize * 0.7,
          flowerY + sin(petalAngle + 0.3) * flowerSize * 0.7,
          flowerX,
          flowerY);

      canvas.drawPath(petalPath, flowerPaint);
    }

    // 외부 꽃잎 레이어 (다른 모양과 색상)
    for (var p = 0; p < petalCount; p++) {
      final petalAngle = p * (2 * pi / petalCount) + pi / petalCount; // 오프셋
      final petalPath = Path();
      final outerSize = flowerSize * 0.85;
      petalPath.moveTo(flowerX, flowerY);

      // 약간 다른 꽃잎 형태
      petalPath.quadraticBezierTo(
          flowerX + cos(petalAngle) * outerSize * 0.5,
          flowerY + sin(petalAngle) * outerSize * 0.5,
          flowerX + cos(petalAngle) * outerSize,
          flowerY + sin(petalAngle) * outerSize);

      petalPath.quadraticBezierTo(
          flowerX + cos(petalAngle + 0.25) * outerSize * 0.5,
          flowerY + sin(petalAngle + 0.25) * outerSize * 0.5,
          flowerX,
          flowerY);

      canvas.drawPath(petalPath, flowerPaint2);
    }

    // 꽃 중앙
    canvas.drawCircle(
        Offset(flowerX, flowerY), flowerSize * 0.3, flowerCenterPaint);

    // 중앙 점들 (꽃가루/암술)
    final stamenPaint = Paint()..color = Colors.brown.shade800;
    for (var i = 0; i < 12; i++) {
      final angle = i * (2 * pi / 12);
      final distance = flowerSize * 0.15;
      canvas.drawCircle(
          Offset(
              flowerX + cos(angle) * distance, flowerY + sin(angle) * distance),
          2,
          stamenPaint);
    }
  }

  void _drawNameTag(Canvas canvas, double centerX, double y, String name) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    final textSpan = TextSpan(
      text: name,
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, y));
  }

  @override
  bool shouldRepaint(_PlantPotPainter oldDelegate) => true;
}
