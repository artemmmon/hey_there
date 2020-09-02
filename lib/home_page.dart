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
  // Config
  static const Duration _animationDuration = Duration(milliseconds: 600);

  static const double _cardTransformLimit = .6;
  static const double _cardShadowLimit = 24;

  static const String _text = 'Hey there!';
  static const double _fontSize = 82;
  static const double _textTransformLimitX = 70;
  static const double _textTransformLimitY = 45;
  static const double _textShadowLimit = 4;

  // Props
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

    final double percentageX = (_localX / (size.width * 0.5) / 2) * 100;
    final double percentageY = (_localY / (size.height * 0.5) / 2) * 100;

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
          onTapUp: (details) => _ripple(details.globalPosition),
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
    final fancyX = (percentageX / 50);
    final fancyY = (percentageY / 50);
    // Card
    final cardX = limit(value: _defaultPosition ? 0 : (1.2 * fancyY + -1.2), threshold: _cardTransformLimit);
    final cardY = limit(value: _defaultPosition ? 0 : (-0.3 * fancyX + 0.3), threshold: _cardTransformLimit);

    // Text
    final textX = limit(value: _defaultPosition ? 0 : (70 * fancyX + -70), threshold: _textTransformLimitX);
    final textY = limit(value: _defaultPosition ? 0 : (80 * fancyY + -80), threshold: _textTransformLimitY);
    final textShadowX = -((textX * _textShadowLimit) / _textTransformLimitX);
    final textShadowY = -((textY * _textShadowLimit) / _textTransformLimitY);

    // Card shadow
    final cardShadowX = limit(value: -(textX), threshold: _cardShadowLimit);
    final cardShadowY = limit(value: -(textY), threshold: _cardShadowLimit);

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
      _text,
      style: GoogleFonts.londrinaSolid(
        fontSize: _fontSize,
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
      duration: _animationDuration,
    );

    _rippleAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() => _fraction = _rippleAnimation.value);
      });
  }

  /// Starts color change ripple animation with given [offset]
  void _ripple(Offset offset) {
    final newColor = Color((_random.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

    setState(() {
      _rippleOffset = offset;
      _prevColor = _color;
      _color = newColor;
    });

    _rippleController.reset();
    _rippleController.forward();
  }

  /*--------------------------- [Utils] ---------------------------*/

  num limit({num value, num threshold}) => value.clamp(-threshold, threshold);
}
