import 'package:flutter/material.dart';

import '../../custom_theme.dart';

class CustomToggle extends StatefulWidget {
  final String? label;
  final bool value;

  const CustomToggle({
    super.key,
    this.label,
    required this.value,
  });

  @override
  State<CustomToggle> createState() => _CustomToggleState();
}

class _CustomToggleState extends State<CustomToggle> {
  final Duration animationDuration = const Duration(milliseconds: 200);

  final double width = 48;
  final double height = 28;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              AnimatedContainer(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                width: width,
                height: height,
                duration: animationDuration,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: widget.value ? primary : Colors.transparent,
                  border: Border.all(
                    color: widget.value ? primary.withOpacity(0.5) : b5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        // child: Text(
                        //   'OFF',
                        //   textAlign: TextAlign.center,
                        //   style: caption02.copyWith(color: Colors.white),
                        // ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        // child: Text(
                        //   'ON',
                        //   textAlign: TextAlign.center,
                        //   style: caption02.copyWith(color: Colors.white),
                        // ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  AnimatedContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    width: width,
                    height: height,
                    duration: animationDuration,
                    alignment: widget.value
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: animationDuration,
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: widget.value
                            ? Colors.white
                            : const Color(0xff757575),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      alignment: Alignment.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.label != null)
          Container(
            margin: EdgeInsets.only(left: 8),
            child: Text(
              widget.label ?? "",
              style: fontB(
                14,
                color: widget.value ? primary : C.current.sub01,
              ),
            ),
          ),
      ],
    );
  }
}
