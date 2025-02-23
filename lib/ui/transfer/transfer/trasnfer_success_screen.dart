import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/model/transfer_fee.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/util/app_ui.dart';

import '../../../custom_theme.dart';
import '../../common/custom_image.dart';
import '../../util/app_util.dart';

class TransferSuccessScreen extends StatelessWidget {
  final String amount;
  final String transactionId;
  final TokenInfo tokenInfo;
  final TransferFee fee;
  final PlanetDto recipient;

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
    required PlanetDto recipient,
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
    var current = context.read<AppBloc>().state as AppLoaded;

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
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: CustomImage(
                      path: "icons/ic_check.svg",
                      width: 40,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Transaction Successful',
                    style: fontSB(14, color: C.current.mainText),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  _label(
                    title: "From",
                    value:
                        AppUtil.shortenWalletAddress(current.current.address),
                  ),
                  _label(
                    title: "To",
                    value: AppUtil.shortenWalletAddress(recipient.address),
                  ),
                  _label(
                    title: "Amount",
                    value: "$amount ${tokenInfo.symbol}",
                  ),
                  _label(
                    title: "Fee",
                    value: "${fee.feeToEth} ${tokenInfo.symbol}",
                  ),
                  _label(
                    title: "TXhash",
                    value: transactionId,
                  ),
                  _label(
                    title: "TXhash",
                    value: DateFormat.yMEd().format(DateTime.now()) +
                        DateFormat.Hms().format(DateTime.now()),
                  ),
                ],
              ),
            ),
            DefaultButton(
              title: "Complete",
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
