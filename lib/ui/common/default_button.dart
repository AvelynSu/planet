import 'package:flutter/material.dart';
import 'package:planet/custom_theme.dart';

import '../util/app_ui.dart';
import '../util/bold_generator.dart';
import 'bounce_button.dart';
import 'custom_image.dart';

class DefaultButton extends StatefulWidget {
  final String title;
  final String? description;
  final String? iconPath;
  final Color? color;
  final Color? textColor;
  final TextStyle? style;
  final bool isReverse;
  final Function()? onTap;
  final bool showBottomPadding;
  final String? prefixIcon;
  final Color? borderColor;
  final BoxShadow? shadow;

  const DefaultButton({
    super.key,
    required this.title,
    this.description,
    this.iconPath,
    this.onTap,
    this.isReverse = false,
    this.color,
    this.style,
    this.textColor,
    this.showBottomPadding = false,
    this.borderColor,
    this.prefixIcon,
    this.shadow,
  });

  @override
  State<StatefulWidget> createState() => DefaultButtonState();
}

class DefaultButtonState extends State<DefaultButton> {
  @override
  Widget build(BuildContext context) {
    var activateColor = widget.color ?? C.current.onBackground;
    var deactivateColor = C.current.lightBase;
    var requiredBoldGenerator = widget.title.contains('*');
    var buttonTitleColor = widget.isReverse
        ? widget.onTap == null
            ? b3
            : b5
        : widget.onTap == null
            ? C.current.sub01
            : widget.textColor ?? C.current.background;
    return BounceButton(
      hasHaptic: false,
      onTap: () {
        if (widget.onTap != null) {
          FocusScope.of(context).unfocus();
          widget.onTap!();
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: widget.showBottomPadding ? AppUi.bottomPadding(context) : 0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isReverse
                ? C.current.onBackground
                : widget.borderColor == null
                    ? (widget.onTap != null
                        ? Colors.white.withOpacity(0)
                        : Colors.transparent)
                    : widget.borderColor!,
          ),
          boxShadow: widget.shadow != null ? [widget.shadow!] : [],
          color: widget.isReverse
              ? C.current.background
              : widget.onTap != null
                  ? activateColor
                  : deactivateColor,
        ),
        height: 52,
        alignment: Alignment.center,
        child: IgnorePointer(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              if (widget.iconPath != null)
                Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  child: CustomImage(path: widget.iconPath!),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: BoldMsgGenerator.toRichText(
                        text: widget.title,
                        textAlign: TextAlign.center,
                        style: widget.style ??
                            (requiredBoldGenerator ? fontB(18) : fontR(18))
                                .copyWith(
                                    color: widget.isReverse
                                        ? C.current.onBackground
                                        : buttonTitleColor,
                                    height: 1.4),
                        boldStyle: fontB(18).copyWith(
                            color:
                                widget.isReverse ? white : buttonTitleColor)),
                  ),
                  if (widget.description != null)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      child: Text(
                        widget.description!,
                        style: fontR(12, color: buttonTitleColor),
                      ),
                    ),
                ],
              ),
              if (widget.prefixIcon != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.centerLeft,
                  child: CustomImage(
                    path: widget.prefixIcon!,
                    color: Colors.white,
                    width: 32,
                  ),
                )
            ],
          ),
        ),
      ),
      //   if (widget.prefixIcon != null)
      //     CustomImage(
      //       path: widget.prefixIcon!,
      //       color: pink,
      //       width: 32,
      //     )
      // ]),
    );
  }
}
