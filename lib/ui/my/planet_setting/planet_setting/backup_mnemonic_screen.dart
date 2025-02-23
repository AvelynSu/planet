import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/custom_error_card.dart';
import 'package:planet/ui/common/default_dialog.dart';
import 'package:planet/ui/small_round_button.dart';

import '../../../../custom_theme.dart';
import '../../../util/app_ui.dart';

class BackupMnemonicScreen extends StatelessWidget {
  final PlanetDto planet;

  const BackupMnemonicScreen({
    super.key,
    required this.planet,
  });

  static push(BuildContext context, {required PlanetDto planet}) {
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
      title: 'Mnemonic Phrase',
      body: Container(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                padding: EdgeInsets.all(0),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12.0,
                  crossAxisSpacing: 12.0,
                  mainAxisExtent: 44,
                ),
                itemCount: planet.mnemonic.split(" ").length,
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  var items = planet.mnemonic.split(" ");
                  var item = items.length > i ? items[i] : "";
                  return Container(
                    decoration: BoxDecoration(
                      color: C.current.lightBase,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: C.current.sub01.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "${i + 1}. $item",
                        style: fontM(14, color: C.current.mainText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: CustomErrorCard(
                  iconPath: "", title: "Save the Mnemonic Phrase safely."),
            ),
            const SizedBox(height: 48),
            SmallRoundButton(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: planet.mnemonic));
                  DefaultDialog.showTimerDialog(context,
                      description: "*Success copy*\n${planet.mnemonic}",
                      duration: Duration(seconds: 1));
                },
                iconPath: "icons/ic_copy.svg",
                title: "Copy Mnemonic"),
          ],
        ),
      ),
    );
  }
}
