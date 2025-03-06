import 'package:flutter/material.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:provider/provider.dart';

import '../../custom_theme.dart';
import '../../enum/menu_type.dart';
import '../../service/global_service.dart';
import '../../util/app_ui.dart';
import '../common/custom_image.dart';

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
    context.watch<GlobalService>();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 12,
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

    return BounceButton(
      hasHaptic: true,
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
              height: 36,
            ),
            const SizedBox(height: 4),
            Text(
              type.title(context),
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
