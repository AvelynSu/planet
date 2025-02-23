enum GasPriority {
  slow,
  medium,
  fast;

  String get getEstimatedTime {
    switch (this) {
      case GasPriority.slow:
        return '5 min';
      case GasPriority.medium:
        return '2 min';
      case GasPriority.fast:
        return '30 sec';
    }
  }
}
