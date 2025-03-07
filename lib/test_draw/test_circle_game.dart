import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class ShapeMatchingGame extends StatefulWidget {
  @override
  _ShapeMatchingGameState createState() => _ShapeMatchingGameState();
}

class _ShapeMatchingGameState extends State<ShapeMatchingGame> {
  List<Offset> userDrawnPoints = []; // 사용자가 그린 도형 좌표
  List<Offset> guideShapePoints = []; // 가이드라인 도형 좌표
  Timer? _timer; // 3초 타이머
  bool isDrawing = false; // 사용자가 그리는 중인지 확인
  int timeLeft = 3; // 남은 시간 표시

  @override
  void initState() {
    super.initState();
    generateGuideShape(); // 가이드라인 도형 생성
  }

  // 가이드라인 도형 (여기서는 원)
  void generateGuideShape() {
    guideShapePoints.clear();
    double size = 200; // 정사각형의 한 변 길이
    Offset center = Offset(200, 300); // 중심점
    double half = size / 2;

    // 네모의 꼭짓점 및 변을 따라 점 추가
    List<Offset> corners = [
      Offset(center.dx - half, center.dy - half), // 좌상단
      Offset(center.dx + half, center.dy - half), // 우상단
      Offset(center.dx + half, center.dy + half), // 우하단
      Offset(center.dx - half, center.dy + half), // 좌하단
      Offset(center.dx - half, center.dy - half), // 시작점으로 되돌아가기
    ];

    // 선을 따라 점을 생성
    for (int i = 0; i < corners.length - 1; i++) {
      Offset start = corners[i];
      Offset end = corners[i + 1];

      int steps = 20; // 한 변당 점 개수
      for (int j = 0; j <= steps; j++) {
        double t = j / steps;
        double x = start.dx + (end.dx - start.dx) * t;
        double y = start.dy + (end.dy - start.dy) * t;
        guideShapePoints.add(Offset(x, y));
      }
    }

    /// circle

    // guideShapePoints.clear();
    // double radius = 100;
    //
    // for (double angle = 0; angle < 2 * pi; angle += 0.1) {
    //   double x = center.dx + radius * cos(angle);
    //   double y = center.dy + radius * sin(angle);
    //   guideShapePoints.add(Offset(x, y));
    // }
  }

  // 3초 타이머 시작
  void startTimer() {
    if (_timer != null) _timer!.cancel(); // 기존 타이머 정지
    timeLeft = 3;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
      });

      if (timeLeft == 0) {
        timer.cancel();
        endDrawing(); // 3초 후 점수 계산
      }
    });
  }

  // 점수 계산 (사용자 도형과 가이드라인 도형 비교)
  double calculateScore() {
    if (userDrawnPoints.isEmpty) return 0;

    double totalDistance = 0;
    int guideCount = guideShapePoints.length;
    int userCount = userDrawnPoints.length;

    for (int i = 0; i < guideCount; i++) {
      Offset guidePoint = guideShapePoints[i];

      // 사용자가 그린 점 중 가장 가까운 점 찾기
      double minDistance = double.infinity;
      for (int j = 0; j < userCount; j++) {
        double distance = (userDrawnPoints[j] - guidePoint).distance;
        if (distance < minDistance) {
          minDistance = distance;
        }
      }
      totalDistance += minDistance; // 가장 가까운 점까지의 거리 누적
    }

    double avgDistance = totalDistance / guideCount;
    double maxError = 50.0; // 허용 오차
    double score = max(0, 100 - (avgDistance / maxError) * 100);

    return score;
  }

  // 3초 후 자동 종료
  void endDrawing() {
    double score = calculateScore();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Time's Up!"),
        content: Text("Your Score: ${score.toStringAsFixed(2)}"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                userDrawnPoints.clear();
                isDrawing = false;
              });
              Navigator.pop(context);
            },
            child: Text("Try Again"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shape Matching Game")),
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (details) {
              if (!isDrawing) {
                setState(() {
                  isDrawing = true;
                  userDrawnPoints.clear();
                });
                startTimer(); // 3초 타이머 시작
              }
            },
            onPanUpdate: (details) {
              if (isDrawing) {
                setState(() {
                  userDrawnPoints.add(details.localPosition);
                });
              }
            },
            child: CustomPaint(
              painter: ShapePainter(userDrawnPoints, guideShapePoints),
              child: Container(),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              "Time Left: $timeLeft sec",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// 도형을 그림
class ShapePainter extends CustomPainter {
  final List<Offset> userPoints;
  final List<Offset> guidePoints;

  ShapePainter(this.userPoints, this.guidePoints);

  @override
  void paint(Canvas canvas, Size size) {
    Paint guidePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10; // 가이드라인 두께 10

    Paint userPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3;

    // 가이드라인 도형 그리기
    for (int i = 0; i < guidePoints.length - 1; i++) {
      canvas.drawLine(guidePoints[i], guidePoints[i + 1], guidePaint);
    }

    // 사용자가 그린 도형 그리기
    for (int i = 0; i < userPoints.length - 1; i++) {
      canvas.drawLine(userPoints[i], userPoints[i + 1], userPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
