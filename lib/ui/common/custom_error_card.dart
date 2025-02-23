import 'package:flutter/material.dart';

import '../../custom_theme.dart';

class CustomErrorCard extends StatelessWidget {
  final String iconPath;
  final String title;

  const CustomErrorCard({
    super.key,
    required this.iconPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: fontR(14, color: Colors.red.shade700, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
