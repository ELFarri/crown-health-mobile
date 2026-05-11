import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../../models/exercise_model.dart';
import '../../services/exercise_service.dart';
import '../add_exercise_screen.dart';

class ExerciseListScreen extends StatefulWidget {
  final String muscleName;

  const ExerciseListScreen({Key? key, required this.muscleName}) : super(key: key);

  @override
  _ExerciseListScreenState createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  late List<Exercise> _exercises;
  Timer? _restTimer;
  int _restSeconds = 60;
  bool _showTimer = false;

  @override
  void initState() {
    super.initState();
    _initializeExercises();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _restSeconds = 60;
      _showTimer = true;
    });
    _restTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_restSeconds > 0) {
        setState(() {
          _restSeconds--;
        });
      } else {
        setState(() {
          _showTimer = false;
        });
        timer.cancel();
      }
    });
  }

  void _initializeExercises() {
    _exercises = ExerciseService.exerciseData[widget.muscleName] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.muscleName} Exercises',
          style: GoogleFonts.outfit(
            color: AppTheme.darkText,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppTheme.nearlyDarkBlue),
            tooltip: 'Add Exercise',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddExerciseScreen(
                    initialMuscle: widget.muscleName,
                  ),
                ),
              );
              if (result == true) {
                setState(() {
                  _initializeExercises();
                });
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      body: Stack(
        children: [
          _exercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.construction, size: 60, color: AppTheme.grey.withOpacity(0.3)),
                      SizedBox(height: 16),
                      Text(
                        'More exercises coming soon!',
                        style: GoogleFonts.outfit(
                          fontSize: 18, 
                          color: AppTheme.grey.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    return _buildExerciseCard(_exercises[index]);
                  },
                ),
          if (_showTimer) _buildTimerOverlay(),
        ],
      ),
    );
  }

  Widget _buildTimerOverlay() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.nearlyDarkBlue.withOpacity(0.3),
              offset: Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.timer, color: Colors.white),
            SizedBox(width: 16),
            Text(
              'REST TIME:',
              style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Text(
              '${_restSeconds}s',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white70),
              onPressed: () => setState(() => _showTimer = false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.nearlyDarkBlue.withOpacity(0.05),
            offset: Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    exercise.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.fitness_center, color: AppTheme.nearlyDarkBlue, size: 30),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      Text(
                        'Equipment: ${exercise.equipment}',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppTheme.grey.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_vert, color: AppTheme.grey.withOpacity(0.5)),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildHeaderLabel('SET')),
                    Expanded(child: _buildHeaderLabel('KG')),
                    Expanded(child: _buildHeaderLabel('REPS')),
                    SizedBox(width: 40),
                  ],
                ),
                Divider(color: AppTheme.background),
                ...exercise.sets.asMap().entries.map((entry) {
                  int idx = entry.key;
                  WorkoutSet set = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.1),
                            child: Text('${idx + 1}', style: TextStyle(fontSize: 12, color: AppTheme.nearlyDarkBlue, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Expanded(
                          child: _buildInputField(set.weight.toString(), (v) => set.weight = double.tryParse(v) ?? 0),
                        ),
                        Expanded(
                          child: _buildInputField(set.reps.toString(), (v) => set.reps = int.tryParse(v) ?? 0),
                        ),
                        Checkbox(
                          value: set.isCompleted,
                          activeColor: Colors.green,
                          onChanged: (v) {
                            setState(() {
                              set.isCompleted = v!;
                              if (set.isCompleted) {
                                _startRestTimer();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  exercise.sets.add(WorkoutSet(
                    reps: exercise.sets.isNotEmpty ? exercise.sets.last.reps : 10,
                    weight: exercise.sets.isNotEmpty ? exercise.sets.last.weight : 0,
                  ));
                });
              },
              icon: Icon(Icons.add, size: 18),
              label: Text('Add Set', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.nearlyDarkBlue,
                backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: Size(double.infinity, 45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderLabel(String label) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.grey.withOpacity(0.3),
      ),
    );
  }

  Widget _buildInputField(String value, Function(String) onChanged) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        initialValue: value == '0.0' || value == '0' ? '' : value,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(border: InputBorder.none, isDense: true, hintText: '-'),
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.nearlyDarkBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: Size(double.infinity, 56),
          elevation: 5,
          shadowColor: AppTheme.nearlyDarkBlue.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard_rounded, size: 20),
            SizedBox(width: 12),
            Text(
              'Back to Dashboard',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
