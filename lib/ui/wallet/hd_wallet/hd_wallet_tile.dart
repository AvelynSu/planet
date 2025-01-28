import 'package:flutter/material.dart';

import '../../../custom_theme.dart';
import '../../../generate_planet/generate_planet.dart';

class HdWalletTile extends StatelessWidget {
  final String address;

  const HdWalletTile({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          PlanetWidget(
            data: address,
            size: 50,
          ),
          const SizedBox(height: 24),
          Text(
            address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: fontR(12,
                color: CustomColors.current.text.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}
