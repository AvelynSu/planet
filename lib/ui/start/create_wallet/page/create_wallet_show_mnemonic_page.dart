import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/ui/common/mnemonic_pharse_component.dart';
import 'package:planet/ui/common/small_round_button.dart';

import '../../../common/default_dialog.dart';
import '../cubit/create_wallet_cubit.dart';

class CreateWalletShowMnemonicPage extends StatefulWidget {
  const CreateWalletShowMnemonicPage({super.key});

  @override
  State<CreateWalletShowMnemonicPage> createState() =>
      _CreateWalletShowMnemonicPageState();
}

class _CreateWalletShowMnemonicPageState
    extends State<CreateWalletShowMnemonicPage> {
  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CreateWalletCubit>();
    var state = cubit.state;

    return Column(
      children: [
        // 안내 텍스트 추가
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Securely store these 12 words in order.",
            //  '아래 12개의 단어를 순서대로 안전하게 저장하세요',
            style: fontSB(16, color: C.current.mainText),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 10),

        // 보안 안내
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "In the next step, we will ask you to select some of these words for verification. Make sure to remember them well!",
            // '다음 단계에서 일부 단어를 선택하여 확인할 예정입니다.\n 단어들을 잘 기억해두세요!',
            style: fontR(14,
                color: C.current.mainText.withValues(alpha: 0.5), height: 1.3),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 42),
        // 니모닉 단어 표시
        if (state.mnemonic.isNotEmpty)
          MnemonicPharseComponent(mnemonic: state.mnemonic),

        const SizedBox(height: 24),
        if (state.mnemonic.isNotEmpty)
          SmallRoundButton(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: state.mnemonic));
              DefaultDialog.showTimerDialog(context,
                  description: "Success copy", duration: Duration(seconds: 1));
            },
            iconPath: "icons/ic_copy.svg",
            title: "Copy Words",
          ),
        const SizedBox(height: 28),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.current.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: C.current.primary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: C.current.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "These mnemonic words are used to recover your wallet. Never share them with anyone else.",
                    // '니모닉 단어들은 지갑 복구에 사용됩니다. 절대 다른 사람과 공유하지 마세요',
                    style: fontR(15, color: C.current.primary, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
