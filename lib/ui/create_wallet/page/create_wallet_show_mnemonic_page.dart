import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/ui/create_wallet/cubit/create_wallet_cubit.dart';

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
            '아래 12개의 단어를 순서대로 안전하게 저장하세요',
            style: fontB(16, color: C.current.mainText),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 10),

        // 보안 안내
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '다음 단계에서 일부 단어를 선택하여 확인할 예정입니다. 위 단어들을 잘 기억해두세요!',
            style: fontR(14, color: C.current.mainText.withValues(alpha: 0.5)),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 30),

        // 니모닉 단어 표시
        if (state.mnemonic.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                mainAxisExtent: 44,
              ),
              itemCount: state.mnemonic.split(" ").length,
              shrinkWrap: true,
              itemBuilder: (context, i) {
                var items = state.mnemonic.split(" ");
                var item = items.length > i ? items[i] : "";
                return Container(
                  decoration: BoxDecoration(
                    color: C.current.lightBase,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: C.current.sub01.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "${i + 1}. $item",
                      style: fontM(14, color: C.current.mainText),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 40),

        // 경고 박스
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
                    '니모닉 단어들은 지갑 복구에 사용됩니다. 절대 다른 사람과 공유하지 마세요',
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
