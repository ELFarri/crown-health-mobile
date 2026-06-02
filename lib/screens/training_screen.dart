import 'package:flutter/material.dart';
import 'workout_session_screen.dart';
import 'workout_history_screen.dart';
import '../app_theme.dart';
import '../widgets/area_list_view.dart';
import '../widgets/running_view.dart';
import '../widgets/title_view.dart';
import '../widgets/workout_view.dart';

class TrainingScreen extends StatefulWidget {
  final AnimationController animationController;
  const TrainingScreen({required this.animationController});
  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> with TickerProviderStateMixin {
  List<Widget> _listviews = [];

  @override
  void initState() {
    super.initState();
    _addAllListData();
  }

  void _addAllListData() {
    const int count = 5;
    _listviews.add(TitleView(
      titleText: 'Your program',
      subText: 'Details',
      animationController: widget.animationController,
      animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: widget.animationController, curve: Interval((1/count)*0, 1.0, curve: Curves.fastOutSlowIn))),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutHistoryScreen())),
    ));
    _listviews.add(WorkoutView(animationController: widget.animationController, animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: widget.animationController, curve: Interval((1/count)*2, 1.0, curve: Curves.fastOutSlowIn))), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutSessionScreen(exercises: [])))));
    _listviews.add(RunningView(animationController: widget.animationController, animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: widget.animationController, curve: Interval((1/count)*3, 1.0, curve: Curves.fastOutSlowIn)))));
    _listviews.add(TitleView(
      titleText: 'Area of focus',
      subText: 'more',
      animationController: widget.animationController,
      animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: widget.animationController, curve: Interval((1/count)*4, 1.0, curve: Curves.fastOutSlowIn))),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutHistoryScreen())),
    ));
    _listviews.add(AreaListView(mainScreenAnimationController: widget.animationController, mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: widget.animationController, curve: Interval((1/count)*5, 1.0, curve: Curves.fastOutSlowIn)))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: ListView.builder(
        itemCount: _listviews.length,
        padding: const EdgeInsets.only(top: 10, bottom: 100),
        itemBuilder: (context, index) {
          widget.animationController.forward();
          return _listviews[index];
        },
      ),
    );
  }
}
