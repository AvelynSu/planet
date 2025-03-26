import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/ui/common/custom_image.dart';

class FriendSearchField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChange;
  final String initialValue;

  const FriendSearchField({
    super.key,
    required this.controller,
    required this.onChange,
    required this.initialValue,
  });

  @override
  State<FriendSearchField> createState() => _FriendSearchFieldState();
}

class _FriendSearchFieldState extends State<FriendSearchField> {
  @override
  Widget build(BuildContext context) {
    var borderSide = const BorderSide(
      width: 1,
      color: Colors.transparent,
      style: BorderStyle.solid,
    );

    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: borderSide,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      height: 56,
      decoration: BoxDecoration(
        color: C.current.sub02,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        CustomImage(path: "icons/ic_search.svg"),
        Expanded(
          child: SizedBox(
            // height: widget.maxLine == null ? widget.height ?? 40 : null,
            child: TextFormField(
              controller: widget.controller,
              keyboardAppearance: Brightness.dark,
              textAlign: TextAlign.left,
              style: fontR(16, height: 1.3, color: C.current.mainText),
              selectionControls: CustomColorSelectionHandle(primary),
              cursorColor: primary,
              onChanged: (text) {
                widget.onChange(text);
                setState(() {});
              },
              decoration: InputDecoration(
                // fillColor: widget.backgroundColor,
                // filled: widget.backgroundColor != null,
                counterText: '',
                hintText:
                    AppLocalizations.of(context)?.search_address_hint ?? '',
                hintStyle: fontR(16, color: C.current.sub01),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                disabledBorder: border,
                enabledBorder: border,
                focusedBorder: border,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final data = await Clipboard.getData('text/plain');
            if (data?.text != null) {
              widget.controller.text = data!.text ?? "";
              widget.onChange(data.text ?? "");
              setState(() {});
            }
          },
          child: CustomImage(
            path: "icons/ic_copy.svg",
            color: C.current.primary,
            width: 32,
          ),
        ),
      ]),
    );
  }
}

class CustomColorSelectionHandle extends TextSelectionControls {
  CustomColorSelectionHandle(this.handleColor)
      : _controls = kIsWeb
            ? materialTextSelectionControls // 웹에서는 기본적으로 Material 스타일 사용
            : Platform.isIOS
                ? cupertinoTextSelectionControls
                : materialTextSelectionControls;

  final Color handleColor;
  final TextSelectionControls _controls;

  /// Wrap the given handle builder with the needed theme data for
  /// each platform to modify the color.
  Widget _wrapWithThemeData(Widget Function(BuildContext) builder) {
    if (kIsWeb) {
      // 웹에서는 Material 테마 사용
      return TextSelectionTheme(
        data: TextSelectionThemeData(selectionHandleColor: handleColor),
        child: Builder(builder: builder),
      );
    } else if (Platform.isIOS) {
      // iOS 테마
      return CupertinoTheme(
        data: CupertinoThemeData(primaryColor: handleColor),
        child: Builder(builder: builder),
      );
    } else {
      // 기타 플랫폼 (Android 등)
      return TextSelectionTheme(
        data: TextSelectionThemeData(selectionHandleColor: handleColor),
        child: Builder(builder: builder),
      );
    }
  }

  @override
  Widget buildHandle(BuildContext context, TextSelectionHandleType type,
          double textLineHeight, [VoidCallback? onTap]) =>
      _wrapWithThemeData((BuildContext context) =>
          _controls.buildHandle(context, type, textLineHeight, onTap));

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    return _controls.getHandleAnchor(type, textLineHeight);
  }

  @override
  Size getHandleSize(double textLineHeight) {
    return _controls.getHandleSize(textLineHeight);
  }

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ValueListenable<ClipboardStatus>? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return _controls.buildToolbar(
        context,
        globalEditableRegion,
        textLineHeight,
        selectionMidpoint,
        endpoints,
        delegate,
        clipboardStatus,
        lastSecondaryTapDownPosition);
  }
}
