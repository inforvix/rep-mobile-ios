import 'package:flutter/material.dart';

class FaceCircleMask extends StatelessWidget {
  const FaceCircleMask({
    super.key,
    required this.width,
    required this.height,
    required this.circleRadius,
  });

  final double width;
  final double height;
  final double circleRadius;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size(width, height),
        painter: _FaceCircleMaskPainter(
            circleRadius: circleRadius, overlayColor: Colors.black),
      ),
    );
  }
}

class _FaceCircleMaskPainter extends CustomPainter {
  final double circleRadius;
  final Color overlayColor;

  _FaceCircleMaskPainter({
    required this.circleRadius,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final ovalRect = Rect.fromCenter(
      center: center,
      width: circleRadius * 2,
      height: circleRadius * 3,
    );

    final overlayPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(ovalRect);

    final overlayPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, overlayPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawOval(ovalRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
