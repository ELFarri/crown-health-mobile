class UserModel {
  final int id;
  final String name;
  final String email;
  final String goal;
  final String activityLevel;
  final double height;
  final double weight;
  final int age;
  final String gender;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.goal,
    required this.activityLevel,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      goal: json['goal'] ?? '',
      activityLevel: json['activity_level'] ?? '',
      height: double.tryParse(json['height'].toString()) ?? 170,
      weight: double.tryParse(json['weight'].toString()) ?? 70,
      age: json['age'] ?? 25,
      gender: json['gender'] ?? 'male',
    );
  }
}
