import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class BounceButton extends StatefulWidget {
  final Widget child;
  final Function onTap;
  final double scale;
  final bool hasHaptic;

  const BounceButton({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.03,
    this.hasHaptic = true,
  });

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: widget.scale,
    );
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapDown: (_) {
        if (widget.hasHaptic) {
          HapticFeedback.lightImpact();
        }
        _controller.forward();
      },
      onTapUp: (_) async {
        _controller.reverse();

        // await Future.delayed(const Duration(milliseconds: 100));
        widget.onTap();
      },
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
