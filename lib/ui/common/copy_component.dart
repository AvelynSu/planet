import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/custom_image.dart';
import 'package:planet/ui/common/default_dialog.dart';

import '../../util/app_util.dart';

class CopyComponent extends StatefulWidget {
  final Planet planet;
  final Function? onSuccess;
  final bool showSuccessDialog;
  final bool enableBackground;

  const CopyComponent({
    super.key,
    required this.planet,
    this.onSuccess,
    this.showSuccessDialog = false,
    this.enableBackground = false,
  });

  @override
  State<CopyComponent> createState() => _CopyComponentState();
}

class _CopyComponentState extends State<CopyComponent> {
  @override
  Widget build(BuildContext context) {
    return BounceButton(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: widget.planet.address));
        if (widget.onSuccess != null) {
          widget.onSuccess!();
          if (widget.showSuccessDialog) {
            DefaultDialog.showTimerDialog(context, description: "Success Copy");
          }
        }
        // Fluttertoast.showToast(msg: "Success Copy");
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: widget.enableBackground
              ? C.current.onBackground.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppUtil.shortenWalletAddress(widget.planet.address),
              style: fontR(
                15,
                color: C.current.onBackground.withValues(alpha: 0.65),
              ),
            ),
            CustomImage(
              path: "icons/ic_copy.svg",
              color: C.current.onBackground.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
