import 'package:flutter/material.dart';
import 'package:planet/ui/common/bounce_button.dart';

import '../../../../custom_theme.dart';
import '../../../../util/app_ui.dart';
import '../../../common/custom_image.dart';

class CustomNumberKeyPad extends StatefulWidget {
  final String initialValue;
  final Function(String) onUpdateValue;
  final bool enableDot;

  const CustomNumberKeyPad({
    super.key,
    required this.initialValue,
    required this.onUpdateValue,
    this.enableDot = true,
  });

  @override
  State<CustomNumberKeyPad> createState() => _CustomNumberKeyPadState();
}

class _CustomNumberKeyPadState extends State<CustomNumberKeyPad> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: C.current.sub02,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _button(value: "1"),
                _button(value: "2"),
                _button(value: "3"),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _button(value: "4"),
                _button(value: "5"),
                _button(value: "6"),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _button(value: "7"),
                _button(value: "8"),
                _button(value: "9"),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _button(value: widget.enableDot ? "." : ""),
                _button(value: "0"),
                _button(value: "delete"),
              ],
            ),
          ),
          SizedBox(
            height: AppUi.bottomPadding(context),
          ),
        ],
      ),
    );
  }

  _button({required String value}) {
    Widget body = Container();
    switch (value) {
      case "delete":
        body = CustomImage(
          path: "icons/ic_keypad_delete.svg",
          width: 40,
        );
        break;
      default:
        body = Text(
          value,
          style: fontR(28, color: C.current.mainText),
        );
        break;
    }

    return Expanded(
      child: BounceButton(
        onTap: () {
          var password = widget.initialValue;
          if (value == "delete") {
            if (password.isNotEmpty) {
              password = password.substring(0, password.length - 1);
            }
          } else if (value == ".") {
            // 아직 소수점이 없는 경우에만 소수점 추가
            if (!password.contains(".")) {
              // 아직 아무 숫자도 입력되지 않았으면 '0.'으로 시작
              if (password.isEmpty) {
                password = "0.";
              } else {
                password = "$password.";
              }
            }
          } else if (value.isNotEmpty) {
            password = password + value;
          }

          widget.onUpdateValue(password);
        },
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: body,
        ),
      ),
    );
  }
}
