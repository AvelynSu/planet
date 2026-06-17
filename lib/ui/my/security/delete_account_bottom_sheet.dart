import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/l10n/app_localizations.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/ui/common/custom_bottom_sheet_frame.dart';
import 'package:planet/ui/common/custom_error_card.dart';
import 'package:planet/ui/common/custom_toggle.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/common/mnemonic_pharse_component.dart';
import 'package:planet/util/app_ui.dart';

import '../../../custom_theme.dart';
import '../../common/default_dialog.dart';
import '../../common/small_round_button.dart';

class DeleteAccountBottomSheet extends StatefulWidget {
  final Function onSuccess;

  const DeleteAccountBottomSheet({
    super.key,
    required this.onSuccess,
  });

  static Future<bool> show(
    BuildContext context, {
    required Function onSuccess,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeleteAccountBottomSheet(
        onSuccess: onSuccess,
      ),
    );

    // 디버깅을 위한 로그 추가
    print('DeleteAccountBottomSheet result: $result');

    // null 체크 후 명시적으로 결과 반환
    return result ?? false;
  }

  @override
  State<DeleteAccountBottomSheet> createState() =>
      _DeleteAccountBottomSheetState();
}

class _DeleteAccountBottomSheetState extends State<DeleteAccountBottomSheet> {
  bool isCheck1 = false;
  bool isCheck2 = false;
  bool isCheck3 = false;

  bool get allChecked => isCheck1 && isCheck2 && isCheck3;

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppBloc>().state;
    var mnemonic = (appState is AppLoaded) ? appState.current.mnemonic : "";
    final localizations = AppLocalizations.of(context)!;

    // 화면 높이의 최대 85%까지 사용하도록 설정
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return CustomBottomSheetFrame(
      title: localizations.deleteAccount,
      topPadding: 0,
      backgroundColor: C.current.sub02,
      titleColor: C.current.mainText,
      barColor: C.current.sub01.withValues(alpha: 0.5),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight - 60, // 제목과 상단 바 높이를 고려하여 조정
        ),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomErrorCard(
                  iconPath: "icons/ic_warning.svg",
                  title: localizations.deleteAccountWarning,
                ),
                SizedBox(height: 24),
                Text(
                  localizations.mnemonicBackupTitle,
                  style: fontB(
                    16,
                    color: C.current.mainText,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  localizations.mnemonicBackupDescription,
                  style: fontR(
                    14,
                    color: C.current.mainText,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                MnemonicPharseComponent(
                  mnemonic: mnemonic,
                  padding: 0,
                ),
                SizedBox(height: 16),
                SmallRoundButton(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: mnemonic));
                    DefaultDialog.showTimerDialog(context,
                        description: localizations.success_copy ?? "복사되었습니다",
                        duration: Duration(seconds: 1));
                  },
                  iconPath: "icons/ic_copy.svg",
                  title: localizations.copyMnemonic,
                ),
                SizedBox(height: 24),
                Divider(color: C.current.sub01),
                SizedBox(height: 24),

                // 확인 체크리스트
                _buildCheckItem(
                  context,
                  localizations.deleteAccountCheck1,
                  isCheck1,
                  (value) {
                    setState(() {
                      isCheck1 = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                _buildCheckItem(
                  context,
                  localizations.deleteAccountCheck2,
                  isCheck2,
                  (value) {
                    setState(() {
                      isCheck2 = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                _buildCheckItem(
                  context,
                  localizations.deleteAccountCheck3,
                  isCheck3,
                  (value) {
                    setState(() {
                      isCheck3 = value;
                    });
                  },
                ),
                SizedBox(height: 32),

                // 계정 삭제 버튼
                DefaultButton(
                  title: localizations.deleteAccountButton,
                  color: primary,
                  textColor: Colors.white,
                  onTap: allChecked
                      ? () {
                          _showFinalConfirmation(context);
                        }
                      : null,
                ),
                SizedBox(height: AppUi.bottomPadding(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(
    BuildContext context,
    String text,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            style: fontR(
              14,
              color: C.current.mainText,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            onChanged(!value);
          },
          child: CustomToggle(value: value),
        ),
      ],
    );
  }

  void _showFinalConfirmation(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    DefaultDialog.show(
      context,
      title: localizations.deleteAccountConfirmTitle,
      description: localizations.deleteAccountConfirmDescription,
      secondButtonLabel: localizations.deleteButton,
      onSecondAction: () async {
        // 다이얼로그를 닫고
        Navigator.pop(context);
        // 바텀시트를 닫으면서 true를 반환
        Navigator.pop(context, true); // of(context) 대신 직접 pop 사용
        widget.onSuccess();
      },
    );
  }
}
