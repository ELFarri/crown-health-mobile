import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/app_theme.dart';

class GlassView extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> animation;

  const GlassView({
    Key? key,
    required this.animationController,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(0, 30 * (1.0 - animation.value)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Stack(
                children: [
                  // Glass Container
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7E0F9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(68, 16, 16, 16),
                        child: Text(
                          'Prepare your stomach for lunch by drinking two glasses of water',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: AppTheme.nearlyDarkBlue.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                  
                  // Glass Image/Icon
                  Positioned(
                    top: -5,
                    left: 0,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'images/glass.png',
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.local_drink, color: AppTheme.nearlyDarkBlue, size: 30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
