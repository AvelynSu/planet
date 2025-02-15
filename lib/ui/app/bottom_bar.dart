import 'package:flutter/material.dart';

import '../../custom_theme.dart';
import '../../enum/menu_type.dart';
import '../common/custom_image.dart';
import '../util/app_ui.dart';

class BottomBar extends StatefulWidget {
  final MenuType selectedType;
  final Function(MenuType) onTap;

  const BottomBar({
    super.key,
    required this.selectedType,
    required this.onTap,
  });

  @override
  State<StatefulWidget> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 14,
        bottom: AppUi.bottomPadding(context),
        left: 32,
        right: 32,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        // borderRadius: const BorderRadius.only(
        //   topLeft: Radius.circular(24),
        //   topRight: Radius.circular(24),
        // ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ...MenuType.values.map(
            (e) {
              return _item(type: e);
            },
          ),
        ],
      ),
    );
  }

  Widget _item({required MenuType type}) {
    bool isSelected = widget.selectedType == type;

    return GestureDetector(
      onTap: () {
        widget.onTap(type);
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImage(
              path: type.iconPath,
              color: isSelected ? primary : borderDisabled,
              height: 38,
            ),
            const SizedBox(height: 6),
            Text(
              type.title,
              style: fontM(
                12,
                color: isSelected ? primary : borderDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
