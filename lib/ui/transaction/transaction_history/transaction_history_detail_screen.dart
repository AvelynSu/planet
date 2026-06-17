import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/model/transaction_history.dart';
import 'package:planet/ui/common/custom_image.dart';

import '../../../bloc/app/app_bloc.dart';
import '../../../bloc/app/app_state.dart';
import '../../../custom_theme.dart';
import '../../../model/planet.dart';
import '../../../util/app_ui.dart';
import '../../../util/app_util.dart';
import '../../common/base_scaffold.dart';
import '../../common/default_dialog.dart';
import '../../common/generate_planet.dart';
import '../transfer/transfer/component/transfer_label.dart';

class TransactionHistoryDetailScreen extends StatefulWidget {
  final TokenInfo info;
  final TransactionHistory item;

  const TransactionHistoryDetailScreen({
    super.key,
    required this.info,
    required this.item,
  });

  static push(
    BuildContext context, {
    required TokenInfo info,
    required TransactionHistory item,
  }) {
    AppUi.push(
        context,
        TransactionHistoryDetailScreen(
          info: info,
          item: item,
        ));
  }

  @override
  State<TransactionHistoryDetailScreen> createState() =>
      _TransactionHistoryDetailScreenState();
}

class _TransactionHistoryDetailScreenState
    extends State<TransactionHistoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppBloc>().state as AppLoaded;
    var others = appState.others;

    Planet from =
        others.where((e) => e.address == widget.item.from).firstOrNull ??
            Planet.empty;
    Planet to = others.where((e) => e.address == widget.item.to).firstOrNull ??
        Planet.empty;

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
                  TransferLabel(
                    title: "종류",
                    value: " ${widget.item.status?.title(context)}",
                    body: Row(
                      children: [
                        CustomImage(path: widget.item.status?.iconPath ?? "")
                      ],
                    ),
                  ),
                  TransferLabel(
                      title:
                          AppLocalizations.of(context)?.transfer_label_from ??
                              '',
                      body: Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: from.name.isEmpty
                            ? null
                            : PlanetComponent(
                                network: from.networkType,
                                data: from.name,
                                size: 24,
                              ),
                      ),
                      value: from.name.isEmpty
                          ? AppUtil.shortenWalletAddress(from.address)
                          : from.name,
                      description: from.name.isEmpty
                          ? null
                          : AppUtil.shortenWalletAddress(widget.item.from)),
                  TransferLabel(
                    title:
                        AppLocalizations.of(context)?.transfer_label_to ?? '',
                    value: to.name,
                    body: Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: PlanetComponent(
                        network: to.networkType,
                        data: to.name,
                        size: 24,
                      ),
                    ),
                    description: AppUtil.shortenWalletAddress(
                      to.address,
                    ),
                  ),
                  _label(
                    title: AppLocalizations.of(context)?.transfer_amount ?? '',
                    value: "${widget.item.amount} ${widget.info.symbol}",
                  ),
                  // _label(
                  //   title: "Fee",
                  //   value: "${widget.item.tokenSymbol} ${widget.info.symbol}",
                  // ),
                  GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(
                          ClipboardData(text: widget.item.hash));

                      DefaultDialog.showTimerDialog(context,
                          description:
                              AppLocalizations.of(context)!.success_copy);
                    },
                    child: _label(
                        title: "TXhash",
                        size: 13,
                        value: widget.item.hash,
                        body: CustomImage(path: "icons/ic_copy.svg")),
                  ),
                  _label(
                    title: AppLocalizations.of(context)?.transfer_date ?? '',
                    value: DateFormat.yMEd().format(widget.item.timestamp!) +
                        " " +
                        DateFormat.Hms().format(widget.item.timestamp!),
                  ),
                ],
              ),
            ),
            // DefaultButton(
            //   title: AppLocalizations.of(context)?.transfer_complete ?? '',
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  _label({
    required String title,
    String? value,
    Widget? body,
    double? size,
  }) {
    return Container(
      color: Colors.transparent,
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: fontR(14, color: C.current.sub01)),
          SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value ?? "",
                    textAlign: TextAlign.end,
                    style: fontR(
                      size ?? 16,
                      color: C.current.mainText,
                      height: 1.3,
                    ),
                  ),
                ),
                body ?? Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
