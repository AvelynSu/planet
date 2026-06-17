import 'package:flutter/material.dart';
import 'package:planet/l10n/app_localizations.dart';
import 'package:planet/service/local_storage_service.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/transaction/transfer/transfer_amount_input/custom_number_keypad.dart';
import 'package:planet/util/app_constant.dart';

import '../custom_theme.dart';
import '../util/app_ui.dart';

enum PinMode {
  setup, // 핀번호 처음 설정
  confirm, // 핀번호 확인 (setup 의 연장)
  validate // 핀번호 검증
}

class PinScreen extends StatefulWidget {
  final Function(bool) onSuccess;
  final bool enableSuccessPop;
  final PinMode mode;
  final Function? onBack;

  const PinScreen({
    super.key,
    required this.onSuccess,
    this.enableSuccessPop = false,
    this.mode = PinMode.validate,
    this.onBack,
  });

  static Future<bool?> push(
    BuildContext context, {
    required Function(bool) onSuccess,
    bool enableSuccessPop = false,
    required PinMode mode,
    Function? onBack,
  }) async {
    return await AppUi.push(
        context,
        PinScreen(
          onSuccess: onSuccess,
          enableSuccessPop: enableSuccessPop,
          onBack: onBack,
          mode: mode,
        ));
  }

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String correctPin = "";
  String value = "";
  String? firstPin; // setup 모드에서 첫 번째 입력값 저장
  late PinMode currentMode;
  String guideText = "";

  @override
  void initState() {
    super.initState();
    correctPin = SharedPrefsUtil.getString(AppConstant.pinCode) ?? "";
    currentMode = widget.mode;
  }

  void _handlePinComplete() async {
    if (value.length == 6) {
      switch (currentMode) {
        case PinMode.setup:
          // 첫 번째 입력 저장 후 확인 모드로 전환
          firstPin = value;
          value = "";
          currentMode = PinMode.confirm;
          setState(() {});
          break;

        case PinMode.confirm:
          // 두 번째 입력값과 첫 번째 입력값 비교
          if (value == firstPin) {
            // 일치하면 성공 콜백 호출
            await SharedPrefsUtil.setString(AppConstant.pinCode, value);
            widget.onSuccess(true);
            if (widget.enableSuccessPop) {
              Navigator.pop(context, true);
            }
          } else {
            // 불일치하면 처음부터 다시
            setState(() {
              value = "";
              firstPin = null;
              currentMode = PinMode.setup;
              // 오류 메시지 표시
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text(AppLocalizations.of(context)?.pin_not_match ?? '')));
            });
          }
          break;

        case PinMode.validate:
          // 입력값과 정답 비교
          if (correctPin == value) {
            widget.onSuccess(true);
            if (widget.enableSuccessPop) {
              Navigator.pop(context, true);
            }
          } else {
            setState(() {
              value = "";
              // 오류 메시지 표시
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text(AppLocalizations.of(context)?.pin_incorrect ?? '')));
            });
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (currentMode) {
      case PinMode.setup:
        guideText = AppLocalizations.of(context)?.pin_new ?? '';
        break;
      case PinMode.confirm:
        guideText = AppLocalizations.of(context)?.pin_reenter ?? '';
        break;
      case PinMode.validate:
        guideText = AppLocalizations.of(context)?.pin_enter ?? '';
        break;
    }

    return BaseScaffold(
      onBack: widget.onBack != null
          ? () {
              widget.onBack!();
            }
          : null,
      isTransparentAppbar: true,
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: widget.onBack != null
                    ? null
                    : EdgeInsets.only(
                        top: AppUi.statusBarHeight(context),
                      ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      guideText,
                      style: fontR(18, color: C.current.mainText),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)?.pin_passcode ?? '',
                      style: fontM(14, color: C.current.sub01),
                    ),
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// 핀번호 부분
                        ...List.generate(
                          6,
                          (e) {
                            String label = value.length > e ? value[e] : "";
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: C.current.onBackground
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: e == value.length
                                      ? primary
                                      : Colors.transparent,
                                ),
                              ),
                              child: e < value.length
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: C.current.mainText,
                                      ),
                                      width: 8,
                                      height: 8,
                                    )
                                  : Text(
                                      label,
                                      style:
                                          fontR(16, color: C.current.mainText),
                                    ),
                            );
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 370,
              child: CustomNumberKeyPad(
                enableDot: false,
                initialValue: value,
                onUpdateValue: (newValue) {
                  if (newValue.length <= 6) {
                    setState(() {
                      value = newValue;
                    });

                    // 6자리 입력 완료시 자동으로 처리
                    if (newValue.length == 6) {
                      _handlePinComplete();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
