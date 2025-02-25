import 'package:flutter/material.dart';

import '../../custom_theme.dart';

void showTopSheet(BuildContext context, Widget child) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation1, animation2) {
      return DraggableTopSheet(
        child: child,
      );
    },
  );
}

class DraggableTopSheet extends StatefulWidget {
  final Widget child;

  const DraggableTopSheet({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _DraggableTopSheetState createState() => _DraggableTopSheetState();
}

class _DraggableTopSheetState extends State<DraggableTopSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  // 현재 시트의 위치를 추적
  double _sheetOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      // 위로 드래그할 때만 반응
      if (details.delta.dy < 0) {
        _sheetOffset += details.delta.dy;
        // 너무 많이 올라가는 것 제한
        _sheetOffset =
            _sheetOffset.clamp(-MediaQuery.of(context).size.height, 0.0);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final threshold = -80.0; // 닫힘 임계값

    if (_sheetOffset < threshold) {
      // 닫는 애니메이션 (현재 위치에서 위로 사라지게)
      final screenHeight = MediaQuery.of(context).size.height;
      final startOffset = _sheetOffset / screenHeight;

      final animation = Tween<Offset>(
        begin: Offset(0, startOffset),
        end: const Offset(0, -1),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));

      setState(() {
        _offsetAnimation = animation;
      });

      _controller.reset();
      _controller.forward().then((_) {
        Navigator.of(context).pop();
      });
    } else {
      // 원래 위치로 복귀
      final animation = Tween<Offset>(
        begin: Offset(0, _sheetOffset / MediaQuery.of(context).size.height),
        end: const Offset(0, 0),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));

      setState(() {
        _offsetAnimation = animation;
        _sheetOffset = 0;
      });

      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 드래그 중일 때는 수동 오프셋, 애니메이션 중일 때는 애니메이션 값
        final currentOffset = _sheetOffset != 0
            ? Offset(0, _sheetOffset / MediaQuery.of(context).size.height)
            : _offsetAnimation.value;

        return SlideTransition(
          position: AlwaysStoppedAnimation(currentOffset),
          child: Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onVerticalDragUpdate: _onPanUpdate,
              onVerticalDragEnd: _onPanEnd,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 12,
                      right: 12),
                  decoration: BoxDecoration(
                    color: C.current.lightBase,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.child,
                      // 드래그 핸들 추가
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: C.current.sub01,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
