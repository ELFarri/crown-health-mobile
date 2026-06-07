import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/meal_provider.dart';
import '../services/api_service.dart';

class StatisticsView extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> animation;

  const StatisticsView({Key? key, required this.animationController, required this.animation}) : super(key: key);

  void _showDailyDetailSheet(BuildContext context, String day) {
    final mealProvider = Provider.of<MealProvider>(context, listen: false);

    String title = "";
    int targetWeekday = 1;
    switch (day) {
      case 'Mon': targetWeekday = 1; break;
      case 'Tue': targetWeekday = 2; break;
      case 'Wed': targetWeekday = 3; break;
      case 'Thu': targetWeekday = 4; break;
      case 'Fri': targetWeekday = 5; break;
      case 'Sat': targetWeekday = 6; break;
      case 'Sun': targetWeekday = 7; break;
    }

    final int todayWeekday = DateTime.now().weekday;
    String englishDay = "";
    switch (day) {
      case 'Mon': englishDay = "Monday"; break;
      case 'Tue': englishDay = "Tuesday"; break;
      case 'Wed': englishDay = "Wednesday"; break;
      case 'Thu': englishDay = "Thursday"; break;
      case 'Fri': englishDay = "Friday"; break;
      case 'Sat': englishDay = "Saturday"; break;
      case 'Sun': englishDay = "Sunday"; break;
    }
    title = "$englishDay - Daily Details";

    // Calculate exact target date and pass it directly to the API
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final difference = targetWeekday - currentWeekday;
    final targetDate = now.add(Duration(days: difference));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FutureBuilder<List<dynamic>>(
        // BUG FIX: pass targetDate directly to API — no more client-side date filtering
        future: Future.wait([
          ApiService.getUserWorkouts(date: targetDate),
          ApiService.getUserMeals(date: targetDate),
        ]),
        builder: (context, snapshot) {
          final isLoadingWorkouts = snapshot.connectionState == ConnectionState.waiting;
          final List<Map<String, dynamic>> workoutsList =
              snapshot.data != null ? List<Map<String, dynamic>>.from(snapshot.data![0] as List) : [];
          final apiMeals = snapshot.data != null ? snapshot.data![1] as List : [];

          // The backend now returns only workouts for targetDate, so take the first one
          Map<String, dynamic>? matchingWorkout = workoutsList.isNotEmpty ? workoutsList.first : null;

          String steps = "0";
          String distance = "0.0 km";
          String activeCal = "0 kcal";
          String workoutName = "No workout";
          String workoutDuration = "0 min";
          List<String> exercises = [];

          if (matchingWorkout != null) {
            workoutName = matchingWorkout['workout_name'] ?? 'Workout';
            workoutDuration = matchingWorkout['duration'] ?? '0 min';
            activeCal = "${matchingWorkout['calories_burned']} kcal";
            exercises = [matchingWorkout['muscle'] ?? 'General'];
          }

          String foodCalories = "0 kcal";
          double protein = 0.0;
          double carbs = 0.0;
          double fat = 0.0;
          List<Map<String, String>> meals = [];

          if (targetWeekday == todayWeekday && !isLoadingWorkouts && apiMeals.isEmpty) {
            // Use local provider for today if API returns nothing yet
            foodCalories = "${mealProvider.totalCalories} kcal";
            protein = mealProvider.totalProtein;
            carbs = mealProvider.totalCarbs;
            fat = mealProvider.totalFat;
            meals = mealProvider.todayMeals.map((item) => {
              "name": item.name,
              "cal": "${item.calories} kcal",
              "type": item.category,
            }).toList();
          } else if (!isLoadingWorkouts) {
            // use API data for any day (including today when synced)
            for (var m in apiMeals) {
              final meal = m as FoodItem;
              protein += meal.protein;
              carbs += meal.carbs;
              fat += meal.fat;
              meals.add({
                "name": meal.name,
                "cal": "${meal.calories} kcal",
                "type": meal.category.isNotEmpty ? meal.category : 'General',
              });
            }
            final totalCal = apiMeals.cast<FoodItem>().fold<int>(0, (s, m) => s + m.calories);
            foodCalories = "$totalCal kcal";
          }

          final totalMacros = protein + carbs + fat;
          final double protP = totalMacros > 0 ? (protein / totalMacros) : 0;
          final double carbP = totalMacros > 0 ? (carbs / totalMacros) : 0;
          final double fatP = totalMacros > 0 ? (fat / totalMacros) : 0;

          final bool hasWorkout = matchingWorkout != null;
          final bool hasMeals = meals.isNotEmpty;

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2.5)),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.darkText),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_rounded, color: Colors.grey, size: 28),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.black12),
                Expanded(
                  child: isLoadingWorkouts
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.nearlyDarkBlue))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildCardioIndicator(Icons.directions_walk_rounded, "Steps", steps, Colors.blue),
                                    _buildCardioIndicator(Icons.map_rounded, "Distance", distance, Colors.green),
                                    _buildCardioIndicator(Icons.local_fire_department_rounded, "Burned", activeCal, Colors.orange),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "Workout Session 🏋️‍♀️",
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.darkText),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  gradient: hasWorkout ? AppTheme.primaryGradient : null,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                                ),
                                child: hasWorkout 
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 24),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                workoutName,
                                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.timer_outlined, color: Colors.white70, size: 16),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Duration: $workoutDuration",
                                              style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.9), fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        const Divider(color: Colors.white30),
                                        const SizedBox(height: 8),
                                        ...exercises.map((ex) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 16),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  ex,
                                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )).toList(),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Icon(Icons.fitness_center_rounded, color: Colors.grey.withOpacity(0.6), size: 24),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            "No workout activity logged for this day",
                                            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "Nutrition & Meals 🍎",
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.darkText),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Total Consumed",
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 14),
                                        ),
                                        Text(
                                          foodCalories,
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.nearlyDarkBlue, fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (hasMeals) ...[
                                      Row(
                                        children: [
                                          Expanded(flex: (protP * 100).toInt().clamp(1, 100), child: Container(height: 6, decoration: const BoxDecoration(color: Color(0xFFFA7D82), borderRadius: BorderRadius.horizontal(left: Radius.circular(3))))),
                                          Expanded(flex: (carbP * 100).toInt().clamp(1, 100), child: Container(height: 6, color: const Color(0xFF738AE6))),
                                          Expanded(flex: (fatP * 100).toInt().clamp(1, 100), child: Container(height: 6, decoration: const BoxDecoration(color: Color(0xFFFE95B2), borderRadius: BorderRadius.horizontal(right: Radius.circular(3))))),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildMacroMiniLegend("Prot", "${protein.toInt()}g", const Color(0xFFFA7D82)),
                                          _buildMacroMiniLegend("Carbs", "${carbs.toInt()}g", const Color(0xFF738AE6)),
                                          _buildMacroMiniLegend("Fat", "${fat.toInt()}g", const Color(0xFFFE95B2)),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      const Divider(color: Colors.black12),
                                      const SizedBox(height: 8),
                                      ...meals.map((meal) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(color: AppTheme.nearlyDarkBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                                    child: Text(
                                                      meal["type"]!,
                                                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.nearlyDarkBlue),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      meal["name"]!,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.darkText, fontSize: 13),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              meal["cal"]!,
                                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      )).toList(),
                                    ] else
                                      Row(
                                        children: [
                                          Icon(Icons.restaurant_menu_rounded, color: Colors.grey.withOpacity(0.6), size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              "No meals logged for this day",
                                              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardioIndicator(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.darkText, fontSize: 14)),
      ],
    );
  }

  Widget _buildMacroMiniLegend(String label, String value, Color color) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text("$label: ", style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(0.0, 30 * (1.0 - animation.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.grey.withOpacity(0.1),
                      offset: const Offset(0, 10),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Weekly Activity',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppTheme.darkText,
                            ),
                          ),
                          Icon(Icons.bar_chart_rounded, color: AppTheme.nearlyDarkBlue),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 150,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBar(context, 'Mon', 0.4),
                            _buildBar(context, 'Tue', 0.7),
                            _buildBar(context, 'Wed', 0.5),
                            _buildBar(context, 'Thu', 0.9),
                            _buildBar(context, 'Fri', 0.6),
                            _buildBar(context, 'Sat', 0.3),
                            _buildBar(context, 'Sun', 0.8),
                          ],
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

  Widget _buildBar(BuildContext context, String day, double heightFactor) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showDailyDetailSheet(context, day),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 12,
            height: 120 * heightFactor,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.nearlyDarkBlue,
                  AppTheme.nearlyDarkBlue.withOpacity(0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            day,
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
