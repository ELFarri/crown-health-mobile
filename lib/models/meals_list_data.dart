class MealsListData {
  MealsListData({
    this.imagePath = '',
    this.title = '',
    this.startColor = '',
    this.endColor = '',
    this.kcal = 0,
    this.meals = const [],
  });

  String imagePath;
  String title;
  String startColor;
  String endColor;
  int kcal;
  List<String> meals;

  static List<MealsListData> tabIconsList = <MealsListData>[
    MealsListData(
      imagePath: 'images/breakfast.png',
      title: 'Breakfast',
      startColor: "#6F56E8",
      endColor: "#C068E4",
      kcal: 350,
      meals: ['Boiled Eggs', 'Toast Bread', 'Avocado'],
    ),
    MealsListData(
      imagePath: 'images/lunch.png',
      title: 'Lunch',
      startColor: "#F1B440",
      endColor: "#F3926E",
      kcal: 680,
      meals: ['Grilled Chicken', 'Brown Rice', 'Vegetables'],
    ),
    MealsListData(
      imagePath: 'images/snack.png',
      title: 'Snack',
      startColor: "#50C9C3",
      endColor: "#87F0D4",
      kcal: 180,
      meals: ['Banana', 'Almonds'],
    ),
    MealsListData(
      imagePath: 'images/dinner.png',
      title: 'Dinner',
      startColor: "#FF8E8E",
      endColor: "#FFAAA6",
      kcal: 420,
      meals: ['Salmon Fish', 'Green Salad'],
    ),
  ];
}
