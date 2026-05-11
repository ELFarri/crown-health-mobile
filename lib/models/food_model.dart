class FoodModel {
  final int id;
  final String name;
  final String category;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodModel({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      calories: double.tryParse(json['calories'].toString()) ?? 0,
      protein: double.tryParse(json['protein'].toString()) ?? 0,
      carbs: double.tryParse(json['carbs'].toString()) ?? 0,
      fat: double.tryParse(json['fat'].toString()) ?? 0,
    );
  }
}
