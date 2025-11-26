import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'tab_icon_data.g.dart';

@HiveType(typeId: 3)
class TabIconData extends HiveObject {
  @HiveField(0)
  final String imagePath;

  @HiveField(1)
  String selectedImagePath;

  @HiveField(2)
  bool isSelected;

  @HiveField(3)
  final int index;

  @HiveField(4)
  AnimationController? animationController;

  TabIconData({
    required this.imagePath,
    required this.selectedImagePath,
    required this.isSelected,
    required this.index,
    this.animationController,
  });
}
