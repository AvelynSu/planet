import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:planet/ui/common/skeleton.dart';

class CustomNetworkImage extends StatefulWidget {
  final BoxFit boxFit;
  final double? size;
  final String? previewUrl;
  final String? url;
  final double? radius;
  final Alignment? alignment;
  final Color? color;
  final Widget? body;

  const CustomNetworkImage({
    super.key,
    this.size,
    this.boxFit = BoxFit.cover,
    this.radius,
    this.alignment,
    this.previewUrl,
    required this.url,
    this.color,
    this.body,
  });

  @override
  State<CustomNetworkImage> createState() => _CustomNetworkImageState();
}

class _CustomNetworkImageState extends State<CustomNetworkImage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius ?? 0),
          ),
          width: widget.size ?? double.infinity,
          height: widget.size ?? double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              (widget.url == null && widget.previewUrl != null)
                  ? Skeleton(
                      width: widget.size ?? double.infinity,
                      height: widget.size ?? double.infinity,
                    )
                  : SizedBox(
                      width: widget.size ?? double.infinity,
                      height: widget.size ?? double.infinity,
                    ),
              if ((widget.url ?? "").isNotEmpty)
                CachedNetworkImage(
                  imageUrl: widget.url ?? "",
                  alignment: widget.alignment ?? Alignment.topCenter,
                  fit: widget.boxFit,
                  width: widget.size ?? double.infinity,
                  height: widget.size ?? double.infinity,
                ),
            ],
          ),
        ),
        if (widget.body != null || widget.color != null)
          Container(
            color: widget.color ?? Colors.transparent,
            width: widget.size ?? double.infinity,
            height: widget.size ?? double.infinity,
          ),
        if (widget.body != null) widget.body!
      ],
    );
  }
}
