import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/model/transfer_fee.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/common/generate_planet.dart';

import '../../../../custom_theme.dart';
import '../../../../util/app_ui.dart';
import '../../../../util/app_util.dart';
import '../../../common/custom_image.dart';
import 'component/transfer_label.dart';

class TransferSuccessScreen extends StatelessWidget {
  final String amount;
  final String transactionId;
  final TokenInfo tokenInfo;
  final TransferFee fee;
  final Planet recipient;

  const TransferSuccessScreen({
    super.key,
    required this.fee,
    required this.transactionId,
    required this.amount,
    required this.tokenInfo,
    required this.recipient,
  });

  static Future<void> push(
    BuildContext context, {
    required String transactionId,
    required TransferFee fee,
    required String amount,
    required TokenInfo tokenInfo,
    required Planet recipient,
  }) async {
    return await AppUi.push(
        context,
        TransferSuccessScreen(
          transactionId: transactionId,
          fee: fee,
          amount: amount,
          tokenInfo: tokenInfo,
          recipient: recipient,
        ));
  }

  @override
  Widget build(BuildContext context) {
    var appState = (context.read<AppBloc>().state as AppLoaded);
    return BaseScaffold(
      onBack: () {
        Navigator.pop(context);
      },
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: C.current.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Success icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: CustomImage(
                      path: "icons/ic_check.svg",
                      width: 52,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)?.transfer_successful ?? '',
                    style: fontSB(14, color: C.current.mainText),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 80),

                  TransferLabel(
                    title:
                        AppLocalizations.of(context)?.transfer_label_to ?? '',
                    value: appState.current.name,
                    body: Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: PlanetComponent(
                        data: appState.current.name,
                        size: 24,
                      ),
                    ),
                    description: AppUtil.shortenWalletAddress(
                      appState.current.address,
                    ),
                  ),
                  TransferLabel(
                      title:
                          AppLocalizations.of(context)?.transfer_label_from ??
                              '',
                      body: Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: recipient.name.isEmpty
                            ? null
                            : PlanetComponent(
                                data: recipient.name,
                                size: 24,
                              ),
                      ),
                      value: recipient.name.isEmpty
                          ? AppUtil.shortenWalletAddress(recipient.address)
                          : recipient.name,
                      description: recipient.name.isEmpty
                          ? null
                          : AppUtil.shortenWalletAddress(recipient.address)),

                  _label(
                    title: AppLocalizations.of(context)?.transfer_amount ?? '',
                    value: "$amount ${tokenInfo.symbol}",
                  ),
                  _label(
                    title: "Fee",
                    value:
                        "${fee.feeToUiValue(tokenInfo.networkType)} ${tokenInfo.symbol}",
                  ),
                  // _label(
                  //   title: "TXhash",
                  //   value: transactionId,
                  // ),
                  _label(
                    title: AppLocalizations.of(context)?.transfer_date ?? '',
                    value: DateFormat.yMEd().format(DateTime.now()) +
                        DateFormat.Hms().format(DateTime.now()),
                  ),
                ],
              ),
            ),
            DefaultButton(
              title: AppLocalizations.of(context)?.transfer_complete ?? '',
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  _label({
    required String title,
    String? value,
    Widget? body,
  }) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: fontR(14, color: C.current.sub01)),
          ),
          Text(
            value ?? "",
            style: fontR(16, color: C.current.mainText),
          ),
          body ?? Container(),
        ],
      ),
    );
  }
}
