import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/app_theme.dart';

class RunningView extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> animation;

  const RunningView({
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main Card
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          // Text Content
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(100, 0, 16, 0),
                                  child: Text(
                                    'You are doing great!',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.nearlyDarkBlue,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(100, 4, 16, 12),
                                  child: Text(
                                    'Keep up the good work and\nstick to your fitness plan!',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: AppTheme.gray.withOpacity(0.9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Runner Image or Icon
                  Positioned(
                    top: -10,
                    left: 10,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.nearlyDarkBlue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(Icons.directions_run, color: Colors.white, size: 40),
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
