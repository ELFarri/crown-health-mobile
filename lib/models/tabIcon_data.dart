import 'package:flutter/material.dart';

class TabIconData {
  TabIconData({
    this.index = 0,
    this.image = "",
    this.selectedImage = "",
    this.isSelected = false,
    this.animationController,
  });

  final int index;
  String image;
  String selectedImage;
  bool isSelected;
  AnimationController? animationController;

  static List<TabIconData> tabIconsList = <TabIconData>[
    TabIconData(
      image: 'images/tab_1.png',
      selectedImage: 'images/tab_1s.png',
      index: 0,
      isSelected: true,
    ),
    TabIconData(
      image: 'images/tab_2.png',
      selectedImage: 'images/tab_2s.png',
      index: 1,
      isSelected: false,
    ),
    TabIconData(
      image: 'images/tab_3.png',
      selectedImage: 'images/tab_3s.png',
      index: 2,
      isSelected: false,
    ),
    TabIconData(
      image: 'images/tab_4.png',
      selectedImage: 'images/tab_4s.png',
      index: 3,
      isSelected: false,
    ),
  ];
}
