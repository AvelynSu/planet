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

  const CopyComponent({
    super.key,
    required this.planet,
    this.onSuccess,
    this.showSuccessDialog = false,
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
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppUtil.shortenWalletAddress(widget.planet.address),
              style: fontR(16, color: C.current.sub01),
            ),
            CustomImage(
              path: "icons/ic_copy.svg",
              color: C.current.sub01,
            ),
          ],
        ),
      ),
    );
  }
}
