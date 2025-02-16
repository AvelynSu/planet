import 'package:flutter/material.dart';

// 테마 모드 관리
class CustomThemeMode {
  static final CustomThemeMode instance = CustomThemeMode._internal();
  static ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.dark);

  factory CustomThemeMode() => instance;

  CustomThemeMode._internal();

  static bool get isLight => themeMode.value == ThemeMode.light;

  static void change(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        themeMode.value = ThemeMode.light;
        break;
      case ThemeMode.dark:
        themeMode.value = ThemeMode.dark;
        break;
      default:
    }
  }
}

// 커스텀 색상 관리
class CustomColors {
  static const lightTheme = ColorTheme(
    text: Colors.yellow,
    appbarText: Colors.white,
    background: Colors.white,
    appBarBackground: Colors.deepOrange,
    buttonBackground: Colors.deepOrange,
  );

  static const darkTheme = ColorTheme(
    text: Colors.white,
    appbarText: Colors.white,
    background: Color.fromRGBO(0, 0, 0, 0.95),
    appBarBackground: Color.fromRGBO(51, 51, 51, 1),
    buttonBackground: Colors.black,
  );

  static ColorTheme get current =>
      CustomThemeMode.isLight ? lightTheme : darkTheme;

  static Color color(Color light, Color dark) {
    return CustomThemeMode.isLight ? light : dark;
  }
}

class ColorTheme {
  final Color text;
  final Color appbarText;
  final Color background;
  final Color appBarBackground;
  final Color buttonBackground;

  const ColorTheme({
    required this.text,
    required this.background,
    required this.appbarText,
    required this.appBarBackground,
    required this.buttonBackground,
  });
}

double hPadding = 20;

/// font =======================================================================
TextStyle fontH(double size, {Color? color, double? height}) => TextStyle(
      fontFamily: 'WorkSans',
      fontSize: size,
      fontWeight: FontWeight.w900,
      height: height ?? 1,
      color: color,
    );

TextStyle fontB(double size, {Color? color, double? height}) => TextStyle(
      fontFamily: 'WorkSans',
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: height ?? 1,
      color: color,
    );

TextStyle fontSB(double size, {Color? color, double? height}) => TextStyle(
      fontFamily: 'WorkSans',
      fontSize: size,
      fontWeight: FontWeight.w600,
      height: height ?? 1,
      color: color,
    );

TextStyle fontM(double size, {Color? color, double? height}) => TextStyle(
      fontFamily: 'WorkSans',
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
      fontFamily: 'WorkSans',
      fontSize: size,
      fontWeight: FontWeight.w300,
      height: height ?? 1,
      color: color,
    );

TextStyle fontTH(double size, {Color? color, double? height}) => TextStyle(
      fontFamily: 'WorkSans',
      fontSize: size,
      fontWeight: FontWeight.w100,
      height: height ?? 1,
      color: color,
    );

const primary = Color(0xffFF0050);

const fgBrandPrimary = Color(0xff0050F0);
const borderBrand = Color(0xff8AAFF8);
const bgBrandPrimary = Color(0xffE6EEFE);

const borderSecondary = Color(0xffE6EEFE);

const textPrimary900 = Color(0xff1A1A1E);
const textSecondary = Color(0xff364152);
const textTertiary600 = Color(0xff4B5565);
const textPlaceholder = Color(0xff9AA4B2);

const fgSecondary700 = Color(0xff364152);
const borderPrimary = Color(0xffEEF2F6);
const bgSecondary = Color(0xffF8FAFC);
const bgTertiary = Color(0xffEEF2F6);

List<BoxShadow> boxShadow({
  required Color color,
  required double blur,
  required double x,
  required double y,
}) {
  return [
    BoxShadow(
      color: color,
      blurRadius: blur,
      offset: Offset(x, y),
    ),
  ];
}

// 임시...
const bgDisabled = Color(0xffEEF2F6);
const textDisabled = Color(0xffCDD5DF);
const borderDisabledSubtle = Color(0xffE3E8EF);
const borderDisabled = Color(0xff9AA4B2);
const textQuaternary500 = Color(0xff697586);

const fgDestructive = Color(0xffF04438);

const orange = Color(0xffFE7F2D);
const orange02 = Color(0xffFEE7AA);
const yellow01 = Color(0xffFCCA46);
const yellow02 = Color(0xffFDDB83);
const yellow03 = Color(0xffFFF2EA);

const red = Color(0xffEE3E3B);

const Color b5 = Color(0xff323232);
const Color b3 = Color(0xffCCCCCC);
const Color b2 = Color(0xffE2E2E2);
const Color b1 = Color(0xffEBEBEB);
const white = Colors.white;
