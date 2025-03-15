import 'package:flutter/material.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/custom_image.dart';
import 'package:planet/ui/common/default_button.dart';

import '../../custom_theme.dart';

// todo : 네트워크별 최대 10개 생성 가능

class SelectNetworkModal extends StatefulWidget {
  final NetworkType networkType;
  final Function(NetworkType) onSuccess;

  const SelectNetworkModal({
    super.key,
    required this.networkType,
    required this.onSuccess,
  });

  static Future<NetworkType?> show(
    BuildContext context, {
    required NetworkType networkType,
    required Function(NetworkType) onSuccess,
  }) async {
    return await showDialog(
      useSafeArea: false,
      context: context,
      builder: (_) => SelectNetworkModal(
        networkType: networkType,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<SelectNetworkModal> createState() => _SelectNetworkModalState();
}

class _SelectNetworkModalState extends State<SelectNetworkModal> {
  late NetworkType networkType;

  @override
  void initState() {
    networkType = widget.networkType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        alignment: Alignment.center,
        child: Container(
          width: double.infinity,
          padding:
              EdgeInsets.symmetric(horizontal: hPadding, vertical: hPadding),
          decoration: BoxDecoration(
            color: C.current.sub02,
            border: Border.all(color: C.current.sub01.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Network',
                style: fontR(16, color: C.current.mainText),
              ),
              const SizedBox(height: 24),
              ...NetworkType.values.map(
                (e) => _tile(
                  networkType: e,
                  iconPath: e.icon,
                  title: e.title,
                ),
              ),
              const SizedBox(height: 24),
              DefaultButton(
                title: "Select",
                onTap: () {
                  widget.onSuccess(networkType);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _tile({
    required NetworkType networkType,
    required String iconPath,
    required String title,
  }) {
    bool isSelected = this.networkType == networkType;
    return BounceButton(
      onTap: () {
        this.networkType = networkType;
        setState(() {});
      },
      child: Container(
        color: Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(5),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(color: C.current.sub01),
                borderRadius: BorderRadius.circular(100),
              ),
              child: isSelected
                  ? Container(
                      decoration: BoxDecoration(
                        color: C.current.mainText,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            CustomImage(
              path: iconPath,
              width: 28,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: fontR(14, color: C.current.mainText),
            )
          ],
        ),
      ),
    );
  }
}
