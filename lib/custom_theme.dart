import 'package:flutter/material.dart';

// 테마 모드 관리
class CustomThemeMode {
  static final CustomThemeMode instance = CustomThemeMode._internal();
  static ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.dark);

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
  static const lightTheme = _ColorTheme(
    text: Colors.yellow,
    appbarText: Colors.white,
    background: Colors.white,
    appBarBackground: Colors.deepOrange,
    buttonBackground: Colors.deepOrange,
  );

  static const darkTheme = _ColorTheme(
    text: Colors.white,
    appbarText: Colors.white,
    background: Color.fromRGBO(31, 31, 31, 1),
    appBarBackground: Color.fromRGBO(51, 51, 51, 1),
    buttonBackground: Colors.black,
  );

  static _ColorTheme get current =>
      CustomThemeMode.isLight ? lightTheme : darkTheme;
}

class _ColorTheme {
  final Color text;
  final Color appbarText;
  final Color background;
  final Color appBarBackground;
  final Color buttonBackground;

  const _ColorTheme({
    required this.text,
    required this.background,
    required this.appbarText,
    required this.appBarBackground,
    required this.buttonBackground,
  });
}

/// font =======================================================================
TextStyle fontH(double size, {Color? color, double? height}) => TextStyle(
      fontFamily: 'Pretendard',
      fontSize: size,
      fontWeight: FontWeight.w900,
      height: height ?? 1,
      color: color,
    );

TextStyle fontB(double size, {Color? color, double? height}) => TextStyle(
      fontFamily: 'Pretendard',
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: height ?? 1,
      color: color,
    );

TextStyle fontSB(double size, {Color? color, double? height}) => TextStyle(
      fontFamily: 'Pretendard',
      fontSize: size,
      fontWeight: FontWeight.w600,
      height: height ?? 1,
      color: color,
    );

TextStyle fontM(double size, {Color? color, double? height}) => TextStyle(
      fontFamily: 'Pretendard',
      fontSize: size,
      fontWeight: FontWeight.w500,
      height: height ?? 1,
      color: color,
    );

TextStyle fontR(double size, {Color? color, double? height}) => TextStyle(
      fontFamily: 'Pretendard',
      fontSize: size,
      fontWeight: FontWeight.w400,
      height: height ?? 1,
      color: color,
    );

TextStyle fontL(double size, {Color? color, double? height}) => TextStyle(
      fontFamily: 'Pretendard',
      fontSize: size,
      fontWeight: FontWeight.w300,
      height: height ?? 1,
      color: color,
    );

TextStyle fontTH(double size, {Color? color, double? height}) => TextStyle(
      fontFamily: 'Pretendard',
      fontSize: size,
      fontWeight: FontWeight.w100,
      height: height ?? 1,
      color: color,
    );
