import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_test_task/ripple_painter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _random = math.Random();

  Color _color = Colors.blue;
  Color _prevColor = Colors.blue;

  Animation<double> _rippleAnimation;
  AnimationController _rippleController;
  double _fraction = 1.0;
  Offset _rippleOffset = Offset.zero;

  double _localX = 0;
  double _localY = 0;
  bool _defaultPosition = true;

  /*--------------------------- [Lifecycle] ---------------------------*/

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  @override
  void dispose() {
    super.dispose();
    _rippleController.dispose();
  }

  /*--------------------------- [UI] ---------------------------*/

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double percentageX = (_localX / (size.width * 0.45) / 2) * 100;
    final double percentageY = (_localY / ((size.height / 2) + 70) / 1.5) * 100;

    return Material(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _defaultPosition = false),
        onExit: (_) => setState(() {
          _localY = (size.height) / 2;
          _localX = (size.width * 0.45) / 2;
          _defaultPosition = true;
        }),
        onHover: (details) {
          if (mounted) setState(() => _defaultPosition = false);
          if (details.localPosition.dx > 0 && details.localPosition.dy > 0) {
            _localX = details.localPosition.dx;
            _localY = details.localPosition.dy;
          }
        },
        child: GestureDetector(
          onTapUp: (details) => ripple(details.globalPosition),
          child: DecoratedBox(
            decoration: BoxDecoration(color: _prevColor),
            child: CustomPaint(
              painter: RipplePainter(
                _fraction,
                size,
                _rippleOffset,
                _color,
              ),
              child: _buildContent(percentageX, percentageY),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(num percentageX, num percentageY) {
    // Card
    final cardLimit = .6;
    final cardX = _defaultPosition ? 0 : (1.2 * (percentageY / 50) + -1.2).clamp(-cardLimit, cardLimit);
    final cardY = _defaultPosition ? 0 : (-0.3 * (percentageX / 50) + 0.3).clamp(-cardLimit, cardLimit);

    // Text
    final textLimitX = 70;
    final textLimitY = 45;
    final textX = _defaultPosition ? 0.0 : (70 * (percentageX / 50) + -70).clamp(-textLimitX, textLimitX);
    final textY = _defaultPosition ? 0.0 : (80 * (percentageY / 50) + -80).clamp(-textLimitY, textLimitY);
    final textShadowLimit = 4;
    final textShadowX = -textX.clamp(-textShadowLimit, textShadowLimit);
    final textShadowY = -textY.clamp(-textShadowLimit, textShadowLimit);

    // Card shadow
    final cardShadowLimit = 24;
    final cardShadowX = -(textX).clamp(-cardShadowLimit, cardShadowLimit);
    final cardShadowY = -(textY).clamp(-cardShadowLimit, cardShadowLimit);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0001)
          ..rotateX(cardX)
          ..rotateY(cardY),
        alignment: FractionalOffset.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Color(0x60000000),
                blurRadius: 24,
                offset: Offset(cardShadowX, cardShadowY),
              )
            ],
          ),
          child: Transform(
            transform: Matrix4.identity()..translate(textX, textY, 0.0),
            alignment: FractionalOffset.center,
            child: _buildText(textShadowX, textShadowY),
          ),
        ),
      ),
    );
  }

  Widget _buildText(double shadowX, double shadowY) {
    return Text(
      'Hey there!',
      style: GoogleFonts.londrinaSolid(
        fontSize: 72,
        fontWeight: FontWeight.w900,
        shadows: [
          Shadow(
            color: _color,
            blurRadius: 2,
            offset: Offset(shadowX, shadowY),
          ),
        ],
        color: Colors.black.withOpacity(.8),
      ),
    );
  }

  /*--------------------------- [Animation] ---------------------------*/

  void _setupAnimation() {
    _rippleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _rippleAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeInOut),
    )..addListener(() {
      setState(() => _fraction = _rippleAnimation.value);
    });
  }

  void ripple(Offset offset) {
    final newColor = Color((_random.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    setState(() {
      _rippleOffset = offset;
      _prevColor = _color;
      _color = newColor;
    });
    _rippleController.reset();
    _rippleController.forward();
  }
}