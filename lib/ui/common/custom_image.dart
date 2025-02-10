import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomImage extends StatelessWidget {
  final Function? onTap;
  final String path;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit? boxFit;
  final Alignment? alignment;
  final double? padding;
  final double? rotate;

  CustomImage({
    super.key,
    required this.path,
    this.onTap,
    this.padding,
    this.width,
    this.height,
    this.color,
    this.boxFit,
    this.alignment,
    this.rotate,
  }) : assert(path.contains('.svg') ||
            path.contains('.png') ||
            path.contains('.jpeg'));

  bool get _hasWidth => width != null;

  bool get _hasHeight => height != null;

  bool get _isSquare {
    return (_hasWidth && !_hasHeight) || (!_hasWidth && _hasHeight);
  }

  double? get _width {
    if (width == 0) {
      return null;
    }
    if (_isSquare) {
      return width ?? height ?? 24;
    } else {
      return _hasWidth ? width! : 24;
    }
  }

  double? get _height {
    if (height == 0) {
      return null;
    }
    if (_isSquare) {
      return width ?? height ?? 24;
    } else {
      return _hasHeight ? height! : 24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotate ?? 0,
      child: InkResponse(
        highlightColor: Colors.white.withOpacity(0.1),
        splashColor: Colors.white.withOpacity(0.1),
        onTap: onTap != null
            ? () async {
                onTap!();
              }
            : null,
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          padding: EdgeInsets.all(padding ?? 0),
          child: Container(
            color: Colors.white.withOpacity(0),
            alignment: alignment,
            width: _width,
            height: _height,
            child: path.contains('.svg')
                ? SvgPicture.asset(
                    'assets/$path',
                    fit: boxFit ?? BoxFit.contain,
                    color: color,
                    width: _width,
                    height: _height,
                  )
                : Image.asset(
                    'assets/$path',
                    fit: boxFit ?? BoxFit.contain,
                    color: color,
                  ),
          ),
        ),
      ),
    );
  }
}
