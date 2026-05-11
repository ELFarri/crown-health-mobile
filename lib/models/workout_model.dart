class WorkoutModel {
  final int id;
  final String name;
  final String category; // cardio, strength, flexibility
  final int duration; // بالدقائق
  final double caloriesBurned; // سعرات محروقة لكل دقيقة
  final String description;
  final String imageUrl;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.category,
    required this.duration,
    required this.caloriesBurned,
    required this.description,
    required this.imageUrl,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      duration: json['duration'] ?? 0,
      caloriesBurned: double.tryParse(json['calories_burned'].toString()) ?? 0,
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'duration': duration,
      'calories_burned': caloriesBurned,
      'description': description,
      'image_url': imageUrl,
    };
  }
}
