import 'package:flutter/material.dart';

// 테마 모드 관리
class CustomThemeMode {
  static final CustomThemeMode instance = CustomThemeMode._internal();
  static ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  factory CustomThemeMode() => instance;

  CustomThemeMode._internal();

  static bool get isLight => themeMode.value == ThemeMode.light;

  static void change() {
    switch (themeMode.value) {
      case ThemeMode.light:
        themeMode.value = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        themeMode.value = ThemeMode.light;
        break;
      default:
    }
  }
}

// 커스텀 색상 관리
class CustomColors {
  // 텍스트 컬러
  static Color getText({Color? l, Color? b}) {
    return CustomThemeMode.isLight ? (l ?? Colors.black) : (b ?? Colors.white);
  }

  // 배경 컬러
  static Color get getBackground {
    return CustomThemeMode.isLight
        ? Colors.white
        : const Color.fromRGBO(31, 31, 31, 1);
  }

  // 앱바 배경 컬러
  static Color getAppBarBackground() {
    return CustomThemeMode.isLight
        ? Colors.deepOrange
        : const Color.fromRGBO(51, 51, 51, 1);
  }
}
