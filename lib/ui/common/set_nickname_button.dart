import 'package:flutter/cupertino.dart';

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
          color: const Color(0xff111117),
          border: Border.all(color: const Color(0xff1E1E28)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: CustomImage(
          path: iconPath,
          width: 40,
        ),
      ),
    );
  }
}
