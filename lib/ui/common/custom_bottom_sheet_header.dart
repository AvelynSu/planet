import 'package:flutter/material.dart';

import '../../custom_theme.dart';

class CustomBottomSheetHeader extends StatefulWidget {
  final String title;

  const CustomBottomSheetHeader({
    super.key,
    required this.title,
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
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xffEDEDED)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Container(
            height: 4,
            width: 35,
            decoration: BoxDecoration(
              color: const Color(0xffCCCCCC),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                widget.title,
                style: fontM(18, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
