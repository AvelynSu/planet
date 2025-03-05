import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/ui/common/custom_bottom_sheet_frame.dart';
import 'package:planet/ui/common/custom_error_card.dart';
import 'package:planet/ui/common/custom_toggle.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/common/mnemonic_pharse_component.dart';
import 'package:planet/util/app_ui.dart';

import '../../custom_theme.dart';
import '../common/default_dialog.dart';
import '../common/small_round_button.dart';

class LogoutBottomSheet extends StatefulWidget {
  const LogoutBottomSheet({super.key});

  static Future<bool?> show(BuildContext context) async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogoutBottomSheet(),
    );
  }

  @override
  State<LogoutBottomSheet> createState() => _LogoutBottomSheetState();
}

class _LogoutBottomSheetState extends State<LogoutBottomSheet> {
  bool isCheck = false;

  @override
  Widget build(BuildContext context) {
    var mnemonic =
        (context.read<AppBloc>().state as AppLoaded).current.mnemonic;
    return CustomBottomSheetFrame(
      title: "Sign out",
      topPadding: 0,
      backgroundColor: C.current.sub02,
      titleColor: C.current.mainText,
      barColor: C.current.sub01.withValues(alpha: 0.5),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        child: Column(
          children: [
            CustomErrorCard(
              iconPath: "",
              title:
                  AppLocalizations.of(context)?.mnemonic_logout_warning ?? '',
            ),
            SizedBox(height: 24),
            MnemonicPharseComponent(
              mnemonic: mnemonic,
              padding: 0,
            ),
            SizedBox(height: 24),
            SmallRoundButton(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: mnemonic));
                DefaultDialog.showTimerDialog(context,
                    description:
                        AppLocalizations.of(context)?.success_copy ?? "",
                    duration: Duration(seconds: 1));
              },
              iconPath: "icons/ic_copy.svg",
              title:
                  AppLocalizations.of(context)?.wallet_create_copy_words ?? '',
            ),
            SizedBox(height: 24),

            /// 이해했습니다.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)
                            ?.mnemonic_logout_confirmation ??
                        '',
                    style: fontR(
                      14,
                      color: C.current.mainText,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    isCheck = !isCheck;
                    setState(() {});
                  },
                  child: CustomToggle(value: isCheck),
                ),
              ],
            ),
            const SizedBox(height: 24),

            /// 로그아웃 버튼
            DefaultButton(
              title: AppLocalizations.of(context)?.settings_sign_out ?? '',
              onTap: isCheck
                  ? () {
                      Navigator.pop(context, true);
                    }
                  : null,
            ),
            SizedBox(height: AppUi.bottomPadding(context)),
          ],
        ),
      ),
    );
  }
}
