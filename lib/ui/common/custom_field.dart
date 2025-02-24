import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../custom_theme.dart';
import '../transaction/transfer/select_friend/friend_search_field.dart';
import 'custom_image.dart';

class CustomField extends StatefulWidget {
  final TextEditingController? controller;
  final List<TextInputFormatter> inputFormatters;
  final double? horizontalPadding;
  final TextInputType keyboardType;
  final String? title;
  final double? titleWidth;
  final String? initialValue;
  final String? hintText;
  final Function(String text)? onChange;
  final bool? autoFocus;
  final int? maxLine;
  final bool expands;
  final Color? borderColor;
  final String? guideMsg;
  final Color guideMsgColor;
  final bool obscureText;
  final Widget? suffix;
  final TextStyle? textStyle;
  final String? buttonTitle;
  final Function? onButtonTap;
  final double? buttonSize;
  final EdgeInsets? padding;
  final Color? cursorColor;
  final Color? backgroundColor;
  final int? maxLength;
  final double? height;

  const CustomField({
    super.key,
    this.height,
    this.controller,
    this.padding,
    this.textStyle,
    this.titleWidth,
    this.inputFormatters = const [],
    this.obscureText = false,
    this.title,
    this.horizontalPadding,
    this.keyboardType = TextInputType.text,
    this.initialValue = '',
    this.hintText,
    this.onChange,
    this.autoFocus,
    this.expands = false,
    this.maxLine,
    this.borderColor,
    this.guideMsg,
    this.guideMsgColor = Colors.red,
    this.suffix,
    this.buttonTitle,
    this.onButtonTap,
    this.buttonSize,
    this.cursorColor,
    this.backgroundColor,
    this.maxLength,
  });

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  late TextEditingController _controller;
  late FocusNode focusNode;

  bool hidePassword = false;

  @override
  void initState() {
    hidePassword = widget.obscureText;
    focusNode = FocusNode();
    focusNode.addListener(_onFocusChange);
    _controller =
        (widget.controller ?? TextEditingController(text: widget.initialValue))
          ..addListener(() {
            setState(() {});
          });

    super.initState();
  }

  bool onFocus = false;

  void _onFocusChange() {
    onFocus = focusNode.hasFocus;
    setState(() {});
  }

  @override
  void dispose() {
    focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  var text = '';

  @override
  Widget build(BuildContext context) {
    var borderSide = const BorderSide(
      width: 1,
      color: Colors.transparent,
      style: BorderStyle.solid,
    );
    var focusSide = borderSide.copyWith(
      color: Colors.transparent,
      width: 1,
    );
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: borderSide,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.title!,
                  style: fontM(14, color: b5),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.borderColor ??
                      C.current.sub01.withValues(alpha: 0.5),
                ),
              ),
              child: Row(children: [
                Expanded(
                  child: SizedBox(
                    height: widget.maxLine == null ? widget.height ?? 40 : null,
                    child: TextFormField(
                      selectionControls: CustomColorSelectionHandle(primary),
                      keyboardAppearance: Brightness.dark,
                      obscureText: hidePassword,
                      obscuringCharacter: '*',
                      keyboardType: widget.keyboardType,
                      autofocus: widget.autoFocus ?? false,
                      focusNode: focusNode,
                      maxLength: widget.maxLength,
                      maxLines: widget.obscureText ? 1 : widget.maxLine,
                      expands: widget.expands,
                      controller: _controller,
                      textAlign: TextAlign.left,
                      style: widget.textStyle ??
                          fontR(16, height: 1.3, color: C.current.mainText),
                      cursorColor: widget.cursorColor ?? b5,
                      onChanged: (text) {
                        this.text = text;
                        if (widget.onChange != null) {
                          widget.onChange!(text);
                        }
                        setState(() {});
                      },
                      inputFormatters: widget.inputFormatters,
                      decoration: InputDecoration(
                        fillColor: widget.backgroundColor,
                        filled: widget.backgroundColor != null,
                        counterText: '',
                        hintText: widget.hintText ?? '',
                        hintStyle: widget.textStyle
                                ?.copyWith(color: C.current.sub01) ??
                            fontR(16, color: C.current.sub01),
                        contentPadding: widget.padding ??
                            EdgeInsets.symmetric(
                              vertical: widget.maxLine != null ? 12 : 0,
                              horizontal: widget.horizontalPadding ?? 12,
                            ),
                        disabledBorder: border,
                        enabledBorder: border,
                        focusedBorder: border,
                      ),
                    ),
                  ),
                ),
                if (widget.suffix != null) widget.suffix!,
                if (widget.obscureText)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: CustomImage(
                        path: !hidePassword
                            ? 'icons/ic_eye_open.svg'
                            : 'icons/ic_eye_close.svg',
                      ),
                    ),
                  ),
              ]),
            ),
          ],
        ),
        if ((widget.guideMsg ?? '').isNotEmpty)
          Container(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.guideMsg!,
              style: fontR(11, color: widget.guideMsgColor, height: 1.3),
            ),
          ),
      ],
    );
  }
}
