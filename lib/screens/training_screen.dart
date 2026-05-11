import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../widgets/area_list_view.dart';
import '../widgets/running_view.dart';
import '../widgets/title_view.dart';
import '../widgets/workout_view.dart';
import '../services/exercise_service.dart';
import '../models/exercise_model.dart';
import 'training/exercise_list_screen.dart';
import 'add_exercise_screen.dart';
import 'exercise_browser_screen.dart';
import 'workout_session_screen.dart';

class TrainingScreen extends StatefulWidget {
  final AnimationController animationController;

  const TrainingScreen({required this.animationController});
  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with TickerProviderStateMixin {
  late Animation<double> _topBarAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: widget.animationController,
    curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn),
  ));
  List<Widget> _listviews = [];
  DateTime? _selectedDate;
  double _topBarOpacity = 0.0;
  final ScrollController _scrollController = ScrollController();
  
  bool _isSearching = false;
  List<Exercise> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _topBarAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn),
    ));
    _addAllListData();

    _scrollController.addListener(() {
      if (_scrollController.offset >= 24) {
        if (_topBarOpacity != 1.0) {
          setState(() {
            _topBarOpacity = 1.0;
          });
        }
      } else if (_scrollController.offset <= 24 &&
          _scrollController.offset >= 0) {
        if (_topBarOpacity != _scrollController.offset / 24) {
          setState(() {
            _topBarOpacity = _scrollController.offset / 24;
          });
        }
      } else if (_scrollController.offset <= 0) {
        if (_topBarOpacity != 0.0) {
          setState(() {
            _topBarOpacity = 0.0;
          });
        }
      }
    });
  }

  void _addAllListData() {
    const int count = 5;

    _listviews.add(
      TitleView(
        titleText: 'Your program',
        subText: 'Details',
        animationController: widget.animationController,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController,
            curve: Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
      ),
    );

    _listviews.add(
      WorkoutView(
        animationController: widget.animationController,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController,
            curve: Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
      ),
    );

    _listviews.add(
      RunningView(
        animationController: widget.animationController,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController,
            curve: Interval((1 / count) * 3, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
      ),
    );

    _listviews.add(
      TitleView(
        titleText: 'Area of focus',
        subText: 'more',
        animationController: widget.animationController,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: widget.animationController,
              curve: Interval((1 / count) * 4, 1.0, curve: Curves.fastOutSlowIn)),
        ),
      ),
    );

    _listviews.add(
      AreaListView(
        mainScreenAnimationController: widget.animationController,
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController,
            curve: Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchResults = ExerciseService.searchExercises(query);
    });
  }

  void _dataPicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  Future<bool> _getData() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Stack(
        children: [
          _isSearching ? _buildSearchResultsUI() : _getMainListViewUI(),
          _getAppBarUI(),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSearchResultsUI() {
    return Container(
      padding: EdgeInsets.only(top: AppBar().preferredSize.height + MediaQuery.of(context).padding.top + 20),
      child: _searchResults.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: AppTheme.grey.withOpacity(0.3)),
                  SizedBox(height: 16),
                  Text('No exercises found', style: GoogleFonts.outfit(color: AppTheme.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final exercise = _searchResults[index];
                return _buildSearchResultTile(exercise);
              },
            ),
    );
  }

  Widget _buildSearchResultTile(Exercise exercise) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(12)),
          child: Image.asset(exercise.imagePath, errorBuilder: (c, e, s) => Icon(Icons.fitness_center, color: AppTheme.nearlyDarkBlue)),
        ),
        title: Text(exercise.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        subtitle: Text('${exercise.targetMuscle} • ${exercise.equipment}', style: GoogleFonts.outfit(fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExerciseListScreen(muscleName: exercise.targetMuscle)),
          );
        },
      ),
    );
  }

  Widget _getMainListViewUI() {
    final _mediaQuery = MediaQuery.of(context);
    return FutureBuilder(
      future: _getData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();
        return ListView.builder(
          controller: _scrollController,
          itemCount: _listviews.length,
          padding: EdgeInsets.only(
            top: AppBar().preferredSize.height + _mediaQuery.padding.top + 24,
            bottom: _mediaQuery.padding.bottom + 100,
          ),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            widget.animationController.forward();
            return _listviews[index];
          },
        );
      },
    );
  }

  Widget _getAppBarUI() {
    return Column(
      children: [
        Container(
          height: AppBar().preferredSize.height + MediaQuery.of(context).padding.top,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            boxShadow: [BoxShadow(color: AppTheme.gray.withOpacity(0.2), offset: Offset(0, 2), blurRadius: 8)],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.menu, color: Colors.white),
                onPressed: () {
                  if (_isSearching) {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  } else {
                    Scaffold.of(context).openDrawer();
                  }
                },
              ),
            ),
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    autofocus: true,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      hintStyle: GoogleFonts.outfit(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  )
                : Text('Training', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
            actions: [
              if (!_isSearching)
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: Colors.white),
                  onPressed: () async {
                    final selectedExercises = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseBrowserScreen(currentWorkout: []),
                      ),
                    );
                    if (selectedExercises != null && selectedExercises is List && selectedExercises.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutSessionScreen(exercises: List<Exercise>.from(selectedExercises)),
                        ),
                      );
                    }
                  },
                ),
              if (!_isSearching)
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () => setState(() => _isSearching = true),
                ),
              if (!_isSearching)
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.white, size: 18),
                  onPressed: _dataPicker,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
