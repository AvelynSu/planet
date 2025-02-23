import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../custom_theme.dart';
import '../../util/bold_generator.dart';
import 'custom_image.dart';

class LinedField extends StatefulWidget {
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final String? title;
  final String? initialValue;
  final String? hintText;
  final TextStyle? style;
  final Function(String text)? onChange;
  final bool? autoFocus;
  final int? maxLine;
  final Color? borderColor;
  final Color? hintBorderColor;
  final Widget? suffix;
  final int? maxLength;
  final TextAlign? align;
  final bool showCancelButton;

  const LinedField({
    super.key,
    this.controller,
    this.inputFormatters = const [],
    this.maxLength,
    this.focusNode,
    this.title,
    this.style,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.initialValue = "",
    this.hintText,
    this.onChange,
    this.autoFocus,
    this.maxLine,
    this.borderColor,
    this.hintBorderColor,
    this.align,
    this.showCancelButton = false,
  });

  @override
  State<LinedField> createState() => _LinedFieldState();
}

class _LinedFieldState extends State<LinedField> {
  late TextEditingController _controller;
  late FocusNode focusNode;

  @override
  void initState() {
    text = widget.initialValue ?? "";
    focusNode = widget.focusNode ?? FocusNode();
    focusNode.addListener(_onFocusChange);
    _controller =
        (widget.controller ?? TextEditingController(text: widget.initialValue))
          ..addListener(() {
            text = _controller.text;
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

  var text = "";

  @override
  Widget build(BuildContext context) {
    var border = UnderlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(
        width: 1,
        color: Colors.transparent,
        style: BorderStyle.solid,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.title!,
              style: fontM(14, color: textSecondary),
            ),
          ),

        Row(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  /// 힌트 텍스트
                  if (widget.hintText != null)
                    Opacity(
                      opacity: text.isEmpty ? 1 : 0,
                      child: Container(
                        color: Colors.transparent,
                        width: double.infinity,
                        child: BoldMsgGenerator.toRichText(
                          text: widget.hintText!,
                          textAlign: widget.align ?? TextAlign.left,
                          style: fontR(widget.style?.fontSize ?? 16,
                              color: textPlaceholder),
                          boldStyle: fontB(widget.style?.fontSize ?? 16,
                              color: textPlaceholder),
                        ),
                      ),
                    ),

                  /// 텍스트 필드
                  TextFormField(
                    maxLength: widget.maxLength,
                    keyboardAppearance: Brightness.dark,
                    keyboardType: widget.keyboardType,
                    textAlign: widget.align ?? TextAlign.right,
                    autofocus: widget.autoFocus ?? false,
                    focusNode: focusNode,
                    maxLines: widget.maxLine ?? 1,
                    controller: _controller,
                    style: widget.style?.copyWith(height: 1.3) ??
                        fontR(16, color: primary, height: 1.3),
                    cursorColor: primary,
                    onChanged: (text) {
                      this.text = text;

                      if (widget.onChange != null) {
                        widget.onChange!(text);
                      }
                      setState(() {});
                    },
                    inputFormatters: widget.inputFormatters,
                    decoration: InputDecoration(
                      counterText: "",
                      hintStyle: fontR(16,
                          color: Colors.white.withValues(alpha: 0.5),
                          height: 1.3),
                      disabledBorder: border,
                      enabledBorder: border,
                      focusedBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          width: 1,
                          color: Colors.transparent,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (text.isNotEmpty && widget.showCancelButton)
              Container(
                padding: const EdgeInsets.only(left: 8),
                child: CustomImage(
                  onTap: () {
                    _controller.clear();
                    text = "";
                    setState(() {});
                  },
                  path: "icons/ic_textfield_cancel.svg",
                  width: 20,
                ),
              ),
            if (widget.suffix != null)
              Container(
                padding: const EdgeInsets.only(left: 8),
                child: widget.suffix!,
              ),
          ],
        ),

        /// 언더라인
        Transform.translate(
          offset: const Offset(0, -5),
          child: Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.hintBorderColor ?? textPlaceholder.withOpacity(0.5),
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: onFocus
                  ? (text.isEmpty
                      ? 0
                      : (text.length / (widget.maxLength ?? 20)) *
                          MediaQuery.of(context).size.width)
                  : (text.isEmpty
                      ? 0
                      : (text.length / (widget.maxLength ?? 20)) *
                          MediaQuery.of(context).size.width),
              decoration: BoxDecoration(
                color: widget.borderColor ?? primary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
