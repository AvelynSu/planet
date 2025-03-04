import 'package:flutter/material.dart';
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
  final PinMode mode;
  final Function? onBack;

  const PinScreen({
    super.key,
    required this.onSuccess,
    this.mode = PinMode.validate,
    this.onBack,
  });

  static Future<bool?> push(
    BuildContext context, {
    required Function(bool) onSuccess,
    required PinMode mode,
    Function? onBack,
  }) async {
    return await AppUi.push(
        context,
        PinScreen(
          onSuccess: onSuccess,
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
    _updateGuideText();
  }

  void _updateGuideText() {
    switch (currentMode) {
      case PinMode.setup:
        guideText = "새로운 PIN 번호를 입력하세요";
        break;
      case PinMode.confirm:
        guideText = "PIN 번호를 다시 입력하세요";
        break;
      case PinMode.validate:
        guideText = "PIN 번호를 입력하세요";
        break;
    }
    setState(() {});
  }

  void _handlePinComplete() async {
    if (value.length == 6) {
      switch (currentMode) {
        case PinMode.setup:
          // 첫 번째 입력 저장 후 확인 모드로 전환
          firstPin = value;
          value = "";
          currentMode = PinMode.confirm;
          _updateGuideText();
          setState(() {});
          break;

        case PinMode.confirm:
          // 두 번째 입력값과 첫 번째 입력값 비교
          if (value == firstPin) {
            // 일치하면 성공 콜백 호출
            await SharedPrefsUtil.setString(AppConstant.pinCode, value);
            widget.onSuccess(true);
          } else {
            // 불일치하면 처음부터 다시
            setState(() {
              value = "";
              firstPin = null;
              currentMode = PinMode.setup;
              _updateGuideText();
              // 오류 메시지 표시
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("PIN 번호가 일치하지 않습니다. 다시 시도해주세요.")));
            });
          }
          break;

        case PinMode.validate:
          // 입력값과 정답 비교
          if (correctPin == value) {
            widget.onSuccess(true);
          } else {
            setState(() {
              value = "";
              // 오류 메시지 표시
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("잘못된 PIN 번호입니다. 다시 시도해주세요.")));
            });
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      guideText,
                      style: fontR(18, color: C.current.mainText),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "암호를 입력하세요",
                      style: fontM(14, color: C.current.sub01),
                    ),
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// 핀번호 부분
                        ...List.generate(6, (e) {
                          String label = value.length > e ? "${value[e]}" : "";
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  C.current.onBackground.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: e == value.length
                                    ? primary
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              label,
                              style: fontR(16, color: C.current.mainText),
                            ),
                          );
                        })
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
            )
          ],
        ),
      ),
    );
  }
}
