class UserWorkoutModel {
  final int id;
  final int userId;
  final int workoutId;
  final String date; // تاريخ التمرين YYYY-MM-DD
  final int duration; // المدة الفعلية
  final double caloriesBurned; // السعرات المحروقة الفعلية
  final String notes; // ملاحظات المستخدم

  UserWorkoutModel({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.date,
    required this.duration,
    required this.caloriesBurned,
    required this.notes,
  });

  factory UserWorkoutModel.fromJson(Map<String, dynamic> json) {
    return UserWorkoutModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      workoutId: json['workout_id'] ?? 0,
      date: json['date'] ?? '',
      duration: json['duration'] ?? 0,
      caloriesBurned: double.tryParse(json['calories_burned'].toString()) ?? 0,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'workout_id': workoutId,
      'date': date,
      'duration': duration,
      'calories_burned': caloriesBurned,
      'notes': notes,
    };
  }
}
