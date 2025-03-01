import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppUi {
  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    String? name,
    bool rootNavigator = false,
  }) async {
    if (Platform.isIOS) {
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
