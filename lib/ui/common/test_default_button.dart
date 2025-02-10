import 'package:flutter/material.dart';
import 'package:planet/custom_theme.dart';

class TestDefaultButton extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const TestDefaultButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  State<TestDefaultButton> createState() => _TestDefaultButtonState();
}

class _TestDefaultButtonState extends State<TestDefaultButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: CustomColors.current.buttonBackground,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: widget.onTap,
        child: Container(
          alignment: Alignment.center,
          height: 52,
          width: double.infinity,
          decoration: BoxDecoration(
            color: CustomColors.current.buttonBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CustomColors.current.text,
            ),
          ),
        ),
      ),
    );
  }
}
