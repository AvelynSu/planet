import 'package:flutter/cupertino.dart';
import 'package:planet/service/local_storage_service.dart';
import 'package:planet/util/app_constant.dart';

class GlobalService extends ChangeNotifier {
  Locale locale = Locale("en");

  onUpdateLocale(Locale locale) {
    this.locale = locale;
    notifyListeners();
  }

  initialize() async {
    var current = SharedPrefsUtil.getString(AppConstant.locale) ?? "en";

    locale = Locale(current);
    notifyListeners();
  }
}
