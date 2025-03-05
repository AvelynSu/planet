
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum MenuType {
  home,
  planets,
  my;

  String title(BuildContext context) {
    switch (this) {
      case MenuType.home:
        return AppLocalizations.of(context)?.menu_type_home ?? '';
      case MenuType.planets:
        return AppLocalizations.of(context)?.menu_type_planets ?? '';
      case MenuType.my:
        return AppLocalizations.of(context)?.menu_type_my ?? '';
    }
  }

  String get iconPath {
    switch (this) {
      case MenuType.home:
        return "icons/ic_planet.svg";
      case MenuType.planets:
        return "icons/ic_planets_menu.svg";
      case MenuType.my:
        return "icons/ic_setting.svg";
    }
  }
}
