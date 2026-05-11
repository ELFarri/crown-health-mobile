import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'package:fitness_app/app_theme.dart';

class WaveView extends StatefulWidget {
  final double percentageValue;

  const WaveView({Key? key, this.percentageValue = 100.0}) : super(key: key);

  @override
  _WaveViewState createState() => _WaveViewState();
}

class _WaveViewState extends State<WaveView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _waveAnimationController;
  Offset bottleOffset1 = Offset.zero;
  List<Offset> animList1 = [];
  Offset bottleOffset2 = const Offset(60, 0);
  List<Offset> animList2 = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });

    _waveAnimationController.addListener(_updateWavePositions);
    
    _animationController.forward();
    _waveAnimationController.repeat();
  }

  void _updateWavePositions() {
    animList1.clear();
    for (int i = -2 - bottleOffset1.dx.toInt(); i <= 60 + 2; i++) {
      animList1.add(Offset(
        i.toDouble() + bottleOffset1.dx.toInt(),
        math.sin((_waveAnimationController.value * 360 - i) % 360 * vector.degrees2Radians) * 4 +
            ((100 - widget.percentageValue) * 160 / 100),
      ));
    }

    animList2.clear();
    for (int i = -2 - bottleOffset2.dx.toInt(); i <= 60 + 2; i++) {
      animList2.add(Offset(
        i.toDouble() + bottleOffset2.dx.toInt(),
        math.sin((_waveAnimationController.value * 360 - i) % 360 * vector.degrees2Radians) * 4 +
            ((100 - widget.percentageValue) * 160 / 100),
      ));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _waveAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      builder: (context, child) {
        return Stack(
          children: [
            // First Wave Layer
            ClipPath(
              clipper: WaveClipper(_animationController.value, animList1),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.nearlyDarkBlue.withOpacity(0.2),
                      AppTheme.nearlyDarkBlue.withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            
            // Second Wave Layer
            ClipPath(
              clipper: WaveClipper(_animationController.value, animList2),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.nearlyDarkBlue.withOpacity(0.4),
                      AppTheme.nearlyDarkBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            
            // Percentage Text
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.percentageValue.clamp(0, 100).round().toString(),
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w500,
                        fontSize: 24,
                        color: AppTheme.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        '%',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Decorative Dots
            Positioned(
              top: 0,
              left: 6,
              bottom: 8,
              child: ScaleTransition(
                scale: Tween(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
                  ),
                ),
                child: Container(
                  width: 2,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 0,
              bottom: 16,
              child: ScaleTransition(
                scale: Tween(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
                  ),
                ),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 24,
              bottom: 32,
              child: ScaleTransition(
                scale: Tween(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.6, 0.8, curve: Curves.fastOutSlowIn),
                  ),
                ),
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 20,
              bottom: 0,
              child: Transform.translate(
                offset: Offset(0, 16 * (1.0 - _animationController.value)),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            
            // Bottle Image
            Align(
              alignment: Alignment.bottomCenter,
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  'images/bottle.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.nearlyDarkBlue, AppTheme.nearlyDarkBlue],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.local_drink, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animation;
  final List<Offset> waveList;

  const WaveClipper(this.animation, this.waveList);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addPolygon(waveList, false);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) => animation != oldClipper.animation || 
      waveList != oldClipper.waveList;
}
