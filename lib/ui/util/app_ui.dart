import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppUi {
  static Future<T?> push<T>(BuildContext context, Widget page,
      {String? name}) async {
    if (Platform.isIOS) {
      return await Navigator.push<T>(
          context,
          CupertinoPageRoute<T>(
            builder: (context) => page,
            settings: RouteSettings(name: name),
          ));
    } else {
      return await Navigator.push<T>(
          context,
          MaterialPageRoute<T>(
            builder: (context) => page,
            settings: RouteSettings(name: name),
          ));
    }
  }

  static double bottomPadding(BuildContext context) {
    var bottom = MediaQuery.of(context).padding.bottom;
    return bottom < 15 ? 16 : min(16, bottom);
  }

  static double statusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
}
