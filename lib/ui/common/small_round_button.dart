import 'package:flutter/cupertino.dart';

import '../../custom_theme.dart';
import 'bounce_button.dart';
import 'custom_image.dart';

class SmallRoundButton extends StatefulWidget {
  final Function onTap;
  final String? iconPath;
  final String title;
  final Color? backgroundColor;
  final Color? iconColor;
  final double iconSize;
  final double? iconRotate;
  final bool isIconLeft; // 아이콘 왼쪽에 위치

  const SmallRoundButton({
    super.key,
    required this.onTap,
    this.iconPath,
    required this.title,
    this.backgroundColor,
    this.iconSize = 24,
    this.isIconLeft = true,
    this.iconRotate,
    this.iconColor,
  });

  @override
  State<SmallRoundButton> createState() => _SmallRoundButtonState();
}

class _SmallRoundButtonState extends State<SmallRoundButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BounceButton(
          onTap: () {
            widget.onTap();
          },
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? C.current.background,
              border: Border.all(color: C.current.sub01.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.iconPath != null)
                  widget.isIconLeft
                      ? Container(
                          margin: const EdgeInsets.only(right: 4),
                          child: CustomImage(
                            path: widget.iconPath!,
                            width: widget.iconSize,
                            rotate: widget.iconRotate,
                            color: widget.iconColor,
                          ),
                        )
                      : Container(),
                Text(
                  widget.title,
                  style: fontM(
                    14,
                    color: C.current.mainText.withValues(alpha: 0.8),
                  ),
                ),
                if (widget.iconPath != null)
                  widget.isIconLeft
                      ? Container()
                      : Container(
                          margin: const EdgeInsets.only(right: 4),
                          child: CustomImage(
                            path: widget.iconPath!,
                            width: widget.iconSize,
                            rotate: widget.iconRotate,
                            color: widget.iconColor,
                          ),
                        ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
