import 'package:flutter/material.dart';

import '../../custom_theme.dart';
import 'bounce_button.dart';
import 'custom_image.dart';

class SetNicknameButton extends StatelessWidget {
  final Function onTap;
  final String iconPath;

  const SetNicknameButton({
    super.key,
    required this.onTap,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return BounceButton(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: C.current.sub02,
          border: Border.all(color: C.current.lightBase),
          borderRadius: BorderRadius.circular(100),
        ),
        child: CustomImage(
          path: iconPath,
          width: 40,
          color: C.color(Color(0xffBCBDD5), Colors.white),
        ),
      ),
    );
  }
}
