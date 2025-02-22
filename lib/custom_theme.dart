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

class C {
  final Color primary;
  final Color onBackground;
  final Color mainText;
  final Color sub01; // AAAAAA // 5C5964
  final Color sub02;

  final Color background;
  final Color lightBase; // EDEDED // 1E1E28

  const C({
    required this.primary,
    required this.mainText,
    required this.background,
    required this.onBackground,
    required this.sub01,
    required this.sub02,
    required this.lightBase,
  });

  static const lightTheme = C(
    primary: Color(0xffFF0050),
    mainText: Colors.black,
    sub01: Color(0xffAAAAAA),
    sub02: Color(0xffFCFCFC),
    background: Colors.white,
    onBackground: Colors.black,
    lightBase: Color(0xffEDEDED),
  );

  static const darkTheme = C(
    primary: Color(0xffFF0050),
    mainText: Colors.white,
    sub01: Color(0xff5C5964),
    sub02: Color(0xff111117),
    background: Colors.black,
    onBackground: Colors.white,
    lightBase: Color(0xff1E1E28),
  );

  static C get current => CustomThemeMode.isLight ? lightTheme : darkTheme;

  static Color color(Color light, Color dark) {
    return CustomThemeMode.isLight ? light : dark;
  }
}

double hPadding = 20;

/// font =======================================================================
TextStyle fontH(double size,
        {Color? color, double? height, bool isIalic = false}) =>
    TextStyle(
      fontFamily: 'WorkSans',
      fontSize: size,
      fontWeight: FontWeight.w900,
      height: height ?? 1,
      color: color,
      fontStyle: isIalic ? FontStyle.italic : null,
    );

TextStyle fontB(double size,
        {Color? color, double? height, bool isIalic = false}) =>
    TextStyle(
      fontFamily: 'WorkSans',
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: height ?? 1,
      color: color,
      fontStyle: isIalic ? FontStyle.italic : null,
    );

TextStyle fontSB(double size,
        {Color? color, double? height, bool isIalic = false}) =>
    TextStyle(
      fontFamily: 'WorkSans',
      fontSize: size,
      fontWeight: FontWeight.w600,
      height: height ?? 1,
      color: color,
      fontStyle: isIalic ? FontStyle.italic : null,
    );

TextStyle fontM(double size,
        {Color? color, double? height, bool isIalic = false}) =>
    TextStyle(
      fontFamily: 'WorkSans',
      fontSize: size,
      fontWeight: FontWeight.w500,
      height: height ?? 1,
      color: color,
      fontStyle: isIalic ? FontStyle.italic : null,
    );

TextStyle fontR(double size,
        {Color? color, double? height, bool isIalic = false}) =>
    TextStyle(
      fontFamily: 'WorkSans',
      fontSize: size,
      fontWeight: FontWeight.w400,
      height: height ?? 1,
      color: color,
      fontStyle: isIalic ? FontStyle.italic : null,
    );

TextStyle fontL(double size,
        {Color? color, double? height, bool isIalic = false}) =>
    TextStyle(
      fontFamily: 'WorkSans',
      fontSize: size,
      fontWeight: FontWeight.w300,
      height: height ?? 1,
      color: color,
      fontStyle: isIalic ? FontStyle.italic : null,
    );

TextStyle fontTH(double size,
        {Color? color, double? height, bool isIalic = false}) =>
    TextStyle(
      fontFamily: 'WorkSans',
      fontSize: size,
      fontWeight: FontWeight.w100,
      height: height ?? 1,
      color: color,
      fontStyle: isIalic ? FontStyle.italic : null,
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
