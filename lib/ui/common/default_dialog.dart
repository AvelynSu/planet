import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../custom_theme.dart';
import '../util/bold_generator.dart';

class DefaultDialog extends StatefulWidget {
  final String? iconPath;
  final String? title;
  final String? description;
  final Color? descriptionColor;
  final String? firstButtonLabel;
  final Color? firstButtonTextColor;
  final int? firstButtonFlex;
  final int? secondButtonFlex;
  final String? secondButtonLabel;
  final Function? onFirstAction;
  final Function? onSecondAction;
  final Widget? body;
  final Color? firstButtonColor;
  final Color? secondButtonColor;
  final bool hideButton;
  final Duration? duration;

  const DefaultDialog({
    super.key,
    this.iconPath,
    this.title,
    this.firstButtonFlex = 3,
    this.secondButtonFlex = 5,
    this.descriptionColor,
    this.description,
    this.firstButtonTextColor,
    this.body,
    this.onFirstAction,
    this.onSecondAction,
    this.firstButtonLabel,
    this.secondButtonLabel,
    this.firstButtonColor,
    this.secondButtonColor,
    this.hideButton = false,
    this.duration,
  });

  static show(
    BuildContext context, {
    String? title,
    String? iconPath,
    int? firstButtonFlex,
    int? secondButtonFlex,
    String? description,
    Color? firstButtonTextColor,
    Color? descriptionColor,
    Function? onSecondAction,
    Function? onFirstAction,
    Widget? body,
    String? firstButtonLabel,
    String? secondButtonLabel,
    Color? firstButtonColor,
    Color? secondButtonColor,
  }) async {
    return await showDialog(
      useSafeArea: false,
      context: context,
      builder: (_) => DefaultDialog(
        title: title,
        description: description,
        iconPath: iconPath,
        firstButtonFlex: firstButtonFlex,
        firstButtonTextColor: firstButtonTextColor,
        secondButtonFlex: secondButtonFlex,
        descriptionColor: descriptionColor,
        onSecondAction: onSecondAction,
        onFirstAction: onFirstAction,
        body: body,
        firstButtonLabel: firstButtonLabel,
        secondButtonLabel: secondButtonLabel,
        firstButtonColor: firstButtonColor,
        secondButtonColor: secondButtonColor,
      ),
    );
  }

  static showComingSoon(BuildContext context) {
    showTimerDialog(context, description: "Coming Soom..");
  }

  static showTimerDialog(
    BuildContext context, {
    String? title,
    String? description,
    Color? descriptionColor,
    Widget? body,
    Duration? duration,
  }) async {
    return await showDialog(
      useSafeArea: false,
      context: context,
      builder: (_) => DefaultDialog(
        title: title,
        description: description,
        descriptionColor: descriptionColor,
        hideButton: true,
        duration: duration,
      ),
    );
  }

  @override
  State<DefaultDialog> createState() => _DefaultDialogState();
}

class _DefaultDialogState extends State<DefaultDialog> {
  final double radius = 10.0;
  final double verticalPadding = 36.0;

  @override
  void initState() {
    super.initState();
    if (widget.hideButton) {
      Future.delayed(widget.duration ?? const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(minHeight: 140),
                padding: EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: widget.hideButton ? 16 : 32,
                    bottom: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.title != null)
                      AutoSizeText(
                        widget.title!,
                        style: fontSB(18, color: textPrimary900, height: 1.3),
                        textAlign: TextAlign.center,
                        maxLines: 10,
                      ),
                    if (widget.title != null && widget.description != null)
                      const SizedBox(height: 14),
                    if (widget.description != null)
                      BoldMsgGenerator.toRichText(
                        text: widget.description!,
                        maxLine: 10,
                        style: fontR(
                          15,
                          height: 1.5,
                          color: widget.descriptionColor ?? textTertiary600,
                        ),
                        textAlign: TextAlign.center,
                        boldStyle: fontB(
                          15,
                          height: 1.5,
                          color: widget.descriptionColor ??
                              const Color(0xff757575),
                        ),
                      ),
                    widget.body == null
                        ? Container()
                        : Container(
                            padding: const EdgeInsets.only(top: 12),
                            child: widget.body!,
                          ),
                  ],
                ),
              ),
              if (!widget.hideButton)
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _itemButton(
                          buttonColor: widget.firstButtonColor,
                          onTap: () async {
                            if (widget.onFirstAction != null) {
                              await widget.onFirstAction!();
                            }

                            Navigator.pop(context);
                          },
                          title: widget.firstButtonLabel ??
                              (widget.onSecondAction != null ? "취소" : "확인"),
                          textColor: b5,
                        ),
                      ),
                      if (widget.onSecondAction != null) SizedBox(width: 8),
                      if (widget.onSecondAction != null)
                        Expanded(
                          child: _itemButton(
                            buttonColor:
                                widget.secondButtonColor ?? fgDestructive,
                            onTap: () {
                              Navigator.pop(context, true);
                              widget.onSecondAction!();
                            },
                            title: widget.secondButtonLabel ?? "확인",
                            textColor: widget.secondButtonColor ?? Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _itemButton({
    required Function onTap,
    required String title,
    required Color? buttonColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
              color: buttonColor ?? textPlaceholder.withValues(alpha: 0.4)),
          color: buttonColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        height: 44,
        child: AutoSizeText(
          title,
          maxLines: 1,
          style: fontSB(16, color: textColor),
        ),
      ),
    );
  }
}
