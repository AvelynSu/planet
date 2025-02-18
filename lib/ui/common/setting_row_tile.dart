import 'package:flutter/material.dart';

import '../../custom_theme.dart';
import 'custom_image.dart';

class SettingRowTile extends StatelessWidget {
  final Function onTap;
  final String title;
  final bool showArrow;
  final String? subText;
  final Widget? child;

  const SettingRowTile({
    super.key,
    required this.onTap,
    required this.title,
    this.showArrow = true,
    this.subText,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        color: Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 5),
        height: 48,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title ?? "",
                style: fontR(16, color: C.current.mainText),
              ),
            ),
            Row(
              children: [
                if (child != null) child!,
                Text(
                  subText ?? "",
                  style: fontR(14, color: const Color(0xff5C5964)),
                ),
                if (showArrow)
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    child: CustomImage(
                      path: "icons/ic_small_arrow.svg",
                      color: C.current.sub01,
                      width: 20,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
