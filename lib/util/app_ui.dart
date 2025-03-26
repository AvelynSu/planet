import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppUi {
  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    String? name,
    bool rootNavigator = false,
  }) async {
    if (kIsWeb) {
      return await Navigator.of(context, rootNavigator: rootNavigator)
          .push<T>(PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        settings: RouteSettings(name: name),
      ));
    } else if (Platform.isIOS) {
      return await Navigator.of(context, rootNavigator: rootNavigator)
          .push<T>(CupertinoPageRoute<T>(
        builder: (context) => page,
        settings: RouteSettings(name: name),
      ));
    } else {
      return await Navigator.of(context, rootNavigator: rootNavigator)
          .push<T>(MaterialPageRoute<T>(
        builder: (context) => page,
        settings: RouteSettings(name: name),
      ));
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
