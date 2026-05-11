import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/exercise_model.dart';
import '../services/exercise_service.dart';

class AddExerciseScreen extends StatefulWidget {
  final String? initialMuscle;
  const AddExerciseScreen({Key? key, this.initialMuscle}) : super(key: key);

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _nameController = TextEditingController();
  final _equipmentController = TextEditingController();
  late String _selectedMuscle;
  
  final List<String> _muscles = [
    'Chest', 'Quadriceps', 'Biceps', 'Triceps', 'Back', 'Shoulders', 
    'Glutes', 'Abs', 'Traps', 'Lower Back', 'Calves', 'Forearms'
  ];

  @override
  void initState() {
    super.initState();
    _selectedMuscle = widget.initialMuscle ?? _muscles.first;
  }

  void _saveExercise() {
    if (_nameController.text.isEmpty) return;

    final newExercise = Exercise(
      name: _nameController.text,
      imagePath: 'images/fitness_center.png', // Default icon
      targetMuscle: _selectedMuscle,
      equipment: _equipmentController.text.isEmpty ? 'None' : _equipmentController.text,
      sets: [WorkoutSet(reps: 10, weight: 0)],
    );

    ExerciseService.addExercise(newExercise, _selectedMuscle);
    
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newExercise.name} added to $_selectedMuscle!', style: GoogleFonts.outfit()),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
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
        title: Text(
          'Add New Exercise',
          style: GoogleFonts.outfit(color: AppTheme.darkText, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Exercise Name'),
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration('e.g. Bicep Curl'),
                    style: GoogleFonts.outfit(),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Target Muscle'),
                  DropdownButtonFormField<String>(
                    value: _selectedMuscle,
                    decoration: _inputDecoration(''),
                    items: _muscles.map((m) => DropdownMenuItem(value: m, child: Text(m, style: GoogleFonts.outfit()))).toList(),
                    onChanged: (val) => setState(() => _selectedMuscle = val!),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Equipment'),
                  TextField(
                    controller: _equipmentController,
                    decoration: _inputDecoration('e.g. Dumbbell, Barbell, Machine'),
                    style: GoogleFonts.outfit(),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.nearlyDarkBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 5,
                    ),
                    child: Text('Create Exercise', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.grey[700])),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppTheme.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
