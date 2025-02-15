import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/ui/common/default_dialog.dart';
import 'package:planet/ui/create_wallet/cubit/create_wallet_cubit.dart';
import 'package:planet/ui/start/set_nickname/set_nickname_screen.dart';

class CreateWalletConfirmMnemonicPage extends StatefulWidget {
  const CreateWalletConfirmMnemonicPage({super.key});

  @override
  State<CreateWalletConfirmMnemonicPage> createState() =>
      _CreateWalletConfirmMnemonicPageState();
}

class _CreateWalletConfirmMnemonicPageState
    extends State<CreateWalletConfirmMnemonicPage> {
  List<int> randomIdx = []; // 유저가 맞춰야하는 니모닉 인덱스
  List<String> shuffled = []; // 선택 가능한 니모닉 목록
  List<String> selected = []; // 유저가 선택한 니모닉

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() {
    var cubit = context.read<CreateWalletCubit>();
    var mnemonic = cubit.state.mnemonic.split(" ");

    // 선택 가능한 니모닉 만들기 (섞인 상태)
    shuffled = [...mnemonic]..shuffle();

    // 유저가 선택해야 하는 니모닉 인덱스 설정
    randomIdx = _getRandomNumbers();
  }

  List<int> _getRandomNumbers() {
    final Set<int> numbers = {};
    while (numbers.length < 4) {
      numbers.add(Random().nextInt(12));
    }
    return numbers.toList()..sort();
  }

  bool _verifyMnemonic() {
    var originalMnemonic =
        context.read<CreateWalletCubit>().state.mnemonic.split(" ");
    var isCorrect = true;

    for (var i = 0; i < randomIdx.length; i++) {
      if (selected[i] != originalMnemonic[randomIdx[i]]) {
        isCorrect = false;
        break;
      }
    }
    return isCorrect;
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CreateWalletCubit>();
    var state = cubit.state;

    return Column(
      children: [
        const SizedBox(height: 100),
        // 유저가 맞춰야 하는 니모닉 표시
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            mainAxisExtent: 40,
          ),
          itemCount: 12,
          shrinkWrap: true,
          itemBuilder: (context, i) {
            var items = state.mnemonic.split(" ");
            var item = items.length > i ? items[i] : "";

            var text = "";
            if (randomIdx.contains(i)) {
              var selectedIndex = randomIdx.indexOf(i);
              text = selectedIndex < selected.length
                  ? selected[selectedIndex]
                  : "";
            } else {
              text = item;
            }

            bool isRandomItem = randomIdx.contains(i);
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 3,
                  color: isRandomItem ? Colors.blue : Colors.grey[300]!,
                ),
              ),
              child: Center(child: Text(text)),
            );
          },
        ),

        // 유저가 선택할 수 있는 니모닉 목록
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            mainAxisExtent: 40,
          ),
          itemCount: shuffled.length,
          shrinkWrap: true,
          itemBuilder: (context, i) {
            var item = shuffled.length > i ? shuffled[i] : "";

            return GestureDetector(
              onTap: () {
                if (selected.length >= 4) {
                  if (selected.length == 4 && selected.last == item) {
                    selected.remove(item);
                    setState(() {});
                  }
                  return;
                }

                if (selected.contains(item)) {
                  if (selected.last == item) {
                    selected.remove(item);
                    setState(() {});
                  }
                  return;
                }

                setState(() {
                  selected.add(item);
                  if (selected.length == 4) {
                    var isCorrect = _verifyMnemonic();
                    if (isCorrect) {
                      Navigator.pop(context);
                      SetNicknameScreen.push(
                        context,
                        planetDto: PlanetDto(
                          mnemonic: state.mnemonic,
                        ),
                      );
                      DefaultDialog.show(
                        context,
                        title: "월렝 생성 성공 !",
                        description: "행성 이름을 설정해주세요",
                      );
                    } else {
                      selected = [];
                      setState(() {});
                      DefaultDialog.show(context, description: "다시 시도해주세요");
                    }
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    width: 3,
                    color: selected.contains(item)
                        ? Colors.red
                        : Colors.grey[300]!,
                  ),
                ),
                child: Center(child: Text(item)),
              ),
            );
          },
        ),
      ],
    );
  }
}
