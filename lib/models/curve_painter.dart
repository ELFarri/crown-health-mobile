import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app_theme.dart';

class CurvePainter extends CustomPainter {
  final double angle;
  final List<Color> colors;

  CurvePainter({this.angle = 140, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colorsList = [];
    if (colors.isNotEmpty) {
      colorsList.addAll(colors);
    } else {
      colorsList.addAll([AppTheme.nearlyDarkBlue, AppTheme.nearlyDarkBlue]);
    }

    final shdowPaint = new Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    shdowPaint.shader = LinearGradient(
      colors: colorsList,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final shdowPaintCenter = Offset(size.width / 2, size.height / 2);
    final shdowPaintSize = math.pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: shdowPaintCenter, radius: 54),
      degreeToRadians(278),
      degreeToRadians(360 - (365 - angle)),
      false,
      shdowPaint,
    );

    final paint = new Paint()
      ..color = AppTheme.white
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    paint.shader = LinearGradient(
      colors: colorsList,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final paintCenter = Offset(size.width / 2, size.height / 2);
    final paintSize = math.pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: paintCenter, radius: 52),
      degreeToRadians(278),
      degreeToRadians(360 - (365 - angle)),
      false,
      paint,
    );

    final paint2 = new Paint()
      ..color = AppTheme.white
      ..strokeWidth = 10 / 2;
    paint2.shader = LinearGradient(
      colors: colorsList,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint2Center = Offset(size.width / 2, size.height / 2);
    final paint2Size = math.pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: paint2Center, radius: 50),
      degreeToRadians(278),
      degreeToRadians(360 - (365 - angle)),
      false,
      paint2,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadians(double degree) {
    var redian = (math.pi / 180) * degree;
    return redian;
  }
}
