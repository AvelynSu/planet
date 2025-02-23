import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/service/wallet/wallet_service.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/default_dialog.dart';
import 'package:planet/ui/common/small_round_button.dart';

import '../../../../custom_theme.dart';
import '../../../../util/app_ui.dart';

class BackupPrivateKeyScreen extends StatefulWidget {
  final PlanetDto planet;

  BackupPrivateKeyScreen({
    super.key,
    required this.planet,
  });

  static push(BuildContext context, {required PlanetDto planet}) {
    AppUi.push(
      context,
      BackupPrivateKeyScreen(planet: planet),
    );
  }

  @override
  State<BackupPrivateKeyScreen> createState() => _BackupPrivacyKeyScreenState();
}

class _BackupPrivacyKeyScreenState extends State<BackupPrivateKeyScreen> {
  String key = "";

  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() async {
    key = await WalletService().getPrivateKeyFromMnemonic(
        widget.planet.mnemonic, NetworkType.ethereum, 0);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      onBack: () {
        Navigator.pop(context);
      },
      title: 'Backup Private Key',
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Private Key',
              style: fontR(18, color: C.current.sub01),
            ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 12),
              width: double.infinity,
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
                  key,
                  style: fontM(14, color: C.current.mainText, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SmallRoundButton(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: key));
                  DefaultDialog.showTimerDialog(context,
                      description: "*Success copy*\n${key}",
                      duration: Duration(seconds: 1));
                },
                iconPath: "icons/ic_copy.svg",
                title: "Copy Private Key"),
          ],
        ),
      ),
    );
  }
}
