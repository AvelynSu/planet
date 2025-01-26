import 'dart:io';

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
}
