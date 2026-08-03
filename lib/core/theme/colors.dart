import 'package:flutter/material.dart';

abstract final class AppColors {
  // base
  static const backgroundColor = Color.fromRGBO(18, 18, 18, 1);
  static const cardColor = Color.fromRGBO(30, 30, 30, 1);
  static const borderColor = Color.fromRGBO(52, 51, 67, 1);
  static const whiteColor = Colors.white;
  static const greyColor = Colors.grey;
  static const errorColor = Colors.redAccent;
  static const transparentColor = Colors.transparent;

  // gradient
  static const gradient1 = Color.fromRGBO(187, 63, 221, 1);
  static const gradient2 = Color.fromRGBO(251, 109, 169, 1);
  static const gradient3 = Color.fromRGBO(255, 159, 124, 1);

  // text
  static const subtitleText = Color(0xffa7a7a7);
  static const inactiveBottomBarItemColor = Color(0xffababab);

  // status
  static const greenColor = Colors.green;
  static const successColor = Color(0xff4CAF50);
  static const warningColor = Color(0xffFF9800);
  static const infoColor = Color(0xff2196F3);

  static const inactiveSeekColor = Colors.white38;

  // surfaces
  static const surfaceLight = Color.fromRGBO(38, 38, 42, 1);
  static const surfaceMedium = Color.fromRGBO(45, 45, 50, 1);
  static const shimmerBase = Color.fromRGBO(35, 35, 40, 1);
  static const shimmerHighlight = Color.fromRGBO(55, 55, 60, 1);
  static const cardHover = Color.fromRGBO(40, 40, 45, 1);
  static const dividerColor = Color.fromRGBO(60, 60, 70, 0.5);

  // tints for card backgrounds
  static const gradient1Light = Color.fromRGBO(187, 63, 221, 0.15);
  static const gradient2Light = Color.fromRGBO(251, 109, 169, 0.15);
  static const gradient3Light = Color.fromRGBO(255, 159, 124, 0.15);

  static const primaryGradient = LinearGradient(
    colors: [gradient1, gradient2, gradient3],
  );

  static const buttonGradient = LinearGradient(
    colors: [gradient1, gradient2],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const subtleGradient = LinearGradient(
    colors: [gradient1Light, gradient2Light],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardGradient = LinearGradient(
    colors: [
      Color.fromRGBO(30, 30, 30, 1),
      Color.fromRGBO(35, 35, 40, 1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
