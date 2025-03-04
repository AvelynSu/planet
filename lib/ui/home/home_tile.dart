import 'package:flutter/cupertino.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/token_balance.dart';
import 'package:planet/service/local_storage_service.dart';
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
      padding: EdgeInsets.only(
        left: hPadding,
        right: hPadding,
        top: 16,
        bottom: 16,
      ),
      margin: const EdgeInsets.only(
        bottom: 12,
        // left: hPadding,
        // right: hPadding,
      ),
      decoration: BoxDecoration(
          color: C.current.lightBase.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: C.color(C.current.sub01.withValues(alpha: 0.18),
                  C.current.onBackground.withValues(alpha: 0.1)),
            ),
            child: CustomImage(path: item.info.logoUrl ?? ""),
          ),
          Expanded(
            child: Text(
              item.info.name,
              style: fontM(14, color: C.current.mainText),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${item.balance}" + " ${item.info.symbol}",
                style: fontM(14, color: C.current.mainText),
              ),
              const SizedBox(height: 6),
              Text(
                "${item.balance}"
                "${SharedPrefsUtil.currency}",
                style: fontM(12, color: C.current.sub01),
              ),
            ],
          ),
          const SizedBox(width: 4),
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
