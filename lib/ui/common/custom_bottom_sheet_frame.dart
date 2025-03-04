import 'package:flutter/material.dart';

import 'custom_bottom_sheet_header.dart';

class CustomBottomSheetFrame extends StatefulWidget {
  final String title;
  final Widget child;
  final Color? backgroundColor;
  final Color? barColor;
  final Color? titleColor;
  final double? topPadding;

  const CustomBottomSheetFrame({
    super.key,
    required this.title,
    required this.child,
    this.backgroundColor,
    this.barColor,
    this.titleColor,
    this.topPadding,
  });

  @override
  State<CustomBottomSheetFrame> createState() => _CustomBottomSheetFrameState();
}

class _CustomBottomSheetFrameState extends State<CustomBottomSheetFrame> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      width: double.infinity,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              CustomBottomSheetHeader(
                title: widget.title,
                titleColor: widget.titleColor,
                barColor: widget.barColor,
              ),
              SizedBox(height: widget.topPadding ?? 40),
              widget.child,
            ],
          )
        ],
      ),
    );
  }
}
