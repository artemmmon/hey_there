import 'dart:math' as math;

import 'package:flutter/material.dart';

class RipplePainter extends CustomPainter {
  double _fraction = 0.0;
  Size _screenSize;
  Color _color;
  Offset _offset;
  Paint _paint;

  RipplePainter(this._fraction, this._screenSize, this._offset, this._color) {
    _paint = Paint()
      ..color = _color
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var finalRadius = math.sqrt(math.pow(_screenSize.width, 2) + math.pow(_screenSize.height, 2));
    var radius = finalRadius * _fraction;

    canvas.drawCircle(_offset, radius, _paint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate._fraction != _fraction;
  }
}
