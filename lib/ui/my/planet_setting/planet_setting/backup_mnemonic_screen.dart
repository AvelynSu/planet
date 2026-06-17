import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planet/l10n/app_localizations.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/custom_error_card.dart';
import 'package:planet/ui/common/default_dialog.dart';
import 'package:planet/ui/common/mnemonic_pharse_component.dart';
import 'package:planet/ui/common/small_round_button.dart';

import '../../../../custom_theme.dart';
import '../../../../util/app_ui.dart';

class BackupMnemonicScreen extends StatelessWidget {
  final Planet planet;

  const BackupMnemonicScreen({
    super.key,
    required this.planet,
  });

  static push(BuildContext context, {required Planet planet}) {
    AppUi.push(
      context,
      BackupMnemonicScreen(planet: planet),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      onBack: () {
        Navigator.pop(context);
      },
      title: AppLocalizations.of(context)?.mnemonic_phrase_title ?? '',
      body: Column(
        children: [
          const SizedBox(height: 48),
          MnemonicPharseComponent(mnemonic: planet.mnemonic),
          const SizedBox(height: 24),
          Container(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            child: CustomErrorCard(
              iconPath: "",
              title: AppLocalizations.of(context)?.mnemonic_save_safely ?? '',
            ),
          ),
          const SizedBox(height: 48),
          SmallRoundButton(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: planet.mnemonic));
                DefaultDialog.showTimerDialog(context,
                    description: AppLocalizations.of(context)
                            ?.success_copy_mnemonic(planet.mnemonic) ??
                        "",
                    duration: Duration(seconds: 1));
              },
              iconPath: "icons/ic_copy.svg",
              title: AppLocalizations.of(context)?.copy_mnemonic ?? ''),
        ],
      ),
    );
  }
}
