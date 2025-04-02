import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/my/security/delete_account_bottom_sheet.dart';
import 'package:planet/ui/pin_screen.dart';

import '../../../util/app_ui.dart';
import '../../common/setting_row_tile.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const SecurityScreen());
  }

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      onBack: () {
        Navigator.pop(context);
      },
      title: AppLocalizations.of(context)?.planet_setting_title ?? '',
      body: Column(
        children: [
          SettingRowTile(
            onTap: () {
              PinScreen.push(
                context,
                onBack: () {
                  Navigator.pop(context);
                },
                onSuccess: (value) {
                  if (value) {
                    Navigator.pop(context);
                    PinScreen.push(
                      context,
                      onBack: () {
                        Navigator.pop(context);
                      },
                      onSuccess: (value) {
                        Navigator.pop(context);
                      },
                      mode: PinMode.setup,
                    );
                  }
                },
                mode: PinMode.validate,
              );
            },
            title: AppLocalizations.of(context)?.change_pincode ?? '',
          ),
          SettingRowTile(
            onTap: () async {
              var result = await DeleteAccountBottomSheet.show(
                context,
                onSuccess: () {
                  var allPlanet =
                      (context.read<AppBloc>().state as AppLoaded).planets;
                  context.read<AppBloc>().add(AppDelete(allPlanet));
                },
              );
            },
            title: AppLocalizations.of(context)!.deleteAccount,
          ),
        ],
      ),
    );
  }
}
