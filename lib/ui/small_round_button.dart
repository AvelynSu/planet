import 'package:flutter/cupertino.dart';

import '../custom_theme.dart';
import 'common/bounce_button.dart';
import 'common/custom_image.dart';

class SmallRoundButton extends StatefulWidget {
  final Function onTap;
  final String iconPath;
  final String title;

  const SmallRoundButton({
    super.key,
    required this.onTap,
    required this.iconPath,
    required this.title,
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
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: C.current.background,
              border: Border.all(color: C.current.sub01.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomImage(path: widget.iconPath),
                const SizedBox(width: 4),
                Text(
                  widget.title,
                  style: fontM(
                    14,
                    color: C.current.mainText.withValues(alpha: 0.8),
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
