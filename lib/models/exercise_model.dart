class Exercise {
  final String name;
  final String imagePath;
  final String targetMuscle;
  final String equipment;
  final List<WorkoutSet> sets;

  Exercise({
    required this.name,
    required this.imagePath,
    required this.targetMuscle,
    required this.equipment,
    this.sets = const [],
  });
}

class WorkoutSet {
  int reps;
  double weight;
  bool isCompleted;

  WorkoutSet({
    this.reps = 0,
    this.weight = 0.0,
    this.isCompleted = false,
  });
}
