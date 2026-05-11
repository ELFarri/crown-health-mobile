import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/exercise_model.dart';
import '../services/exercise_service.dart';
import 'workout_session_screen.dart';

class ExerciseBrowserScreen extends StatefulWidget {
  final List<Exercise> currentWorkout;

  const ExerciseBrowserScreen({Key? key, required this.currentWorkout}) : super(key: key);

  @override
  _ExerciseBrowserScreenState createState() => _ExerciseBrowserScreenState();
}

class _ExerciseBrowserScreenState extends State<ExerciseBrowserScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedMuscle = 'All';
  late List<Exercise> _selectedExercises;

  @override
  void initState() {
    super.initState();
    _selectedExercises = List.from(widget.currentWorkout);
  }

  List<String> get _muscles => ['All', ...ExerciseService.exerciseData.keys.toList()];

  List<Exercise> get _filteredExercises {
    List<Exercise> all = [];
    if (_selectedMuscle == 'All') {
      ExerciseService.exerciseData.values.forEach((list) => all.addAll(list));
    } else {
      all = ExerciseService.exerciseData[_selectedMuscle] ?? [];
    }
    if (_searchQuery.isNotEmpty) {
      all = all.where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return all;
  }

  bool _isSelected(Exercise exercise) {
    return _selectedExercises.any((e) => e.name == exercise.name);
  }

  void _toggleExercise(Exercise exercise) {
    setState(() {
      if (_isSelected(exercise)) {
        _selectedExercises.removeWhere((e) => e.name == exercise.name);
      } else {
        _selectedExercises.add(Exercise(
          name: exercise.name,
          imagePath: exercise.imagePath,
          targetMuscle: exercise.targetMuscle,
          equipment: exercise.equipment,
          sets: [WorkoutSet(reps: 10, weight: 0)],
        ));
      }
    });
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
        title: Text('Exercise Library', style: GoogleFonts.outfit(color: AppTheme.darkText, fontWeight: FontWeight.bold)),
        actions: [
          if (_selectedExercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: () => Navigator.pop(context, _selectedExercises),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.nearlyDarkBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'Start (${_selectedExercises.length})',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                hintStyle: GoogleFonts.outfit(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: AppTheme.nearlyDarkBlue),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              style: GoogleFonts.outfit(),
            ),
          ),

          // Muscle Filter Chips
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _muscles.length,
              itemBuilder: (context, index) {
                final muscle = _muscles[index];
                final isActive = _selectedMuscle == muscle;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMuscle = muscle),
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.nearlyDarkBlue : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                    ),
                    child: Text(
                      muscle,
                      style: GoogleFonts.outfit(
                        color: isActive ? Colors.white : AppTheme.darkText,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Exercise Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${_filteredExercises.length} exercises',
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                ),
                Spacer(),
                if (_selectedExercises.isNotEmpty)
                  Text(
                    '${_selectedExercises.length} selected',
                    style: GoogleFonts.outfit(color: AppTheme.nearlyDarkBlue, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
              ],
            ),
          ),

          // Exercise List
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center(child: Text('No exercises found', style: GoogleFonts.outfit(color: Colors.grey)))
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 120),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      return _buildExerciseTile(_filteredExercises[index]);
                    },
                  ),
          ),
        ],
      ),
      // Bottom Confirm Button
      bottomNavigationBar: _selectedExercises.isNotEmpty
          ? Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 30),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _selectedExercises),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.nearlyDarkBlue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Start Workout (${_selectedExercises.length} exercises)',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildExerciseTile(Exercise exercise) {
    final selected = _isSelected(exercise);
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: selected ? AppTheme.nearlyDarkBlue.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? AppTheme.nearlyDarkBlue : Colors.transparent, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            exercise.imagePath,
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => Icon(Icons.fitness_center, color: AppTheme.nearlyDarkBlue, size: 28),
          ),
        ),
        title: Text(exercise.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        subtitle: Text(
          '${exercise.targetMuscle} • ${exercise.equipment}',
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
        ),
        trailing: GestureDetector(
          onTap: () => _toggleExercise(exercise),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: selected ? AppTheme.nearlyDarkBlue : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.nearlyDarkBlue, width: 2),
            ),
            child: Icon(
              selected ? Icons.check : Icons.add,
              color: selected ? Colors.white : AppTheme.nearlyDarkBlue,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
