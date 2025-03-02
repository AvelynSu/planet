import 'package:flutter/cupertino.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/transaction_history.dart';
import 'package:planet/ui/common/custom_image.dart';

import '../../../util/bold_generator.dart';

class TransactionHistoryTile extends StatefulWidget {
  final TransactionHistory item;

  const TransactionHistoryTile({
    super.key,
    required this.item,
  });

  @override
  State<TransactionHistoryTile> createState() => _TransactionHistoryTileState();
}

class _TransactionHistoryTileState extends State<TransactionHistoryTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CustomImage(
                path: widget.item.status?.iconPath ?? "",
                width: 24,
              ),
              const SizedBox(width: 10),
              Text(
                widget.item.status?.title ?? "",
                style: fontM(16, color: C.current.mainText),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BoldMsgGenerator.toRichText(
                  text: "*${widget.item.amount}* ${widget.item.tokenSymbol}",
                  style: fontM(16, color: C.current.sub01),
                  boldStyle: fontM(16, color: C.current.mainText)),
              const SizedBox(height: 5),
              BoldMsgGenerator.toRichText(
                  text: "0.01* USD",
                  style: fontM(16, color: C.current.sub01),
                  boldStyle: fontM(16, color: C.current.mainText)),
            ],
          )
        ],
      ),
    );
  }
}
