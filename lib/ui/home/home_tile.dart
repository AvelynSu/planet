import 'package:flutter/cupertino.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/token_balance.dart';
import 'package:planet/ui/common/custom_image.dart';

class HomeTile extends StatelessWidget {
  final TokenBalance item;

  const HomeTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: hPadding,
        vertical: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: C.current.lightBase),
          ),
          Expanded(
            child: Text(
              item.info.name,
              style: fontM(16, color: C.current.mainText),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${item.balance}",
                style: fontM(16, color: C.current.mainText),
              ),
              const SizedBox(height: 4),
              Text(
                "${item.balance}",
                style: fontM(14, color: C.current.sub01),
              ),
            ],
          ),
          const SizedBox(width: 14),
          CustomImage(
            width: 20,
            path: "icons/ic_small_arrow.svg",
            color: C.current.sub01,
          ),
        ],
      ),
    );
  }
}
