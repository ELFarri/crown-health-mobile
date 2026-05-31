import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/exercise_model.dart';
import 'exercise_browser_screen.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final List<Exercise> exercises;

  const WorkoutSessionScreen({Key? key, required this.exercises}) : super(key: key);

  @override
  _WorkoutSessionScreenState createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late List<Exercise> _exercises;
  Timer? _sessionTimer;
  Timer? _restTimer;
  int _sessionSeconds = 0;
  int _restSeconds = 0;
  bool _showRestTimer = false;

  @override
  void initState() {
    super.initState();
    _exercises = widget.exercises;
    _startSessionTimer();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() => _sessionSeconds++);
    });
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restSeconds = seconds;
      _showRestTimer = true;
    });
    _restTimer = Timer.periodic(Duration(seconds: 1), (t) {
      if (_restSeconds > 0) {
        setState(() => _restSeconds--);
      } else {
        setState(() => _showRestTimer = false);
        t.cancel();
      }
    });
  }

  String get _sessionDuration {
    final m = _sessionSeconds ~/ 60;
    final s = _sessionSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int get _completedSets =>
      _exercises.fold(0, (sum, e) => sum + e.sets.where((s) => s.isCompleted).length);
  int get _totalSets =>
      _exercises.fold(0, (sum, e) => sum + e.sets.length);

  void _finishWorkout() {
    _sessionTimer?.cancel();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Workout Complete! 🎉', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow(Icons.timer, 'Duration', _sessionDuration),
            SizedBox(height: 12),
            _buildSummaryRow(Icons.fitness_center, 'Exercises', '${_exercises.length}'),
            SizedBox(height: 12),
            _buildSummaryRow(Icons.check_circle, 'Sets done', '$_completedSets / $_totalSets'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Done', style: GoogleFonts.outfit(color: AppTheme.nearlyDarkBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.nearlyDarkBlue, size: 20),
        SizedBox(width: 12),
        Text(label, style: GoogleFonts.outfit(color: Colors.grey)),
        Spacer(),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active Workout', style: GoogleFonts.outfit(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(_sessionDuration, style: GoogleFonts.outfit(color: AppTheme.nearlyDarkBlue, fontSize: 13)),
          ],
        ),
        actions: [
          // Add more exercises
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppTheme.nearlyDarkBlue),
            tooltip: 'Add Exercise',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExerciseBrowserScreen(currentWorkout: _exercises),
                ),
              );
              if (result != null && result is List) {
                setState(() => _exercises = List<Exercise>.from(result));
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _finishWorkout,
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text('Finish', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Progress bar
              _buildProgressBar(),
              // Exercise list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 120),
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) => _buildExerciseCard(_exercises[index]),
                ),
              ),
            ],
          ),
          if (_showRestTimer) _buildRestTimerOverlay(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _totalSets == 0 ? 0.0 : _completedSets / _totalSets;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.darkText)),
              Text('$_completedSets / $_totalSets sets', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.background,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.nearlyDarkBlue),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(12)),
                  child: Image.asset(
                    exercise.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => Icon(Icons.fitness_center, color: AppTheme.nearlyDarkBlue, size: 28),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkText)),
                      Text('${exercise.targetMuscle} • ${exercise.equipment}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.background),
          // Sets
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _headerLabel('SET')),
                    Expanded(child: _headerLabel('KG')),
                    Expanded(child: _headerLabel('REPS')),
                    SizedBox(width: 40),
                  ],
                ),
                SizedBox(height: 4),
                ...exercise.sets.asMap().entries.map((entry) {
                  int i = entry.key;
                  WorkoutSet set = entry.value;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: CircleAvatar(
                            radius: 13,
                            backgroundColor: set.isCompleted ? Colors.green.withOpacity(0.15) : AppTheme.nearlyDarkBlue.withOpacity(0.1),
                            child: Text('${i + 1}', style: TextStyle(fontSize: 12, color: set.isCompleted ? Colors.green : AppTheme.nearlyDarkBlue, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Expanded(child: _inputField(set.weight.toString(), (v) => set.weight = double.tryParse(v) ?? 0)),
                        Expanded(child: _inputField(set.reps.toString(), (v) => set.reps = int.tryParse(v) ?? 0)),
                        Checkbox(
                          value: set.isCompleted,
                          activeColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (v) {
                            setState(() {
                              set.isCompleted = v!;
                              if (v) _startRestTimer(90);
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
          // Add Set button
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextButton.icon(
              onPressed: () => setState(() => exercise.sets.add(WorkoutSet(
                reps: exercise.sets.isNotEmpty ? exercise.sets.last.reps : 10,
                weight: exercise.sets.isNotEmpty ? exercise.sets.last.weight : 0,
              ))),
              icon: Icon(Icons.add, size: 16),
              label: Text('Add Set', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.nearlyDarkBlue,
                backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.06),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: Size(double.infinity, 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerLabel(String text) => Text(text, textAlign: TextAlign.center,
      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.6)));

  Widget _inputField(String value, Function(String) onChanged) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
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

  Widget _buildRestTimerOverlay() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppTheme.nearlyDarkBlue.withOpacity(0.3), offset: Offset(0, 10), blurRadius: 20)],
        ),
        child: Row(
          children: [
            Icon(Icons.timer, color: Colors.white),
            SizedBox(width: 12),
            Text('REST TIME', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold)),
            Spacer(),
            Text('${_restSeconds}s', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
            SizedBox(width: 12),
            IconButton(icon: Icon(Icons.close, color: Colors.white70), onPressed: () => setState(() => _showRestTimer = false)),
          ],
        ),
      ),
    );
  }
}
