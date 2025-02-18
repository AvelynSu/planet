import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../custom_theme.dart';

class Skeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final double? radius;

  Skeleton({
    this.width,
    this.height,
    this.radius,
  });

  @override
  _SkeletonState createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: C.current.lightBase,
      highlightColor: Colors.white,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius ?? 6),
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
    );
  }
}
