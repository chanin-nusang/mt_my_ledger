import 'package:flutter/material.dart';

enum ScreenSize { small, medium, large }

extension ScreenSizeUtils on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  ScreenSize get screenSize {
    final width = screenWidth;
    if (width < 600) {
      return ScreenSize.small;
    } else if (width < 1200) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }

  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;
}
