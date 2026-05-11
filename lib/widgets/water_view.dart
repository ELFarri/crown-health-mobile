import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

class WaterView extends StatefulWidget {
  final AnimationController animationController;
  final Animation<double> animation;

  const WaterView({Key? key, required this.animationController, required this.animation}) : super(key: key);

  @override
  _WaterViewState createState() => _WaterViewState();
}

class _WaterViewState extends State<WaterView> {
  int _glasses = 0;
  final int _goal = 8;

  void _addGlass() {
    if (_glasses < _goal) {
      setState(() {
        _glasses++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: widget.animation,
          child: Transform(
            transform: Matrix4.translationValues(0.0, 30 * (1.0 - widget.animation.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(68.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.grey.withOpacity(0.2),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Water Animation/Icon
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.nearlyDarkBlue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Icon(Icons.local_drink, color: AppTheme.nearlyDarkBlue, size: 30),
                          CircularProgressIndicator(
                            value: _glasses / _goal,
                            strokeWidth: 4,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.nearlyDarkBlue),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Water Intake',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.darkText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Goal: $_goal glasses',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: AppTheme.grey.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(_goal, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Icon(
                                    Icons.opacity,
                                    size: 14,
                                    color: index < _glasses 
                                        ? AppTheme.nearlyDarkBlue 
                                        : AppTheme.grey.withOpacity(0.2),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      // Add Button
                      GestureDetector(
                        onTap: _addGlass,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.nearlyDarkBlue.withOpacity(0.3),
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
