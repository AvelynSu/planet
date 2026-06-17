import 'package:flutter/cupertino.dart';
import 'package:planet/l10n/app_localizations.dart';

enum GasPriority {
  slow,
  medium,
  fast;

  String getEstimatedTime(BuildContext context) {
    switch (this) {
      case GasPriority.slow:
        return AppLocalizations.of(context)?.gas_priority_slow_time ?? '';
      case GasPriority.medium:
        return AppLocalizations.of(context)?.gas_priority_medium_time ?? '';
      case GasPriority.fast:
        return AppLocalizations.of(context)?.gas_priority_fast_time ?? '';
    }
  }
}
