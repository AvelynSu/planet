import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';

class AppUi {
  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    String? name,
    bool enablePushAnimation = true,
    bool enablePopAnimation = true,
  }) async {
    if (Platform.isIOS) {
      return await Navigator.push<T>(
        context,
        CupertinoPageRoute<T>(
          builder: (context) => page,
          settings: RouteSettings(name: name),
        ),
      );
    } else {
      return await Navigator.push<T>(
        context,
        PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          settings: RouteSettings(name: name),
          transitionDuration: enablePushAnimation
              ? const Duration(milliseconds: 300)
              : Duration.zero,
          // push 애니메이션 적용 여부
          reverseTransitionDuration: enablePopAnimation
              ? const Duration(milliseconds: 300)
              : Duration.zero,
          // pop 애니메이션 적용 여부
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (!enablePushAnimation && !enablePopAnimation) {
              return child; // 애니메이션 없이 바로 화면 전환
            }

            const begin = Offset(1.0, 0.0); // 오른쪽에서 왼쪽으로 이동
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    }
  }

  static double bottomPadding(BuildContext context) {
    var bottom = MediaQuery.of(context).padding.bottom;
    return bottom < 15 ? 16 : max(16, bottom);
  }

  static double statusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
}
