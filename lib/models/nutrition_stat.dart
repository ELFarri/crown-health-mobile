class NutritionStat {
  final String date;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  NutritionStat({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  factory NutritionStat.fromJson(Map<String, dynamic> json) {
    return NutritionStat(
      date: json['date'] as String,
      totalCalories: json['total_calories'] ?? 0,
      totalProtein: (json['total_protein'] ?? 0).toDouble(),
      totalCarbs: (json['total_carbs'] ?? 0).toDouble(),
      totalFat: (json['total_fat'] ?? 0).toDouble(),
    );
  }
}
