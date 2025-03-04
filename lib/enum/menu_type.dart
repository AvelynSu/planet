enum MenuType {
  home,
  planets,
  my;

  String get title {
    switch (this) {
      case MenuType.home:
        return "Home";
      case MenuType.planets:
        return "Planets";
      case MenuType.my:
        return "My";
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
