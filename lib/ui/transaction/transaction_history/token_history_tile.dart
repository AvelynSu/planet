import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/model/transaction_history.dart';
import 'package:planet/ui/common/custom_image.dart';

import '../../../bloc/app/app_bloc.dart';
import '../../../bloc/app/app_state.dart';
import '../../../model/planet.dart';
import '../../../util/app_util.dart';
import '../../../util/bold_generator.dart';
import '../../common/generate_planet.dart';

class TransactionHistoryTile extends StatefulWidget {
  final TransactionHistory item;
  final TokenInfo info;

  const TransactionHistoryTile({
    super.key,
    required this.item,
    required this.info,
  });

  @override
  State<TransactionHistoryTile> createState() => _TransactionHistoryTileState();
}

class _TransactionHistoryTileState extends State<TransactionHistoryTile> {
  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppBloc>().state as AppLoaded;
    var others = appState.others;

    Planet from =
        others.where((e) => e.address == widget.item.from).firstOrNull ??
            Planet.empty;
    Planet to = others.where((e) => e.address == widget.item.to).firstOrNull ??
        Planet.empty;

    return Container(
      height: 72,
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomImage(
                      path: widget.item.status?.iconPath ?? "",
                      width: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.item.status?.title(context) ?? "",
                      style: fontM(16, color: C.current.mainText),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.only(left: 24 + 8),
                  child: Row(
                    children: [
                      if (widget.item.status ==
                          TransactionHistoryStatus.isReceived)
                        _planetTile(from, widget.item.from),
                      if (widget.item.status == TransactionHistoryStatus.isSent)
                        _planetTile(to, widget.item.to),
                    ],
                  ),
                ),
              ]),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BoldMsgGenerator.toRichText(
                  text: "*${widget.item.amount}* ${widget.info.symbol}",
                  style: fontM(16, color: C.current.sub01),
                  boldStyle: fontM(16, color: C.current.mainText)),
              const SizedBox(height: 5),
              BoldMsgGenerator.toRichText(
                  text: AppUtil.tokenToCurrency(
                      (widget.item.amount ?? 0) * widget.info.tokenPrice),
                  style: fontM(16, color: C.current.sub01),
                  boldStyle: fontM(16, color: C.current.mainText)),
            ],
          )
        ],
      ),
    );
  }

  _planetTile(Planet planet, String address) {
    return Row(
      children: [
        planet.name.isEmpty
            ? Stack(alignment: Alignment.center, children: [
                PlanetComponent(
                  network: planet.networkType,
                  data: "a1.",
                  size: 12,
                ),
                Positioned.fill(
                  child: Container(
                    color: C.current.background.withValues(alpha: 0.3),
                  ),
                ),
                Text(
                  "?",
                  style: fontB(
                    12,
                    color: C.current.mainText.withValues(alpha: 0.8),
                  ),
                )
              ])
            : PlanetComponent(
                network: planet.networkType,
                data: planet.name,
                size: 12,
              ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              planet.name.isEmpty
                  ? AppUtil.shortenWalletAddress(address)
                  : planet.name,
              style: fontR(12, color: C.current.mainText),
            ),
          ],
        )
      ],
    );
  }
}
