import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/enum/screen_status.dart';
import 'package:planet/model/custom_exception.dart';
import 'package:planet/ui/common/custom_image.dart';
import 'package:planet/ui/common/plannet_background_frame.dart';

import '../../custom_theme.dart';
import 'base_scaffold.dart';
import 'generate_planet.dart';
import 'line_text_field.dart';
import 'set_nickname_button.dart';

class PlanetNicknameFrame extends StatefulWidget {
  final ScreenStatus status;
  final CustomException exception;
  final String nickname;
  final String? title;
  final Function(String) onUpdateValue;
  final Function onComplete;
  final NetworkType? network;
  final Function? onChangeNetwork;

  const PlanetNicknameFrame({
    super.key,
    this.title,
    required this.status,
    required this.exception,
    required this.nickname,
    required this.onUpdateValue,
    required this.onComplete,
    this.network,
    this.onChangeNetwork,
  });

  @override
  State<PlanetNicknameFrame> createState() => _PlanetNicknameFrameState();
}

class _PlanetNicknameFrameState extends State<PlanetNicknameFrame> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.nickname);
  }

  @override
  Widget build(BuildContext context) {
    var errorMsg = "";

    if (widget.exception.errType == ExceptionType.planetNameDuplicate) {
      errorMsg = AppLocalizations.of(context)!.planet_name_duplicate;
    }

    return BaseScaffold(
      isTransparentAppbar: true,
      title: widget.title,
      titleWidget: widget.network != null
          ? GestureDetector(
              onTap: () {
                widget.onChangeNetwork!();
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: C.current.sub02,
                  borderRadius: BorderRadius.circular(100),
                  border:
                      Border.all(color: C.current.sub01.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomImage(path: widget.network!.icon),
                    SizedBox(width: 4),
                    Text(
                      widget.network!.title,
                      style: fontR(14, color: C.current.mainText),
                    ),
                  ],
                ),
              ),
            )
          : null,
      onBack: () {
        Navigator.pop(context);
      },
      onLoading: widget.status == ScreenStatus.loading,
      body: PlanetBackgroundFrame(
        data: widget.nickname,
        scale: 3.8,
        topPadding: 80,
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SingleChildScrollView(
            child: widget.status != ScreenStatus.initial
                ? Column(
                    children: [
                      const SizedBox(height: 150),
                      Text(
                        AppLocalizations.of(context)!.planet_name_display,
                        style:
                            fontB(28, color: C.current.mainText, isIalic: true),
                      ),
                      const SizedBox(height: 12),
                      LinedField(
                        hintBorderColor: Colors.transparent,
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final lowerCaseText = newValue.text.toLowerCase();
                            final regExp = RegExp(r'^[a-z0-9._]*$');

                            if (regExp.hasMatch(lowerCaseText)) {
                              return TextEditingValue(
                                text: lowerCaseText,
                                selection: newValue.selection,
                              );
                            }
                            return oldValue;
                          }),
                        ],
                        controller: _controller,
                        initialValue: widget.nickname,
                        hintText:
                            AppLocalizations.of(context)!.planet_name_enter,
                        align: TextAlign.center,
                        style: fontR(22, color: primary),
                        onChange: (value) {
                          widget.onUpdateValue(value);
                        },
                      ),
                      if (widget.status != ScreenStatus.fail)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          child: Text(
                            AppLocalizations.of(context)!
                                .planet_name_change_info,
                            style: fontR(14, color: C.current.sub01),
                          ),
                        ),
                      if (widget.status == ScreenStatus.fail)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          child: Text(
                            errorMsg,
                            style: fontR(14, color: primary),
                          ),
                        ),
                      const SizedBox(height: 100),
                      PlanetComponent(
                        data: widget.nickname,
                        size: 200,
                      ),
                      const SizedBox(height: 80),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SetNicknameButton(
                            onTap: () {
                              RegExp regex = RegExp(r'\d+$');
                              String baseText = widget.nickname;

                              if (regex.hasMatch(baseText)) {
                                baseText = baseText.replaceAll(regex, '');
                              }

                              String updateNickname =
                                  "$baseText${Random().nextInt(2000) + 1}";
                              widget.onUpdateValue(updateNickname);
                              _controller.text = updateNickname;
                              setState(() {});
                            },
                            iconPath: "icons/ic_refresh.svg",
                          ),
                          const SizedBox(width: 30),
                          SetNicknameButton(
                            onTap: () {
                              widget.onComplete();
                            },
                            iconPath: "icons/ic_check.svg",
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                    ],
                  )
                : Container(),
          ),
        ),
      ),
    );
  }
}
