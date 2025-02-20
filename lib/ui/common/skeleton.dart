import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../custom_theme.dart';

class Skeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final double? r;

  const Skeleton({
    this.width,
    this.height,
    this.r,
  });

  static Widget get homeTile {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 12,
        horizontal: hPadding,
      ),
      child: const Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Skeleton(width: 20, height: 20, r: 4),
                const SizedBox(width: 8),
                Skeleton(width: 40, height: 15, r: 4),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Skeleton(width: 160, height: 16, r: 4),
              const SizedBox(height: 4),
              Skeleton(width: 100, height: 16, r: 4),
            ],
          )
        ],
      ),
    );
  }

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: C.current.lightBase,
      highlightColor: C.current.lightBase.withValues(alpha: 0.5),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.r ?? 6),
          color: C.current.lightBase,
        ),
      ),
    );
  }
}
