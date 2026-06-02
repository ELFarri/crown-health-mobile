import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/app_theme.dart';
import '../models/curve_painter.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';

class MediterraneanDietView extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> animation;
  final int? eatenCalories;
  final int? burnedCalories;
  final int targetCalories;

  const MediterraneanDietView({
    Key? key,
    required this.animationController,
    required this.animation,
    this.eatenCalories,
    this.burnedCalories,
    required this.targetCalories,
  }) : super(key: key);

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();
    final double caloriesProgress = targetCalories > 0 ? (eatenCalories ?? 0) / targetCalories : 0.0;
    final double clampedProgress = caloriesProgress.clamp(0.0, 1.0);
    
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(0, 30 * (1.0 - animation.value)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                    topRight: Radius.circular(68),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gray.withOpacity(0.2),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Stats Row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                              child: Column(
                                children: [
                                  _buildStatRow(
                                    'images/eaten.png',
                                    'Eaten',
                                    eatenCalories ?? 0,
                                    hexToColor('#87A0E5'),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildStatRow(
                                    'images/burned.png',
                                    'Burned',
                                    burnedCalories ?? 0,
                                    hexToColor('#F56E98'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Progress Circle
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: AppTheme.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 4,
                                        color: AppTheme.nearlyDarkBlue.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${(targetCalories - (eatenCalories ?? 0) + (burnedCalories ?? 0)).clamp(0, targetCalories)}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.nearlyDarkBlue,
                                          ),
                                        ),
                                        Text(
                                          'kcal left',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: AppTheme.gray.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: CustomPaint(
                                    painter: CurvePainter(
                                      colors: [
                                        AppTheme.nearlyDarkBlue,
                                        hexToColor("#8A98E8"),
                                        hexToColor("#8A98E8"),
                                      ],
                                      angle: 5 + 360 * (clampedProgress * animation.value),
                                    ),
                                    child: const SizedBox(width: 108, height: 108),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Divider
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    
                    // Macros Row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Row(
                        children: [
                          _buildMacro('Carbs', '${mealProvider.totalCarbs.toInt()}g', hexToColor('#87A0E5'), animation.value),
                          _buildMacro('Protein', '${mealProvider.totalProtein.toInt()}g', hexToColor('#F56E98'), animation.value),
                          _buildMacro('Fat', '${mealProvider.totalFat.toInt()}g', hexToColor('#F1B440'), animation.value),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String imagePath, String label, int value, Color color) {
    return Row(
      children: [
        Container(
          height: 48,
          width: 2,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(
                  label,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppTheme.gray.withOpacity(0.5),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Image.asset(
                      imagePath,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.local_fire_department,
                        color: color,
                        size: 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      '$value',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppTheme.darkerText,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      'kcal',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppTheme.gray.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacro(String label, String value, Color color, double progress) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppTheme.darkText,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              height: 4,
              width: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Container(
                    height: 4,
                    width: (70 * progress).clamp(0.0, 70.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.1), color],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppTheme.gray.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}