class MealModel {
  final int? id;
  final String title;
  final String imagePath;
  final int kCal;
  final List<String> meals;
  final String startColor;
  final String endColor;

  MealModel({
    this.id,
    required this.title,
    required this.imagePath,
    required this.kCal,
    required this.meals,
    required this.startColor,
    required this.endColor,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'],
      title: json['title'] ?? '',
      imagePath: json['image_path'] ?? '',
      kCal: json['calories'] ?? 0,
      meals: (json['items'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      startColor: json['start_color'] ?? '#FA7D82',
      endColor: json['end_color'] ?? '#FFB295',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'image_path': imagePath,
      'calories': kCal,
      'items': meals,
      'start_color': startColor,
      'end_color': endColor,
    };
  }

  static List<MealModel> tabIconsList = <MealModel>[
    MealModel(
      imagePath: 'images/breakfast.png',
      title: 'Breakfast',
      kCal: 525,
      meals: <String>['Bread,', 'Peanut butter,', 'Apple'],
      startColor: '#FA7D82',
      endColor: '#FFB295',
    ),
    MealModel(
      imagePath: 'images/lunch.png',
      title: 'Lunch',
      kCal: 602,
      meals: <String>['Salmon,', 'Mixed salad,', 'Avocado'],
      startColor: '#738AE6',
      endColor: '#5C5EDD',
    ),
    MealModel(
      imagePath: 'images/snack.png',
      title: 'Snack',
      kCal: 0,
      meals: <String>['Recommend:', '800 kcal'],
      startColor: '#FE95B2',
      endColor: '#FF54BE',
    ),
    MealModel(
      imagePath: 'images/dinner.png',
      title: 'Dinner',
      kCal: 0,
      meals: <String>['Recommend:', '703 kcal'],
      startColor: '#6F72CA',
      endColor: '#1E1466',
    ),
  ];
}
