import 'package:flutter/material.dart';

import '../../custom_theme.dart';

class CustomBottomSheetHeader extends StatefulWidget {
  final String title;
  final Color? barColor;
  final Color? titleColor;

  const CustomBottomSheetHeader({
    super.key,
    required this.title,
    this.barColor,
    this.titleColor,
  });

  @override
  State<CustomBottomSheetHeader> createState() =>
      _CustomBottomSheetHeaderState();
}

class _CustomBottomSheetHeaderState extends State<CustomBottomSheetHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: (widget.barColor ?? Color(0xffCCCCCC))
                  .withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              alignment: Alignment.center,
              color: Colors.transparent,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                height: 4,
                width: 35,
                decoration: BoxDecoration(
                  color: widget.barColor ?? const Color(0xffCCCCCC),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                widget.title,
                style: fontM(18, color: widget.titleColor ?? Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
