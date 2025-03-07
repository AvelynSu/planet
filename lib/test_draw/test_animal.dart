import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class AnimalCharacterComponent extends StatelessWidget {
  final String name;
  final double size;
  late final Uint8List hash;

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

  // 동물 유형 (총 8종류)
  static const List<String> animalTypes = [
    'cat',
    'dog',
    'rabbit',
    'bear',
    'fox',
    'panda',
    'penguin',
    'owl',
  ];

  // 색상 팔레트
  static const List<Color> primaryColors = [
    Color(0xFFF5F5DC), // 베이지
    Color(0xFFFFEBCD), // 살구색
    Color(0xFFA52A2A), // 갈색
    Color(0xFF808080), // 회색
    Color(0xFF000000), // 검정
    Color(0xFFFFFFFF), // 흰색
    Color(0xFFA0522D), // 적갈색
    Color(0xFFFFA500), // 주황
    Color(0xFF8B4513), // 새들브라운
    Color(0xFFFFF8DC), // 콘실크
    Color(0xFFF0E68C), // 카키
    Color(0xFFE6E6FA), // 라벤더
    Color(0xFFADD8E6), // 연한 파랑
    Color(0xFF90EE90), // 연한 초록
    Color(0xFFFFB6C1), // 연한 분홍
  ];

  // 액센트 색상 (패턴, 특징용)
  static const List<Color> accentColors = [
    Color(0xFF000000), // 검정
    Color(0xFFFFFFFF), // 흰색
    Color(0xFF8B4513), // 새들브라운
    Color(0xFFFFA500), // 주황
    Color(0xFF800000), // 마룬
    Color(0xFF4B0082), // 인디고
    Color(0xFF006400), // 다크 그린
    Color(0xFF00008B), // 다크 블루
    Color(0xFF800080), // 퍼플
    Color(0xFFFF0000), // 빨강
    Color(0xFF0000FF), // 파랑
    Color(0xFF008000), // 초록
    Color(0xFFFFD700), // 골드
    Color(0xFFC0C0C0), // 실버
  ];

  // 액세서리 유형
  static const List<int> accessoryTypes = [0, 1, 2, 3, 4, 5];

  // 표정 유형
  static const List<int> expressionTypes = [0, 1, 2, 3, 4];

  // 패턴 유형
  static const List<int> patternTypes = [0, 1, 2, 3, 4, 5];

  AnimalCharacterComponent({
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
      height: size,
      child: CustomPaint(
        painter: _AnimalCharacterPainter(
          hash: hash,
          size: size,
          name: name,
        ),
      ),
    );
  }
}

class _AnimalCharacterPainter extends CustomPainter {
  final Uint8List hash;
  final double size;
  final String name;

  _AnimalCharacterPainter({
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
    // 캔버스 중앙
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 동물 특성 결정
    final animalType = AnimalCharacterComponent.animalTypes[_getValueFromByte(
        hash[0], AnimalCharacterComponent.animalTypes.length)];

    final primaryColor = AnimalCharacterComponent.primaryColors[
        _getValueFromByte(
            hash[1], AnimalCharacterComponent.primaryColors.length)];

    final accentColor = AnimalCharacterComponent.accentColors[_getValueFromByte(
        hash[2], AnimalCharacterComponent.accentColors.length)];

    final expressionType = AnimalCharacterComponent.expressionTypes[
        _getValueFromByte(
            hash[3], AnimalCharacterComponent.expressionTypes.length)];

    final accessoryType = AnimalCharacterComponent.accessoryTypes[
        _getValueFromByte(
            hash[4], AnimalCharacterComponent.accessoryTypes.length)];

    final patternType = AnimalCharacterComponent.patternTypes[_getValueFromByte(
        hash[5], AnimalCharacterComponent.patternTypes.length)];

    // 동물 체형 변화를 위한 값들
    final bodyWidth = size.width * (0.7 + _getValueFromByte(hash[6], 20) / 100);
    final bodyHeight =
        size.height * (0.7 + _getValueFromByte(hash[7], 20) / 100);
    final headSize = size.width * (0.5 + _getValueFromByte(hash[8], 20) / 100);

    // 동물 유형에 따라 캐릭터 그리기
    switch (animalType) {
      case 'cat':
        _drawCat(canvas, centerX, centerY, primaryColor, accentColor,
            patternType, expressionType, accessoryType, headSize);
        break;

      case 'dog':
        _drawDog(canvas, centerX, centerY, primaryColor, accentColor,
            patternType, expressionType, accessoryType, headSize);
        break;

      case 'rabbit':
        _drawRabbit(canvas, centerX, centerY, primaryColor, accentColor,
            patternType, expressionType, accessoryType, headSize);
        break;

      case 'bear':
        _drawBear(canvas, centerX, centerY, primaryColor, accentColor,
            patternType, expressionType, accessoryType, headSize);
        break;

      case 'fox':
        _drawFox(canvas, centerX, centerY, primaryColor, accentColor,
            patternType, expressionType, accessoryType, headSize);
        break;

      case 'panda':
        _drawPanda(canvas, centerX, centerY, primaryColor, accentColor,
            patternType, expressionType, accessoryType, headSize);
        break;

      case 'penguin':
        _drawPenguin(canvas, centerX, centerY, primaryColor, accentColor,
            patternType, expressionType, accessoryType, headSize);
        break;

      case 'owl':
        _drawOwl(canvas, centerX, centerY, primaryColor, accentColor,
            patternType, expressionType, accessoryType, headSize);
        break;
    }

    // 이름 표시 (선택적)
    _drawNameTag(canvas, centerX, size.height - 20, name);
  }

  // 고양이 캐릭터 그리기
  void _drawCat(
      Canvas canvas,
      double centerX,
      double centerY,
      Color primaryColor,
      Color accentColor,
      int patternType,
      int expressionType,
      int accessoryType,
      double headSize) {
    final radius = headSize / 2;
    final primaryPaint = Paint()..color = primaryColor;
    final accentPaint = Paint()..color = accentColor;

    // 얼굴 그리기
    canvas.drawCircle(Offset(centerX, centerY), radius, primaryPaint);

    // 귀
    final earPath1 = Path();
    earPath1.moveTo(centerX - radius * 0.7, centerY - radius * 0.7);
    earPath1.lineTo(centerX - radius * 0.9, centerY - radius * 1.4);
    earPath1.lineTo(centerX - radius * 0.3, centerY - radius * 0.9);
    earPath1.close();
    canvas.drawPath(earPath1, primaryPaint);

    final earPath2 = Path();
    earPath2.moveTo(centerX + radius * 0.7, centerY - radius * 0.7);
    earPath2.lineTo(centerX + radius * 0.9, centerY - radius * 1.4);
    earPath2.lineTo(centerX + radius * 0.3, centerY - radius * 0.9);
    earPath2.close();
    canvas.drawPath(earPath2, primaryPaint);

    // 귀 내부
    final innerEarPath1 = Path();
    innerEarPath1.moveTo(centerX - radius * 0.65, centerY - radius * 0.75);
    innerEarPath1.lineTo(centerX - radius * 0.8, centerY - radius * 1.2);
    innerEarPath1.lineTo(centerX - radius * 0.4, centerY - radius * 0.85);
    innerEarPath1.close();
    canvas.drawPath(innerEarPath1, accentPaint);

    final innerEarPath2 = Path();
    innerEarPath2.moveTo(centerX + radius * 0.65, centerY - radius * 0.75);
    innerEarPath2.lineTo(centerX + radius * 0.8, centerY - radius * 1.2);
    innerEarPath2.lineTo(centerX + radius * 0.4, centerY - radius * 0.85);
    innerEarPath2.close();
    canvas.drawPath(innerEarPath2, accentPaint);

    // 눈 그리기 (표정에 따라 다름)
    _drawCatEyes(canvas, centerX, centerY, radius, expressionType, accentColor);

    // 코와 입
    canvas.drawCircle(
        Offset(centerX, centerY + radius * 0.1), radius * 0.08, accentPaint);

    // 입 (표정에 따라 다름)
    _drawCatMouth(
        canvas, centerX, centerY, radius, expressionType, accentColor);

    // 수염
    _drawCatWhiskers(canvas, centerX, centerY, radius, accentColor);

    // 패턴 추가
    _drawAnimalPattern(canvas, centerX, centerY, radius, patternType,
        primaryColor, accentColor);

    // 액세서리 추가
    _drawAnimalAccessory(
        canvas, centerX, centerY, radius, accessoryType, accentColor);
  }

  // 고양이 눈 그리기 (표정별)
  void _drawCatEyes(Canvas canvas, double centerX, double centerY,
      double radius, int expressionType, Color accentColor) {
    final eyePaint = Paint()..color = accentColor;
    final whitePaint = Paint()..color = Colors.white;
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.7);

    switch (expressionType) {
      case 0: // 보통 눈
        // 왼쪽 눈
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX - radius * 0.35, centerY - radius * 0.1),
                width: radius * 0.4,
                height: radius * 0.5),
            whitePaint);
        canvas.drawOval(
            Rect.fromCenter(
                center:
                    Offset(centerX - radius * 0.35, centerY - radius * 0.05),
                width: radius * 0.25,
                height: radius * 0.4),
            eyePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.15),
            radius * 0.05,
            highlightPaint);

        // 오른쪽 눈
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX + radius * 0.35, centerY - radius * 0.1),
                width: radius * 0.4,
                height: radius * 0.5),
            whitePaint);
        canvas.drawOval(
            Rect.fromCenter(
                center:
                    Offset(centerX + radius * 0.35, centerY - radius * 0.05),
                width: radius * 0.25,
                height: radius * 0.4),
            eyePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.15),
            radius * 0.05,
            highlightPaint);
        break;

      case 1: // 행복한 눈 (웃는 눈)
        // 왼쪽 눈
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.55, centerY - radius * 0.1);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.35,
            centerY - radius * 0.3,
            centerX - radius * 0.15,
            centerY - radius * 0.1);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.35,
            centerY - radius * 0.05,
            centerX - radius * 0.55,
            centerY - radius * 0.1);
        canvas.drawPath(leftEyePath, eyePaint);

        // 오른쪽 눈
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.55, centerY - radius * 0.1);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.35,
            centerY - radius * 0.3,
            centerX + radius * 0.15,
            centerY - radius * 0.1);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.35,
            centerY - radius * 0.05,
            centerX + radius * 0.55,
            centerY - radius * 0.1);
        canvas.drawPath(rightEyePath, eyePaint);
        break;

      case 2: // 졸린 눈
        // 왼쪽 눈
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.55, centerY - radius * 0.15);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.35,
            centerY - radius * 0.05,
            centerX - radius * 0.15,
            centerY - radius * 0.15);
        canvas.drawPath(leftEyePath, eyePaint);

        // 오른쪽 눈
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.55, centerY - radius * 0.15);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.35,
            centerY - radius * 0.05,
            centerX + radius * 0.15,
            centerY - radius * 0.15);
        canvas.drawPath(rightEyePath, eyePaint);
        break;

      case 3: // 동그란 눈 (놀란 표정)
        // 왼쪽 눈
        canvas.drawCircle(
            Offset(centerX - radius * 0.35, centerY - radius * 0.1),
            radius * 0.2,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.35, centerY - radius * 0.1),
            radius * 0.15,
            eyePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.32, centerY - radius * 0.15),
            radius * 0.05,
            highlightPaint);

        // 오른쪽 눈
        canvas.drawCircle(
            Offset(centerX + radius * 0.35, centerY - radius * 0.1),
            radius * 0.2,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.35, centerY - radius * 0.1),
            radius * 0.15,
            eyePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.32, centerY - radius * 0.15),
            radius * 0.05,
            highlightPaint);
        break;

      case 4: // 하트 눈
        final heartPaint = Paint()..color = Colors.red;

        // 왼쪽 하트 눈
        _drawHeart(canvas, centerX - radius * 0.35, centerY - radius * 0.1,
            radius * 0.2, heartPaint);

        // 오른쪽 하트 눈
        _drawHeart(canvas, centerX + radius * 0.35, centerY - radius * 0.1,
            radius * 0.2, heartPaint);
        break;
    }
  }

  // 고양이 입 그리기 (표정별)
  void _drawCatMouth(Canvas canvas, double centerX, double centerY,
      double radius, int expressionType, Color accentColor) {
    final mouthPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.04;

    switch (expressionType) {
      case 0: // 일반 입
        final mouthPath = Path();
        mouthPath.moveTo(centerX - radius * 0.1, centerY + radius * 0.25);
        mouthPath.lineTo(centerX, centerY + radius * 0.35);
        mouthPath.lineTo(centerX + radius * 0.1, centerY + radius * 0.25);
        canvas.drawPath(mouthPath, mouthPaint);
        break;

      case 1: // 웃는 입
        final mouthPath = Path();
        mouthPath.moveTo(centerX - radius * 0.2, centerY + radius * 0.25);
        mouthPath.quadraticBezierTo(centerX, centerY + radius * 0.45,
            centerX + radius * 0.2, centerY + radius * 0.25);
        canvas.drawPath(mouthPath, mouthPaint);
        break;

      case 2: // 하품하는 입
        final mouthPaint = Paint()..color = accentColor;
        canvas.drawCircle(
            Offset(centerX, centerY + radius * 0.3), radius * 0.12, mouthPaint);

        final innerMouthPaint = Paint()..color = Color(0xFFFF6B6B);
        canvas.drawCircle(Offset(centerX, centerY + radius * 0.3),
            radius * 0.08, innerMouthPaint);
        break;

      case 3: // 놀란 입
        final mouthPaint = Paint()..color = accentColor;
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.3),
                width: radius * 0.25,
                height: radius * 0.2),
            mouthPaint);
        break;

      case 4: // 뾰루퉁한 입
        final mouthPath = Path();
        mouthPath.moveTo(centerX - radius * 0.2, centerY + radius * 0.3);
        mouthPath.quadraticBezierTo(centerX, centerY + radius * 0.2,
            centerX + radius * 0.2, centerY + radius * 0.3);
        canvas.drawPath(mouthPath, mouthPaint);
        break;
    }
  }

  // 고양이 수염 그리기
  void _drawCatWhiskers(Canvas canvas, double centerX, double centerY,
      double radius, Color color) {
    final whiskerPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = radius * 0.02
      ..style = PaintingStyle.stroke;

    // 왼쪽 수염
    canvas.drawLine(Offset(centerX - radius * 0.2, centerY + radius * 0.15),
        Offset(centerX - radius * 0.7, centerY + radius * 0.1), whiskerPaint);
    canvas.drawLine(Offset(centerX - radius * 0.2, centerY + radius * 0.25),
        Offset(centerX - radius * 0.7, centerY + radius * 0.25), whiskerPaint);
    canvas.drawLine(Offset(centerX - radius * 0.2, centerY + radius * 0.35),
        Offset(centerX - radius * 0.7, centerY + radius * 0.4), whiskerPaint);

    // 오른쪽 수염
    canvas.drawLine(Offset(centerX + radius * 0.2, centerY + radius * 0.15),
        Offset(centerX + radius * 0.7, centerY + radius * 0.1), whiskerPaint);
    canvas.drawLine(Offset(centerX + radius * 0.2, centerY + radius * 0.25),
        Offset(centerX + radius * 0.7, centerY + radius * 0.25), whiskerPaint);
    canvas.drawLine(Offset(centerX + radius * 0.2, centerY + radius * 0.35),
        Offset(centerX + radius * 0.7, centerY + radius * 0.4), whiskerPaint);
  }

  // 강아지 캐릭터 그리기
  void _drawDog(
      Canvas canvas,
      double centerX,
      double centerY,
      Color primaryColor,
      Color accentColor,
      int patternType,
      int expressionType,
      int accessoryType,
      double headSize) {
    final radius = headSize / 2;
    final primaryPaint = Paint()..color = primaryColor;
    final accentPaint = Paint()..color = accentColor;

    // 얼굴 그리기
    canvas.drawCircle(Offset(centerX, centerY), radius, primaryPaint);

    // 귀
    final earPaint = Paint()..color = primaryColor;

    // 왼쪽 귀
    final leftEarPath = Path();
    leftEarPath.moveTo(centerX - radius * 0.5, centerY - radius * 0.5);
    leftEarPath.quadraticBezierTo(
        centerX - radius * 0.85,
        centerY - radius * 0.85,
        centerX - radius * 0.9,
        centerY - radius * 0.2);
    leftEarPath.quadraticBezierTo(
        centerX - radius * 0.7,
        centerY - radius * 0.35,
        centerX - radius * 0.5,
        centerY - radius * 0.5);
    canvas.drawPath(leftEarPath, earPaint);

    // 오른쪽 귀
    final rightEarPath = Path();
    rightEarPath.moveTo(centerX + radius * 0.5, centerY - radius * 0.5);
    rightEarPath.quadraticBezierTo(
        centerX + radius * 0.85,
        centerY - radius * 0.85,
        centerX + radius * 0.9,
        centerY - radius * 0.2);
    rightEarPath.quadraticBezierTo(
        centerX + radius * 0.7,
        centerY - radius * 0.35,
        centerX + radius * 0.5,
        centerY - radius * 0.5);
    canvas.drawPath(rightEarPath, earPaint);

    // 눈 그리기
    _drawDogEyes(canvas, centerX, centerY, radius, expressionType, accentColor);

    // 코
    canvas.drawCircle(Offset(centerX, centerY + radius * 0.15), radius * 0.15,
        Paint()..color = Color(0xFF000000));

    // 입
    _drawDogMouth(
        canvas, centerX, centerY, radius, expressionType, accentColor);

    // 패턴 추가
    _drawAnimalPattern(canvas, centerX, centerY, radius, patternType,
        primaryColor, accentColor);

    // 액세서리 추가
    _drawAnimalAccessory(
        canvas, centerX, centerY, radius, accessoryType, accentColor);
  }

  // 강아지 눈 그리기 (표정별)
  // 강아지 눈 그리기 (표정별)
  void _drawDogEyes(Canvas canvas, double centerX, double centerY,
      double radius, int expressionType, Color accentColor) {
    final eyePaint = Paint()..color = accentColor;
    final whitePaint = Paint()..color = Colors.white;
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.7);

    switch (expressionType) {
      case 0: // 보통 눈
        // 왼쪽 눈
        canvas.drawCircle(
            Offset(centerX - radius * 0.35, centerY - radius * 0.15),
            radius * 0.13,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.35, centerY - radius * 0.15),
            radius * 0.08,
            eyePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.33, centerY - radius * 0.17),
            radius * 0.03,
            highlightPaint);

        // 오른쪽 눈
        canvas.drawCircle(
            Offset(centerX + radius * 0.35, centerY - radius * 0.15),
            radius * 0.13,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.35, centerY - radius * 0.15),
            radius * 0.08,
            eyePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.33, centerY - radius * 0.17),
            radius * 0.03,
            highlightPaint);
        break;
      case 1: // 행복한 눈
        // 왼쪽 눈
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.45, centerY - radius * 0.15);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.35,
            centerY - radius * 0.3,
            centerX - radius * 0.25,
            centerY - radius * 0.15);
        canvas.drawPath(leftEyePath, eyePaint);

        // 오른쪽 눈
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.45, centerY - radius * 0.15);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.35,
            centerY - radius * 0.3,
            centerX + radius * 0.25,
            centerY - radius * 0.15);
        canvas.drawPath(rightEyePath, eyePaint);
        break;

      case 2: // 졸린 눈
        // 왼쪽 눈
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.45, centerY - radius * 0.2);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.35,
            centerY - radius * 0.1,
            centerX - radius * 0.25,
            centerY - radius * 0.2);
        canvas.drawPath(leftEyePath, eyePaint);

        // 오른쪽 눈
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.45, centerY - radius * 0.2);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.35,
            centerY - radius * 0.1,
            centerX + radius * 0.25,
            centerY - radius * 0.2);
        canvas.drawPath(rightEyePath, eyePaint);
        break;

      case 3: // 동그란 눈 (놀란 표정)
        // 왼쪽 눈
        canvas.drawCircle(
            Offset(centerX - radius * 0.35, centerY - radius * 0.15),
            radius * 0.18,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.35, centerY - radius * 0.15),
            radius * 0.12,
            eyePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.32, centerY - radius * 0.18),
            radius * 0.04,
            highlightPaint);

        // 오른쪽 눈
        canvas.drawCircle(
            Offset(centerX + radius * 0.35, centerY - radius * 0.15),
            radius * 0.18,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.35, centerY - radius * 0.15),
            radius * 0.12,
            eyePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.32, centerY - radius * 0.18),
            radius * 0.04,
            highlightPaint);
        break;

      case 4: // 하트 눈
        final heartPaint = Paint()..color = Colors.red;

        // 왼쪽 하트 눈
// 왼쪽 하트 눈
        _drawHeart(canvas, centerX - radius * 0.35, centerY - radius * 0.15,
            radius * 0.18, heartPaint);

// 오른쪽 하트 눈
        _drawHeart(canvas, centerX + radius * 0.35, centerY - radius * 0.15,
            radius * 0.18, heartPaint);

        break;
    }
  }

// 강아지 입 그리기 (표정별)
  void _drawDogMouth(Canvas canvas, double centerX, double centerY,
      double radius, int expressionType, Color accentColor) {
    final mouthPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.04;

    final tonguePaint = Paint()..color = Color(0xFFFF9E9E);

    switch (expressionType) {
      case 0: // 일반 입
        final mouthPath = Path();
        mouthPath.moveTo(centerX - radius * 0.2, centerY + radius * 0.3);
        mouthPath.quadraticBezierTo(centerX, centerY + radius * 0.4,
            centerX + radius * 0.2, centerY + radius * 0.3);
        canvas.drawPath(mouthPath, mouthPaint);
        break;

      case 1: // 웃는 입 (혀 내밀기)
        // 입 윤곽
        final mouthPath = Path();
        mouthPath.moveTo(centerX - radius * 0.25, centerY + radius * 0.3);
        mouthPath.quadraticBezierTo(centerX, centerY + radius * 0.5,
            centerX + radius * 0.25, centerY + radius * 0.3);
        canvas.drawPath(mouthPath, mouthPaint);

        // 혀
        final tonguePath = Path();
        tonguePath.moveTo(centerX - radius * 0.1, centerY + radius * 0.4);
        tonguePath.quadraticBezierTo(centerX, centerY + radius * 0.5,
            centerX + radius * 0.1, centerY + radius * 0.4);
        tonguePath.quadraticBezierTo(centerX, centerY + radius * 0.35,
            centerX - radius * 0.1, centerY + radius * 0.4);
        canvas.drawPath(tonguePath, tonguePaint);
        break;

      case 2: // 하품하는 입
        final mouthPaint = Paint()..color = accentColor;
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.35),
                width: radius * 0.3,
                height: radius * 0.25),
            mouthPaint);

        final innerMouthPaint = Paint()..color = Color(0xFFFF6B6B);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.35),
                width: radius * 0.2,
                height: radius * 0.15),
            innerMouthPaint);
        break;

      case 3: // 놀란 입
        final mouthPath = Path();
        mouthPath.addOval(
          Rect.fromCenter(
              center: Offset(centerX, centerY + radius * 0.35),
              width: radius * 0.4,
              height: radius * 0.3),
        );
        canvas.drawPath(mouthPath, mouthPaint);
        break;

      case 4: // 뾰루퉁한 입
        final mouthPath = Path();
        mouthPath.moveTo(centerX - radius * 0.2, centerY + radius * 0.35);
        mouthPath.quadraticBezierTo(centerX, centerY + radius * 0.25,
            centerX + radius * 0.2, centerY + radius * 0.35);
        canvas.drawPath(mouthPath, mouthPaint);
        break;
    }
  }

// 토끼 캐릭터 그리기
  void _drawRabbit(
      Canvas canvas,
      double centerX,
      double centerY,
      Color primaryColor,
      Color accentColor,
      int patternType,
      int expressionType,
      int accessoryType,
      double headSize) {
    final radius = headSize / 2;
    final primaryPaint = Paint()..color = primaryColor;
    final accentPaint = Paint()..color = accentColor;

    // 얼굴 그리기
    canvas.drawCircle(Offset(centerX, centerY), radius, primaryPaint);

    // 긴 귀
    final earPaint = Paint()..color = primaryColor;

    // 왼쪽 귀
    final leftEarPath = Path();
    leftEarPath.moveTo(centerX - radius * 0.4, centerY - radius * 0.5);
    leftEarPath.quadraticBezierTo(centerX - radius * 0.5,
        centerY - radius * 1.8, centerX - radius * 0.2, centerY - radius * 1.0);
    leftEarPath.quadraticBezierTo(centerX - radius * 0.2,
        centerY - radius * 0.7, centerX - radius * 0.4, centerY - radius * 0.5);
    canvas.drawPath(leftEarPath, earPaint);

    // 왼쪽 귀 내부
    final leftInnerEarPath = Path();
    leftInnerEarPath.moveTo(centerX - radius * 0.35, centerY - radius * 0.5);
    leftInnerEarPath.quadraticBezierTo(
        centerX - radius * 0.45,
        centerY - radius * 1.6,
        centerX - radius * 0.25,
        centerY - radius * 1.0);
    leftInnerEarPath.quadraticBezierTo(
        centerX - radius * 0.25,
        centerY - radius * 0.75,
        centerX - radius * 0.35,
        centerY - radius * 0.5);
    canvas.drawPath(leftInnerEarPath, accentPaint);

    // 오른쪽 귀
    final rightEarPath = Path();
    rightEarPath.moveTo(centerX + radius * 0.4, centerY - radius * 0.5);
    rightEarPath.quadraticBezierTo(centerX + radius * 0.5,
        centerY - radius * 1.8, centerX + radius * 0.2, centerY - radius * 1.0);
    rightEarPath.quadraticBezierTo(centerX + radius * 0.2,
        centerY - radius * 0.7, centerX + radius * 0.4, centerY - radius * 0.5);
    canvas.drawPath(rightEarPath, earPaint);

    // 오른쪽 귀 내부
    final rightInnerEarPath = Path();
    rightInnerEarPath.moveTo(centerX + radius * 0.35, centerY - radius * 0.5);
    rightInnerEarPath.quadraticBezierTo(
        centerX + radius * 0.45,
        centerY - radius * 1.6,
        centerX + radius * 0.25,
        centerY - radius * 1.0);
    rightInnerEarPath.quadraticBezierTo(
        centerX + radius * 0.25,
        centerY - radius * 0.75,
        centerX + radius * 0.35,
        centerY - radius * 0.5);
    canvas.drawPath(rightInnerEarPath, accentPaint);

    // 눈
    _drawRabbitEyes(
        canvas, centerX, centerY, radius, expressionType, accentColor);

    // 코
    canvas.drawCircle(Offset(centerX, centerY + radius * 0.05), radius * 0.08,
        Paint()..color = Colors.pink);

    // 입과 수염
    _drawRabbitMouth(
        canvas, centerX, centerY, radius, expressionType, accentColor);

    // 패턴 추가
    _drawAnimalPattern(canvas, centerX, centerY, radius, patternType,
        primaryColor, accentColor);

    // 액세서리 추가
    _drawAnimalAccessory(
        canvas, centerX, centerY, radius, accessoryType, accentColor);
  }

// 토끼 눈 그리기
  void _drawRabbitEyes(Canvas canvas, double centerX, double centerY,
      double radius, int expressionType, Color accentColor) {
    final eyePaint = Paint()..color = accentColor;
    final whitePaint = Paint()..color = Colors.white;
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.7);

    // 표정에 따라 눈 모양 변화
    switch (expressionType) {
      case 0: // 일반 눈
        // 왼쪽 눈
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX - radius * 0.35, centerY - radius * 0.1),
                width: radius * 0.4,
                height: radius * 0.3),
            whitePaint);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX - radius * 0.35, centerY - radius * 0.1),
                width: radius * 0.25,
                height: radius * 0.18),
            eyePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.13),
            radius * 0.05,
            highlightPaint);

        // 오른쪽 눈
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX + radius * 0.35, centerY - radius * 0.1),
                width: radius * 0.4,
                height: radius * 0.3),
            whitePaint);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX + radius * 0.35, centerY - radius * 0.1),
                width: radius * 0.25,
                height: radius * 0.18),
            eyePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.13),
            radius * 0.05,
            highlightPaint);
        break;

      case 1: // 행복한 눈
        // 왼쪽 눈
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.5, centerY - radius * 0.1);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.35,
            centerY - radius * 0.3,
            centerX - radius * 0.2,
            centerY - radius * 0.1);
        canvas.drawPath(leftEyePath, eyePaint);

        // 오른쪽 눈
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.5, centerY - radius * 0.1);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.35,
            centerY - radius * 0.3,
            centerX + radius * 0.2,
            centerY - radius * 0.1);
        canvas.drawPath(rightEyePath, eyePaint);
        break;

      // 나머지 case 구현...
      case 2: // 졸린 눈
        // 왼쪽 눈
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.5, centerY - radius * 0.15);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.35,
            centerY - radius * 0.05,
            centerX - radius * 0.2,
            centerY - radius * 0.15);
        canvas.drawPath(leftEyePath, eyePaint);

        // 오른쪽 눈
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.5, centerY - radius * 0.15);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.35,
            centerY - radius * 0.05,
            centerX + radius * 0.2,
            centerY - radius * 0.15);
        canvas.drawPath(rightEyePath, eyePaint);
        break;

      case 3: // 동그란 눈 (놀란 표정)
        // 왼쪽 눈
        canvas.drawCircle(
            Offset(centerX - radius * 0.35, centerY - radius * 0.1),
            radius * 0.18,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.35, centerY - radius * 0.1),
            radius * 0.12,
            eyePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.32, centerY - radius * 0.13),
            radius * 0.04,
            highlightPaint);

        // 오른쪽 눈
        canvas.drawCircle(
            Offset(centerX + radius * 0.35, centerY - radius * 0.1),
            radius * 0.18,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.35, centerY - radius * 0.1),
            radius * 0.12,
            eyePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.32, centerY - radius * 0.13),
            radius * 0.04,
            highlightPaint);
        break;

      case 4: // 하트 눈
        final heartPaint = Paint()..color = Colors.red;

        // 왼쪽 하트 눈
        _drawHeart(canvas, centerX - radius * 0.35, centerY - radius * 0.1,
            radius * 0.18, heartPaint);

        // 오른쪽 하트 눈
        _drawHeart(canvas, centerX + radius * 0.35, centerY - radius * 0.1,
            radius * 0.18, heartPaint);
        break;
    }
  }

// 토끼 입과 수염 그리기
  void _drawRabbitMouth(Canvas canvas, double centerX, double centerY,
      double radius, int expressionType, Color accentColor) {
    final mouthPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.03;

    // 수염 그리기
    final whiskerPaint = Paint()
      ..color = accentColor.withOpacity(0.5)
      ..strokeWidth = radius * 0.02
      ..style = PaintingStyle.stroke;

    // 왼쪽 수염
    canvas.drawLine(Offset(centerX - radius * 0.15, centerY + radius * 0.15),
        Offset(centerX - radius * 0.6, centerY + radius * 0.1), whiskerPaint);
    canvas.drawLine(Offset(centerX - radius * 0.15, centerY + radius * 0.25),
        Offset(centerX - radius * 0.6, centerY + radius * 0.2), whiskerPaint);

    // 오른쪽 수염
    canvas.drawLine(Offset(centerX + radius * 0.15, centerY + radius * 0.15),
        Offset(centerX + radius * 0.6, centerY + radius * 0.1), whiskerPaint);
    canvas.drawLine(Offset(centerX + radius * 0.15, centerY + radius * 0.25),
        Offset(centerX + radius * 0.6, centerY + radius * 0.2), whiskerPaint);

    // 표정에 따른 입 형태
    switch (expressionType) {
      case 0: // 일반 입
        final mouthPath = Path();
        mouthPath.moveTo(centerX - radius * 0.1, centerY + radius * 0.2);
        mouthPath.lineTo(centerX, centerY + radius * 0.3);
        mouthPath.lineTo(centerX + radius * 0.1, centerY + radius * 0.2);
        canvas.drawPath(mouthPath, mouthPaint);
        break;

      case 1: // 웃는 입
        final mouthPath = Path();
        mouthPath.moveTo(centerX - radius * 0.2, centerY + radius * 0.2);
        mouthPath.quadraticBezierTo(centerX, centerY + radius * 0.4,
            centerX + radius * 0.2, centerY + radius * 0.2);
        canvas.drawPath(mouthPath, mouthPaint);
        break;

      case 2: // 하품하는 입
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.25),
                width: radius * 0.2,
                height: radius * 0.15),
            Paint()..color = Colors.pink.withOpacity(0.7));
        break;

      case 3: // 놀란 입
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.25),
                width: radius * 0.25,
                height: radius * 0.2),
            mouthPaint);
        break;

      case 4: // 뾰루퉁한 입
        final mouthPath = Path();
        mouthPath.moveTo(centerX - radius * 0.2, centerY + radius * 0.3);
        mouthPath.quadraticBezierTo(centerX, centerY + radius * 0.2,
            centerX + radius * 0.2, centerY + radius * 0.3);
        canvas.drawPath(mouthPath, mouthPaint);
        break;
    }
  }

// 곰 캐릭터 그리기
  void _drawBear(
      Canvas canvas,
      double centerX,
      double centerY,
      Color primaryColor,
      Color accentColor,
      int patternType,
      int expressionType,
      int accessoryType,
      double headSize) {
    final radius = headSize / 2;
    final primaryPaint = Paint()..color = primaryColor;
    final accentPaint = Paint()..color = accentColor;

    // 얼굴 그리기
    canvas.drawCircle(Offset(centerX, centerY), radius, primaryPaint);

    // 귀
    // 왼쪽 귀
    canvas.drawCircle(Offset(centerX - radius * 0.5, centerY - radius * 0.6),
        radius * 0.25, primaryPaint);

    // 오른쪽 귀
    canvas.drawCircle(Offset(centerX + radius * 0.5, centerY - radius * 0.6),
        radius * 0.25, primaryPaint);

    // 코
    canvas.drawCircle(Offset(centerX, centerY + radius * 0.15), radius * 0.18,
        Paint()..color = Colors.black);

    // 눈 그리기
    _drawBearEyes(
        canvas, centerX, centerY, radius, expressionType, accentColor);

    // 입 그리기
    _drawBearMouth(
        canvas, centerX, centerY, radius, expressionType, accentColor);

    // 패턴 추가
    _drawAnimalPattern(canvas, centerX, centerY, radius, patternType,
        primaryColor, accentColor);

    // 액세서리 추가
    _drawAnimalAccessory(
        canvas, centerX, centerY, radius, accessoryType, accentColor);
  }

// 곰 눈 그리기
  void _drawBearEyes(Canvas canvas, double centerX, double centerY,
      double radius, int expressionType, Color accentColor) {
    final eyePaint = Paint()..color = accentColor;
    final whitePaint = Paint()..color = Colors.white;

    switch (expressionType) {
      case 0: // 일반 눈
        // 왼쪽 눈
        canvas.drawCircle(
            Offset(centerX - radius * 0.25, centerY - radius * 0.1),
            radius * 0.08,
            eyePaint);

        // 오른쪽 눈
        canvas.drawCircle(
            Offset(centerX + radius * 0.25, centerY - radius * 0.1),
            radius * 0.08,
            eyePaint);
        break;

      case 1: // 행복한 눈
        // 왼쪽 눈
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.35, centerY - radius * 0.1);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.25,
            centerY - radius * 0.3,
            centerX - radius * 0.15,
            centerY - radius * 0.1);
        canvas.drawPath(leftEyePath, eyePaint);

        // 오른쪽 눈
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.35, centerY - radius * 0.1);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.25,
            centerY - radius * 0.3,
            centerX + radius * 0.15,
            centerY - radius * 0.1);
        canvas.drawPath(rightEyePath, eyePaint);
        break;

      case 2: // 졸린 눈
        // 왼쪽 눈
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.35, centerY - radius * 0.15);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.25,
            centerY - radius * 0.05,
            centerX - radius * 0.15,
            centerY - radius * 0.15);
        canvas.drawPath(leftEyePath, eyePaint);

        // 오른쪽 눈
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.35, centerY - radius * 0.15);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.25,
            centerY - radius * 0.05,
            centerX + radius * 0.15,
            centerY - radius * 0.15);
        canvas.drawPath(rightEyePath, eyePaint);
        break;

      case 3: // 동그란 눈 (놀란 표정)
        // 왼쪽 눈
        canvas.drawCircle(
            Offset(centerX - radius * 0.25, centerY - radius * 0.1),
            radius * 0.12,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.25, centerY - radius * 0.1),
            radius * 0.08,
            eyePaint);

        // 오른쪽 눈
        canvas.drawCircle(
            Offset(centerX + radius * 0.25, centerY - radius * 0.1),
            radius * 0.12,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.25, centerY - radius * 0.1),
            radius * 0.08,
            eyePaint);
        break;

      case 4: // 하트 눈
        final heartPaint = Paint()..color = Colors.red;

        // 왼쪽 하트 눈
        _drawHeart(canvas, centerX - radius * 0.25, centerY - radius * 0.1,
            radius * 0.15, heartPaint);

        // 오른쪽 하트 눈
        _drawHeart(canvas, centerX + radius * 0.25, centerY - radius * 0.1,
            radius * 0.15, heartPaint);
        break;
    }
  }

// 곰 입 그리기
  void _drawBearMouth(Canvas canvas, double centerX, double centerY,
      double radius, int expressionType, Color accentColor) {
    final mouthPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.03;

    switch (expressionType) {
      case 0: // 일반 입
        canvas.drawArc(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.3),
                width: radius * 0.3,
                height: radius * 0.2),
            0.2,
            pi - 0.4,
            false,
            mouthPaint);
        break;

      case 1: // 웃는 입
        canvas.drawArc(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.3),
                width: radius * 0.5,
                height: radius * 0.3),
            0.2,
            pi - 0.4,
            false,
            mouthPaint);
        break;

      case 2: // 하품하는 입
        final mouthPath = Path();
        mouthPath.addOval(
          Rect.fromCenter(
              center: Offset(centerX, centerY + radius * 0.35),
              width: radius * 0.25,
              height: radius * 0.2),
        );
        canvas.drawPath(
            mouthPath, Paint()..color = Colors.black.withOpacity(0.3));
        break;

      case 3: // 놀란 입
        final mouthPaint = Paint()..color = accentColor;
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.4),
                width: radius * 0.2,
                height: radius * 0.25),
            mouthPaint);
        break;

      case 4: // 뾰루퉁한 입
        canvas.drawArc(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.45),
                width: radius * 0.4,
                height: radius * 0.25),
            pi + 0.2,
            pi - 0.4,
            false,
            mouthPaint);
        break;
    }
  }

// 여우 캐릭터 그리기
  void _drawFox(
      Canvas canvas,
      double centerX,
      double centerY,
      Color primaryColor,
      Color accentColor,
      int patternType,
      int expressionType,
      int accessoryType,
      double headSize) {
    final radius = headSize / 2;
    final primaryPaint = Paint()..color = primaryColor;
    final accentPaint = Paint()..color = accentColor;

    // 얼굴 그리기
    canvas.drawCircle(Offset(centerX, centerY), radius, primaryPaint);

    // 귀
    // 왼쪽 귀
    final leftEarPath = Path();
    leftEarPath.moveTo(centerX - radius * 0.3, centerY - radius * 0.5);
    leftEarPath.lineTo(centerX - radius * 0.7, centerY - radius * 1.2);
    leftEarPath.lineTo(centerX - radius * 0.1, centerY - radius * 0.7);
    leftEarPath.close();
    canvas.drawPath(leftEarPath, primaryPaint);

    // 오른쪽 귀
    final rightEarPath = Path();
    rightEarPath.moveTo(centerX + radius * 0.3, centerY - radius * 0.5);
    rightEarPath.lineTo(centerX + radius * 0.7, centerY - radius * 1.2);
    rightEarPath.lineTo(centerX + radius * 0.1, centerY - radius * 0.7);
    rightEarPath.close();
    canvas.drawPath(rightEarPath, primaryPaint);

    // 얼굴 특징 - 여우 특유의 흰색 부분
    final faceMaskPath = Path();
    faceMaskPath.moveTo(centerX - radius * 0.2, centerY + radius * 0.3);
    faceMaskPath.quadraticBezierTo(centerX, centerY + radius * 0.5,
        centerX + radius * 0.2, centerY + radius * 0.3);
    faceMaskPath.quadraticBezierTo(centerX, centerY - radius * 0.3,
        centerX - radius * 0.2, centerY + radius * 0.3);
    canvas.drawPath(faceMaskPath, Paint()..color = Colors.white);

    // 눈 그리기
    _drawFoxEyes(canvas, centerX, centerY, radius, expressionType, accentColor);

    // 코
    canvas.drawCircle(Offset(centerX, centerY + radius * 0.1), radius * 0.08,
        Paint()..color = Colors.black);

    // 입
    _drawFoxMouth(
        canvas, centerX, centerY, radius, expressionType, accentColor);

    // 패턴 추가
    _drawAnimalPattern(canvas, centerX, centerY, radius, patternType,
        primaryColor, accentColor);

    // 액세서리 추가
    _drawAnimalAccessory(
        canvas, centerX, centerY, radius, accessoryType, accentColor);
  }

// 여우 눈 그리기
  void _drawFoxEyes(Canvas canvas, double centerX, double centerY,
      double radius, int expressionType, Color accentColor) {
    final eyePaint = Paint()..color = accentColor;
    final whitePaint = Paint()..color = Colors.white;
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.7);

    switch (expressionType) {
      case 0: // 일반 눈
        // 왼쪽 눈
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX - radius * 0.3, centerY - radius * 0.1),
                width: radius * 0.25,
                height: radius * 0.15),
            whitePaint);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX - radius * 0.3, centerY - radius * 0.1),
                width: radius * 0.15,
                height: radius * 0.08),
            eyePaint);

        // 오른쪽 눈
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX + radius * 0.3, centerY - radius * 0.1),
                width: radius * 0.25,
                height: radius * 0.15),
            whitePaint);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX + radius * 0.3, centerY - radius * 0.1),
                width: radius * 0.15,
                height: radius * 0.08),
            eyePaint);
        break;

      // 다른 표정들 구현...
      case 1: // 행복한 눈
        // 왼쪽 눈
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.4, centerY - radius * 0.1);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.3,
            centerY - radius * 0.25,
            centerX - radius * 0.2,
            centerY - radius * 0.1);
        canvas.drawPath(leftEyePath, eyePaint);

        // 오른쪽 눈
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.4, centerY - radius * 0.1);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.3,
            centerY - radius * 0.25,
            centerX + radius * 0.2,
            centerY - radius * 0.1);
        canvas.drawPath(rightEyePath, eyePaint);
        break;

      case 2: // 졸린 눈
        // 왼쪽 눈
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.4, centerY - radius * 0.1);
        leftEyePath.quadraticBezierTo(centerX - radius * 0.3, centerY,
            centerX - radius * 0.2, centerY - radius * 0.1);
        canvas.drawPath(leftEyePath, eyePaint);

        // 오른쪽 눈
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.4, centerY - radius * 0.1);
        rightEyePath.quadraticBezierTo(centerX + radius * 0.3, centerY,
            centerX + radius * 0.2, centerY - radius * 0.1);
        canvas.drawPath(rightEyePath, eyePaint);
        break;

      case 3: // 동그란 눈 (놀란 표정)
        // 왼쪽 눈
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.1),
            radius * 0.15,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.1),
            radius * 0.1,
            eyePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.28, centerY - radius * 0.13),
            radius * 0.03,
            highlightPaint);

        // 오른쪽 눈
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.1),
            radius * 0.15,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.1),
            radius * 0.1,
            eyePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.28, centerY - radius * 0.13),
            radius * 0.03,
            highlightPaint);
        break;

      case 4: // 하트 눈
        final heartPaint = Paint()..color = Colors.red;

        // 왼쪽 하트 눈
        _drawHeart(canvas, centerX - radius * 0.3, centerY - radius * 0.1,
            radius * 0.15, heartPaint);

        // 오른쪽 하트 눈
        _drawHeart(canvas, centerX + radius * 0.3, centerY - radius * 0.1,
            radius * 0.15, heartPaint);
        break;
    }
  }

// 여우 입 그리기
  void _drawFoxMouth(Canvas canvas, double centerX, double centerY,
      double radius, int expressionType, Color accentColor) {
    final mouthPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.03;

    switch (expressionType) {
      case 0: // 일반 입
        final mouthPath = Path();
        mouthPath.moveTo(centerX - radius * 0.15, centerY + radius * 0.2);
        mouthPath.lineTo(centerX, centerY + radius * 0.3);
        mouthPath.lineTo(centerX + radius * 0.15, centerY + radius * 0.2);
        canvas.drawPath(mouthPath, mouthPaint);
        break;

      case 1: // 웃는 입
        final mouthPath = Path();
        mouthPath.moveTo(centerX - radius * 0.25, centerY + radius * 0.2);
        mouthPath.quadraticBezierTo(centerX, centerY + radius * 0.4,
            centerX + radius * 0.25, centerY + radius * 0.2);
        canvas.drawPath(mouthPath, mouthPaint);
        break;

      case 2: // 하품하는 입
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.25),
                width: radius * 0.25,
                height: radius * 0.2),
            Paint()..color = Colors.black.withOpacity(0.2));
        break;

      case 3: // 놀란 입
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.25),
                width: radius * 0.2,
                height: radius * 0.25),
            mouthPaint);
        break;

      case 4: // 뾰루퉁한 입
        final mouthPath = Path();
        mouthPath.moveTo(centerX - radius * 0.25, centerY + radius * 0.3);
        mouthPath.quadraticBezierTo(centerX, centerY + radius * 0.2,
            centerX + radius * 0.25, centerY + radius * 0.3);
        canvas.drawPath(mouthPath, mouthPaint);
        break;
    }
  }

  // 판다 입 그리기
  void _drawPandaMouth(Canvas canvas, double centerX, double centerY,
      double radius, int expressionType) {
    final whitePaint = Paint()..color = Colors.white;
    final mouthPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.04;

    switch (expressionType) {
      case 0: // 일반 입
        canvas.drawArc(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.3),
                width: radius * 0.3,
                height: radius * 0.2),
            0.2,
            pi - 0.4,
            false,
            mouthPaint);
        break;

      case 1: // 웃는 입
        canvas.drawArc(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.3),
                width: radius * 0.5,
                height: radius * 0.3),
            0.2,
            pi - 0.4,
            false,
            mouthPaint);
        break;

      case 2: // 하품하는 입
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.35),
                width: radius * 0.25,
                height: radius * 0.2),
            Paint()..color = Colors.pink.withOpacity(0.7));
        break;

      case 3: // 놀란 입
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.35),
                width: radius * 0.2,
                height: radius * 0.25),
            mouthPaint);
        break;

      case 4: // 뾰루퉁한 입
        canvas.drawArc(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.45),
                width: radius * 0.4,
                height: radius * 0.25),
            pi + 0.2,
            pi - 0.4,
            false,
            mouthPaint);
        break;
    }
  }

// 판다 캐릭터 그리기
  void _drawPanda(
      Canvas canvas,
      double centerX,
      double centerY,
      Color primaryColor,
      Color accentColor,
      int patternType,
      int expressionType,
      int accessoryType,
      double headSize) {
    final radius = headSize / 2;

    // 판다는 색상을 무시하고 항상 흑백 컬러로 고정
    final whitePaint = Paint()..color = Colors.white;
    final blackPaint = Paint()..color = Colors.black;

    // 얼굴 그리기 (기본 흰색)
    canvas.drawCircle(Offset(centerX, centerY), radius, whitePaint);

    // 귀
    // 왼쪽 귀
    canvas.drawCircle(Offset(centerX - radius * 0.5, centerY - radius * 0.6),
        radius * 0.25, blackPaint);

    // 오른쪽 귀
    canvas.drawCircle(Offset(centerX + radius * 0.5, centerY - radius * 0.6),
        radius * 0.25, blackPaint);

    // 눈 주변 검은 패치
    // 왼쪽 눈 패치
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(centerX - radius * 0.3, centerY - radius * 0.1),
            width: radius * 0.5,
            height: radius * 0.4),
        blackPaint);

    // 오른쪽 눈 패치
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(centerX + radius * 0.3, centerY - radius * 0.1),
            width: radius * 0.5,
            height: radius * 0.4),
        blackPaint);

    // 코 주변 검은 패치
    final nosePatchPath = Path();
    nosePatchPath.addOval(
      Rect.fromCenter(
          center: Offset(centerX, centerY + radius * 0.2),
          width: radius * 0.7,
          height: radius * 0.5),
    );
    canvas.drawPath(nosePatchPath, blackPaint);

    // 코
    canvas.drawCircle(
        Offset(centerX, centerY + radius * 0.15), radius * 0.12, blackPaint);

    // 눈 그리기
    _drawPandaEyes(canvas, centerX, centerY, radius, expressionType);

    // 입 그리기
    _drawPandaMouth(canvas, centerX, centerY, radius, expressionType);

    // 액세서리 추가
    _drawAnimalAccessory(
        canvas, centerX, centerY, radius, accessoryType, accentColor);
  }

// 판다 눈 그리기
  void _drawPandaEyes(Canvas canvas, double centerX, double centerY,
      double radius, int expressionType) {
    final whitePaint = Paint()..color = Colors.white;
    final blackPaint = Paint()..color = Colors.black;

    switch (expressionType) {
      case 0: // 일반 눈
        // 왼쪽 눈
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.1),
            radius * 0.1,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.1),
            radius * 0.05,
            blackPaint);

        // 오른쪽 눈
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.1),
            radius * 0.1,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.1),
            radius * 0.05,
            blackPaint);
        break;

      case 1: // 행복한 눈
        // 왼쪽 눈
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.4, centerY - radius * 0.1);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.3,
            centerY - radius * 0.25,
            centerX - radius * 0.2,
            centerY - radius * 0.1);
        canvas.drawPath(leftEyePath, whitePaint);

        // 오른쪽 눈
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.4, centerY - radius * 0.1);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.3,
            centerY - radius * 0.25,
            centerX + radius * 0.2,
            centerY - radius * 0.1);
        canvas.drawPath(rightEyePath, whitePaint);
        break;

      case 2: // 졸린 눈
        // 왼쪽 눈
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.4, centerY - radius * 0.15);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.3,
            centerY - radius * 0.05,
            centerX - radius * 0.2,
            centerY - radius * 0.15);
        canvas.drawPath(leftEyePath, whitePaint);

        // 오른쪽 눈
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.4, centerY - radius * 0.15);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.3,
            centerY - radius * 0.05,
            centerX + radius * 0.2,
            centerY - radius * 0.15);
        canvas.drawPath(rightEyePath, whitePaint);
        break;

      case 3: // 동그란 눈 (놀란 표정)
        // 왼쪽 눈
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.1),
            radius * 0.15,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.1),
            radius * 0.08,
            blackPaint);

        // 오른쪽 눈
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.1),
            radius * 0.15,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.1),
            radius * 0.08,
            blackPaint);
        break;

      case 4: // 하트 눈
        final redPaint = Paint()..color = Colors.red;

        // 왼쪽 하트 눈
        _drawHeart(canvas, centerX - radius * 0.3, centerY - radius * 0.1,
            radius * 0.15, redPaint);

        // 오른쪽 하트 눈
        _drawHeart(canvas, centerX + radius * 0.3, centerY - radius * 0.1,
            radius * 0.15, redPaint);
        break;
    }
  }

// 펭귄 캐릭터 그리기
  void _drawPenguin(
      Canvas canvas,
      double centerX,
      double centerY,
      Color primaryColor,
      Color accentColor,
      int patternType,
      int expressionType,
      int accessoryType,
      double headSize) {
    final radius = headSize / 2;

    // 펭귄은 기본 색상을 무시하고 항상 검정/흰색
    final blackPaint = Paint()..color = Colors.black;
    final whitePaint = Paint()..color = Colors.white;

    // 얼굴 그리기 (검은색)
    canvas.drawCircle(Offset(centerX, centerY), radius, blackPaint);

    // 얼굴의 흰색 부분
    final faceMaskPath = Path();
    faceMaskPath.addOval(
      Rect.fromCenter(
          center: Offset(centerX, centerY + radius * 0.3),
          width: radius * 1.4,
          height: radius * 1.2),
    );
    canvas.drawPath(faceMaskPath, whitePaint);

    // 부리
    final beakPath = Path();
    beakPath.addOval(
      Rect.fromCenter(
          center: Offset(centerX, centerY + radius * 0.1),
          width: radius * 0.5,
          height: radius * 0.3),
    );
    canvas.drawPath(beakPath, Paint()..color = Color(0xFFFFA500)); // 주황색 부리

    // 눈 그리기
    _drawPenguinEyes(canvas, centerX, centerY, radius, expressionType);

    // 입 그리기 (표정에 따라)
    _drawPenguinMouth(canvas, centerX, centerY, radius, expressionType);

    // 액세서리 추가
    _drawAnimalAccessory(
        canvas, centerX, centerY, radius, accessoryType, accentColor);
  }

// 펭귄 눈 그리기
  void _drawPenguinEyes(Canvas canvas, double centerX, double centerY,
      double radius, int expressionType) {
    final whitePaint = Paint()..color = Colors.white;
    final blackPaint = Paint()..color = Colors.black;

    switch (expressionType) {
      case 0: // 일반 눈
        // 왼쪽 눈
        canvas.drawCircle(
            Offset(centerX - radius * 0.25, centerY - radius * 0.15),
            radius * 0.1,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.25, centerY - radius * 0.15),
            radius * 0.06,
            blackPaint);

        // 오른쪽 눈
        canvas.drawCircle(
            Offset(centerX + radius * 0.25, centerY - radius * 0.15),
            radius * 0.1,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.25, centerY - radius * 0.15),
            radius * 0.06,
            blackPaint);
        break;
        break;

      case 1: // 행복한 눈
        // 왼쪽 눈
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.35, centerY - radius * 0.15);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.25,
            centerY - radius * 0.3,
            centerX - radius * 0.15,
            centerY - radius * 0.15);
        canvas.drawPath(leftEyePath, whitePaint);

        // 오른쪽 눈
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.35, centerY - radius * 0.15);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.25,
            centerY - radius * 0.3,
            centerX + radius * 0.15,
            centerY - radius * 0.15);
        canvas.drawPath(rightEyePath, whitePaint);
        break;

      case 2: // 졸린 눈
        // 왼쪽 눈
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.35, centerY - radius * 0.15);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.25,
            centerY - radius * 0.05,
            centerX - radius * 0.15,
            centerY - radius * 0.15);
        canvas.drawPath(leftEyePath, whitePaint);

        // 오른쪽 눈
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.35, centerY - radius * 0.15);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.25,
            centerY - radius * 0.05,
            centerX + radius * 0.15,
            centerY - radius * 0.15);
        canvas.drawPath(rightEyePath, whitePaint);
        break;

      case 3: // 동그란 눈 (놀란 표정)
        // 왼쪽 눈
        canvas.drawCircle(
            Offset(centerX - radius * 0.25, centerY - radius * 0.15),
            radius * 0.15,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.25, centerY - radius * 0.15),
            radius * 0.1,
            blackPaint);

        // 오른쪽 눈
        canvas.drawCircle(
            Offset(centerX + radius * 0.25, centerY - radius * 0.15),
            radius * 0.15,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.25, centerY - radius * 0.15),
            radius * 0.1,
            blackPaint);
        break;

      case 4: // 하트 눈
        final redPaint = Paint()..color = Colors.red;

        // 왼쪽 하트 눈
        _drawHeart(canvas, centerX - radius * 0.25, centerY - radius * 0.15,
            radius * 0.15, redPaint);

        // 오른쪽 하트 눈
        _drawHeart(canvas, centerX + radius * 0.25, centerY - radius * 0.15,
            radius * 0.15, redPaint);
        break;
    }
  }

// 펭귄 입 그리기
  void _drawPenguinMouth(Canvas canvas, double centerX, double centerY,
      double radius, int expressionType) {
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.03;

    switch (expressionType) {
      case 0: // 일반 입 - 작은 선
        canvas.drawLine(
            Offset(centerX - radius * 0.1, centerY + radius * 0.25),
            Offset(centerX + radius * 0.1, centerY + radius * 0.25),
            mouthPaint);
        break;

      case 1: // 웃는 입
        final mouthPath = Path();
        mouthPath.moveTo(centerX - radius * 0.15, centerY + radius * 0.25);
        mouthPath.quadraticBezierTo(centerX, centerY + radius * 0.35,
            centerX + radius * 0.15, centerY + radius * 0.25);
        canvas.drawPath(mouthPath, mouthPaint);
        break;

      case 2: // 하품하는 입
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(centerX, centerY + radius * 0.3),
                width: radius * 0.15,
                height: radius * 0.1),
            Paint()..color = Colors.black.withOpacity(0.2));
        break;

      case 3: // 놀란 입
        canvas.drawCircle(Offset(centerX, centerY + radius * 0.3),
            radius * 0.08, Paint()..color = Colors.black.withOpacity(0.3));
        break;

      case 4: // 뾰루퉁한 입
        final mouthPath = Path();
        mouthPath.moveTo(centerX - radius * 0.15, centerY + radius * 0.25);
        mouthPath.quadraticBezierTo(centerX, centerY + radius * 0.15,
            centerX + radius * 0.15, centerY + radius * 0.25);
        canvas.drawPath(mouthPath, mouthPaint);
        break;
    }
  }

// 부엉이 캐릭터 그리기
  void _drawOwl(
      Canvas canvas,
      double centerX,
      double centerY,
      Color primaryColor,
      Color accentColor,
      int patternType,
      int expressionType,
      int accessoryType,
      double headSize) {
    final radius = headSize / 2;
    final primaryPaint = Paint()..color = primaryColor;
    final accentPaint = Paint()..color = accentColor;

    // 얼굴 그리기
    canvas.drawCircle(Offset(centerX, centerY), radius, primaryPaint);

    // 귀/뿔 (부엉이의 특징)
    // 왼쪽 귀
    final leftEarPath = Path();
    leftEarPath.moveTo(centerX - radius * 0.4, centerY - radius * 0.4);
    leftEarPath.lineTo(centerX - radius * 0.6, centerY - radius * 1.0);
    leftEarPath.lineTo(centerX - radius * 0.2, centerY - radius * 0.4);
    leftEarPath.close();
    canvas.drawPath(leftEarPath, primaryPaint);

    // 오른쪽 귀
    final rightEarPath = Path();
    rightEarPath.moveTo(centerX + radius * 0.4, centerY - radius * 0.4);
    rightEarPath.lineTo(centerX + radius * 0.6, centerY - radius * 1.0);
    rightEarPath.lineTo(centerX + radius * 0.2, centerY - radius * 0.4);
    rightEarPath.close();
    canvas.drawPath(rightEarPath, primaryPaint);

    // 얼굴 주변 특징 (부엉이의 얼굴 디스크)
    final faceDiskPath = Path();
    faceDiskPath.addOval(
      Rect.fromCenter(
          center: Offset(centerX, centerY + radius * 0.05),
          width: radius * 1.6,
          height: radius * 1.5),
    );
    canvas.drawPath(faceDiskPath,
        Paint()..color = Color.lerp(primaryColor, Colors.white, 0.3)!);

    // 부리
    final beakPath = Path();
    beakPath.moveTo(centerX - radius * 0.1, centerY + radius * 0.1);
    beakPath.lineTo(centerX, centerY + radius * 0.3);
    beakPath.lineTo(centerX + radius * 0.1, centerY + radius * 0.1);
    beakPath.close();
    canvas.drawPath(beakPath, Paint()..color = Color(0xFFFFA500)); // 주황색 부리

    // 눈 그리기
    _drawOwlEyes(canvas, centerX, centerY, radius, expressionType, accentColor);

    // 패턴 추가
    _drawAnimalPattern(canvas, centerX, centerY, radius, patternType,
        primaryColor, accentColor);

    // 액세서리 추가
    _drawAnimalAccessory(
        canvas, centerX, centerY, radius, accessoryType, accentColor);
  }

// 부엉이 눈 그리기
  void _drawOwlEyes(Canvas canvas, double centerX, double centerY,
      double radius, int expressionType, Color accentColor) {
    final whitePaint = Paint()..color = Colors.white;
    final eyePaint = Paint()..color = accentColor;
    final blackPaint = Paint()..color = Colors.black;

    // 부엉이의 큰 눈이 특징
    switch (expressionType) {
      case 0: // 일반 눈
        // 왼쪽 눈
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.05),
            radius * 0.25,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.05),
            radius * 0.15,
            eyePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.05),
            radius * 0.07,
            blackPaint);

        // 오른쪽 눈
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.05),
            radius * 0.25,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.05),
            radius * 0.15,
            eyePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.05),
            radius * 0.07,
            blackPaint);
        break;

      case 1: // 행복한 눈
        // 왼쪽 눈
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.05),
            radius * 0.25,
            whitePaint);
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.45, centerY - radius * 0.05);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.3,
            centerY - radius * 0.15,
            centerX - radius * 0.15,
            centerY - radius * 0.05);
        canvas.drawPath(leftEyePath, eyePaint);

        // 오른쪽 눈
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.05),
            radius * 0.25,
            whitePaint);
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.45, centerY - radius * 0.05);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.3,
            centerY - radius * 0.15,
            centerX + radius * 0.15,
            centerY - radius * 0.05);
        canvas.drawPath(rightEyePath, eyePaint);
        break;

      case 2: // 졸린 눈
        // 왼쪽 눈
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.05),
            radius * 0.25,
            whitePaint);
        final leftEyePath = Path();
        leftEyePath.moveTo(centerX - radius * 0.45, centerY - radius * 0.05);
        leftEyePath.quadraticBezierTo(
            centerX - radius * 0.3,
            centerY + radius * 0.05,
            centerX - radius * 0.15,
            centerY - radius * 0.05);
        canvas.drawPath(leftEyePath, eyePaint);

        // 오른쪽 눈
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.05),
            radius * 0.25,
            whitePaint);
        final rightEyePath = Path();
        rightEyePath.moveTo(centerX + radius * 0.45, centerY - radius * 0.05);
        rightEyePath.quadraticBezierTo(
            centerX + radius * 0.3,
            centerY + radius * 0.05,
            centerX + radius * 0.15,
            centerY - radius * 0.05);
        canvas.drawPath(rightEyePath, eyePaint);
        break;

      case 3: // 놀란 눈
        // 왼쪽 눈
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.05),
            radius * 0.28,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.05),
            radius * 0.2,
            eyePaint);
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.05),
            radius * 0.1,
            blackPaint);

        // 오른쪽 눈
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.05),
            radius * 0.28,
            whitePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.05),
            radius * 0.2,
            eyePaint);
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.05),
            radius * 0.1,
            blackPaint);
        break;

      case 4: // 하트 눈
        // 왼쪽 눈 배경
        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.05),
            radius * 0.25,
            whitePaint);

        // 왼쪽 하트 눈
        _drawHeart(canvas, centerX - radius * 0.3, centerY - radius * 0.05,
            radius * 0.18, Paint()..color = Colors.red);

        // 오른쪽 눈 배경
        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.05),
            radius * 0.25,
            whitePaint);

        // 오른쪽 하트 눈
        _drawHeart(canvas, centerX + radius * 0.3, centerY - radius * 0.05,
            radius * 0.18, Paint()..color = Colors.red);
        break;
    }
  }

// 동물 패턴 그리기
  void _drawAnimalPattern(Canvas canvas, double centerX, double centerY,
      double radius, int patternType, Color primaryColor, Color accentColor) {
    final patternPaint = Paint()..color = accentColor.withOpacity(0.6);

    switch (patternType) {
      case 0: // 패턴 없음
        break;

      case 1: // 점박이 패턴
        final spotCount = 8 + _getValueFromByte(hash[27], 8);
        final spotRadius = radius * 0.1;
        final Random random = Random(_getValueFromByte(hash[28], 1000));

        for (var i = 0; i < spotCount; i++) {
          final angle = random.nextDouble() * 2 * pi;
          final distance = random.nextDouble() * radius * 0.7;

          canvas.drawCircle(
              Offset(centerX + cos(angle) * distance,
                  centerY + sin(angle) * distance),
              spotRadius * (0.5 + random.nextDouble() * 0.5),
              patternPaint);
        }
        break;

      case 2: // 줄무늬 패턴
        final stripeCount = 3 + _getValueFromByte(hash[29], 3);
        final stripeWidth = radius * 0.1;

        for (var i = 0; i < stripeCount; i++) {
          final yOffset = radius * (-0.5 + i * 0.5);

          canvas.drawLine(
              Offset(centerX - radius * 0.7, centerY + yOffset),
              Offset(centerX + radius * 0.7, centerY + yOffset),
              Paint()
                ..color = accentColor.withOpacity(0.6)
                ..strokeWidth = stripeWidth);
        }
        break;

      case 3: // 반점 패턴 (마블링)
        final Random random = Random(_getValueFromByte(hash[30], 1000));
        final patchCount = 4 + random.nextInt(4);

        for (var i = 0; i < patchCount; i++) {
          final angle = random.nextDouble() * 2 * pi;
          final distance = random.nextDouble() * radius * 0.6;
          final patchPath = Path();
          final patchSize = radius * (0.2 + random.nextDouble() * 0.3);

          patchPath.addOval(
            Rect.fromCenter(
                center: Offset(centerX + cos(angle) * distance,
                    centerY + sin(angle) * distance),
                width: patchSize * (1.0 + random.nextDouble()),
                height: patchSize * (1.0 + random.nextDouble())),
          );

          canvas.drawPath(patchPath, patternPaint);
        }
        break;

      case 4: // 얼룩 패턴
        final patternPath = Path();
        patternPath.moveTo(centerX - radius * 0.3, centerY - radius * 0.4);
        patternPath.quadraticBezierTo(centerX - radius * 0.6, centerY,
            centerX - radius * 0.2, centerY + radius * 0.4);
        patternPath.quadraticBezierTo(centerX + radius * 0.2, centerY,
            centerX + radius * 0.3, centerY - radius * 0.3);
        patternPath.quadraticBezierTo(centerX, centerY - radius * 0.6,
            centerX - radius * 0.3, centerY - radius * 0.4);

        canvas.drawPath(patternPath, patternPaint);
        break;

      case 5: // 그라데이션 패턴
        final gradientPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              primaryColor,
              accentColor.withOpacity(0.7),
            ],
            stops: [0.6, 1.0],
          ).createShader(
            Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
          );

        canvas.drawCircle(
            Offset(centerX, centerY), radius * 0.95, gradientPaint);
        break;
    }
  }

// 액세서리 그리기
  void _drawAnimalAccessory(Canvas canvas, double centerX, double centerY,
      double radius, int accessoryType, Color accentColor) {
    final accentPaint = Paint()..color = accentColor;

    switch (accessoryType) {
      case 0: // 액세서리 없음
        break;

      case 1: // 모자
        final hatPath = Path();
        hatPath.moveTo(centerX - radius * 0.7, centerY - radius * 0.5);
        hatPath.lineTo(centerX - radius * 0.3, centerY - radius * 1.2);
        hatPath.lineTo(centerX + radius * 0.3, centerY - radius * 1.2);
        hatPath.lineTo(centerX + radius * 0.7, centerY - radius * 0.5);
        hatPath.close();

        canvas.drawPath(hatPath, accentPaint);
        break;

      case 2: // 안경
        final glassesPaint = Paint()
          ..color = accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.05;

        // 왼쪽 렌즈
        canvas.drawCircle(
            Offset(centerX - radius * 0.35, centerY - radius * 0.1),
            radius * 0.2,
            glassesPaint);

        // 오른쪽 렌즈
        canvas.drawCircle(
            Offset(centerX + radius * 0.35, centerY - radius * 0.1),
            radius * 0.2,
            glassesPaint);

        // 다리
        canvas.drawLine(
            Offset(centerX - radius * 0.15, centerY - radius * 0.1),
            Offset(centerX + radius * 0.15, centerY - radius * 0.1),
            glassesPaint);

        // 다리 끝
        canvas.drawLine(
            Offset(centerX - radius * 0.55, centerY - radius * 0.1),
            Offset(centerX - radius * 0.7, centerY - radius * 0.2),
            glassesPaint);

        canvas.drawLine(
            Offset(centerX + radius * 0.55, centerY - radius * 0.1),
            Offset(centerX + radius * 0.7, centerY - radius * 0.2),
            glassesPaint);
        break;

      case 3: // 나비넥타이
        final bowtiePath = Path();

        // 왼쪽 날개
        bowtiePath.moveTo(centerX, centerY + radius * 0.4);
        bowtiePath.lineTo(centerX - radius * 0.3, centerY + radius * 0.3);
        bowtiePath.lineTo(centerX - radius * 0.3, centerY + radius * 0.5);
        bowtiePath.close();

        // 오른쪽 날개
        bowtiePath.moveTo(centerX, centerY + radius * 0.4);
        bowtiePath.lineTo(centerX + radius * 0.3, centerY + radius * 0.3);
        bowtiePath.lineTo(centerX + radius * 0.3, centerY + radius * 0.5);
        bowtiePath.close();

        // 중앙 부분
        bowtiePath.addOval(
          Rect.fromCenter(
              center: Offset(centerX, centerY + radius * 0.4),
              width: radius * 0.15,
              height: radius * 0.15),
        );

        canvas.drawPath(bowtiePath, accentPaint);
        break;

      case 4: // 스카프
        final scarfPath = Path();
        scarfPath.moveTo(centerX - radius * 0.6, centerY + radius * 0.2);
        scarfPath.quadraticBezierTo(centerX, centerY + radius * 0.6,
            centerX + radius * 0.6, centerY + radius * 0.2);
        scarfPath.lineTo(centerX + radius * 0.6, centerY + radius * 0.4);
        scarfPath.quadraticBezierTo(centerX, centerY + radius * 0.8,
            centerX - radius * 0.6, centerY + radius * 0.4);
        scarfPath.close();

        canvas.drawPath(scarfPath, accentPaint);

        // 무늬 추가
        final patternPaint = Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.03;

        for (var i = 0; i < 3; i++) {
          canvas.drawLine(
              Offset(
                  centerX - radius * 0.5, centerY + radius * (0.25 + i * 0.1)),
              Offset(
                  centerX + radius * 0.5, centerY + radius * (0.25 + i * 0.1)),
              patternPaint);
        }
        break;

      case 5: // 왕관
        final crownPaint = Paint()..color = Color(0xFFFFD700); // 금색

        final crownPath = Path();
        crownPath.moveTo(centerX - radius * 0.4, centerY - radius * 0.5);
        crownPath.lineTo(centerX - radius * 0.5, centerY - radius * 0.7);
        crownPath.lineTo(centerX - radius * 0.3, centerY - radius * 0.6);
        crownPath.lineTo(centerX, centerY - radius * 0.9);
        crownPath.lineTo(centerX + radius * 0.3, centerY - radius * 0.6);
        crownPath.lineTo(centerX + radius * 0.5, centerY - radius * 0.7);
        crownPath.lineTo(centerX + radius * 0.4, centerY - radius * 0.5);
        crownPath.close();

        canvas.drawPath(crownPath, crownPaint);

        // 보석 추가
        final jewelPaint = Paint()..color = accentColor;
        canvas.drawCircle(Offset(centerX, centerY - radius * 0.65),
            radius * 0.08, jewelPaint);

        canvas.drawCircle(
            Offset(centerX - radius * 0.3, centerY - radius * 0.6),
            radius * 0.05,
            Paint()..color = Colors.red);

        canvas.drawCircle(
            Offset(centerX + radius * 0.3, centerY - radius * 0.6),
            radius * 0.05,
            Paint()..color = Colors.blue);
        break;
    }
  }

// 하트 그리기 (눈 표현용)
  void _drawHeart(
      Canvas canvas, double centerX, double centerY, double size, Paint paint) {
    final heartPath = Path();

    // 왼쪽 곡선
    heartPath.moveTo(centerX, centerY + size * 0.3);
    heartPath.cubicTo(centerX - size * 0.85, centerY - size * 0.45,
        centerX - size, centerY, centerX, centerY + size * 0.8);

    // 오른쪽 곡선
    heartPath.cubicTo(centerX + size, centerY, centerX + size * 0.85,
        centerY - size * 0.45, centerX, centerY + size * 0.3);

    canvas.drawPath(heartPath, paint);
  }

// 이름 표시
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
  bool shouldRepaint(_AnimalCharacterPainter oldDelegate) => true;
}
