import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/custom_image.dart';

import '../util/app_util.dart';

class CopyComponent extends StatefulWidget {
  final PlanetDto planet;
  final Function? onSuccess;

  const CopyComponent({
    super.key,
    required this.planet,
    this.onSuccess,
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
        }
        Fluttertoast.showToast(msg: "Success Copy");
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
              style: fontR(16, color: Color(0xff5C5964)),
            ),
            CustomImage(path: "icons/ic_copy.svg"),
          ],
        ),
      ),
    );
  }
}
