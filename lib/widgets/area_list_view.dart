import 'package:fitness_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/training/exercise_list_screen.dart';

class AreaListView extends StatefulWidget {
  final AnimationController mainScreenAnimationController;
  final Animation<double> mainScreenAnimation;
  
  const AreaListView({
    Key? key,
    required this.mainScreenAnimationController,
    required this.mainScreenAnimation,
  }) : super(key: key);

  @override
  _AreaListViewState createState() => _AreaListViewState();
}

class _AreaListViewState extends State<AreaListView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  
  // Full Detailed Muscle Data
  final List<Map<String, String>> _areaListData = [
    {
      'image': 'images/abs.png',
      'title': 'Abs',
      'count': '12 Exercises',
    },
    {
      'image': 'images/quads.png',
      'title': 'Quadriceps',
      'count': '15 Exercises',
    },
    {
      'image': 'images/chest.png',
      'title': 'Chest',
      'count': '10 Exercises',
    },
    {
      'image': 'images/back.png',
      'title': 'Back',
      'count': '14 Exercises',
    },
    {
      'image': 'images/biceps.png',
      'title': 'Biceps',
      'count': '10 Exercises',
    },
    {
      'image': 'images/triceps.png',
      'title': 'Triceps',
      'count': '8 Exercises',
    },
    {
      'image': 'images/shoulders.png',
      'title': 'Shoulders',
      'count': '8 Exercises',
    },
    {
      'image': 'images/glutes.png',
      'title': 'Glutes',
      'count': '10 Exercises',
    },
    {
      'image': 'images/calves.png',
      'title': 'Calves',
      'count': '6 Exercises',
    },
    {
      'image': 'images/forearms.png',
      'title': 'Forearms',
      'count': '5 Exercises',
    },
    {
      'image': 'images/traps.png',
      'title': 'Traps',
      'count': '7 Exercises',
    },
    {
      'image': 'images/lower_back.png',
      'title': 'Lower Back',
      'count': '8 Exercises',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation,
          child: Transform.translate(
            offset: Offset(
              0.0, 
              30 * (1.0 - widget.mainScreenAnimation.value),
            ),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _areaListData.length,
                  itemBuilder: (context, index) {
                    final animation = Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          (1 / _areaListData.length) * index,
                          1.0,
                          curve: Curves.fastOutSlowIn,
                        ),
                      ),
                    );
                    return AreaView(
                      animationController: _animationController,
                      animation: animation,
                      imagePath: _areaListData[index]['image']!,
                      title: _areaListData[index]['title']!,
                      count: _areaListData[index]['count']!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseListScreen(
                              muscleName: _areaListData[index]['title']!,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AreaView extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> animation;
  final String imagePath;
  final String title;
  final String count;
  final VoidCallback onTap;

  const AreaView({
    Key? key,
    required this.animationController,
    required this.animation,
    required this.imagePath,
    required this.title,
    required this.count,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(0.0, 50 * (1 - animation.value)),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.nearlyDarkBlue.withOpacity(0.1),
                    offset: const Offset(4, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  splashColor: AppTheme.nearlyDarkBlue.withOpacity(0.1),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.fitness_center, size: 40, color: AppTheme.nearlyDarkBlue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          count,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: AppTheme.gray.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
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
