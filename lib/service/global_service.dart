import 'package:flutter/cupertino.dart';

class GlobalService extends ChangeNotifier {
  Locale locale = Locale("en");

  onUpdateLocale(Locale locale) {
    this.locale = locale;
    notifyListeners();
  }
}
