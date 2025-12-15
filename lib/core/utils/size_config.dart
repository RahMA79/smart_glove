import 'package:flutter/widgets.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;

  static void init(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    screenWidth = size.width;
    screenHeight = size.height;

    // 100 blocks
    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;
  }
}
