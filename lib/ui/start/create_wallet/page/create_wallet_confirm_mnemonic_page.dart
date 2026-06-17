import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/l10n/app_localizations.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/ui/common/default_dialog.dart';

import '../../set_nickname/set_nickname_screen.dart';
import '../cubit/create_wallet_cubit.dart';

class CreateWalletConfirmMnemonicPage extends StatefulWidget {
  const CreateWalletConfirmMnemonicPage({super.key});

  @override
  State<CreateWalletConfirmMnemonicPage> createState() =>
      _CreateWalletConfirmMnemonicPageState();
}

class _CreateWalletConfirmMnemonicPageState
    extends State<CreateWalletConfirmMnemonicPage> {
  List<int> challengeIndices = []; // 유저가 맞춰야하는 니모닉 인덱스들
  List<String> shuffledWords = []; // 선택 가능한 니모닉 목록
  int currentStep = 0; // 현재 검증 단계 (0, 1, 2)
  bool isVerifying = false; // 검증 중인지 여부

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() {
    var cubit = context.read<CreateWalletCubit>();
    var mnemonic = cubit.state.mnemonic.split(" ");

    // 유저가 선택해야 하는 니모닉 인덱스 3개 설정
    challengeIndices = _getRandomNumbers(3);

    // 현재 검증 단계 초기화
    currentStep = 0;

    // 화면 갱신
    setState(() {});
  }

  // count개의 랜덤한 인덱스 반환 (0~11)
  List<int> _getRandomNumbers(int count) {
    final Set<int> numbers = {};
    while (numbers.length < count) {
      numbers.add(Random().nextInt(12));
    }
    return numbers.toList()..sort();
  }

  // 현재 단계에서 보여줄 선택지 생성
  List<String> _getShuffledChoices() {
    var cubit = context.read<CreateWalletCubit>();
    var allWords = cubit.state.mnemonic.split(" ");
    var correctWord = allWords[challengeIndices[currentStep]];

    // 정답 + 3개의 오답으로 구성된 선택지 생성
    List<String> choices = [correctWord];

    // 오답 추가 (중복되지 않도록)
    while (choices.length < 4) {
      int randomIndex = Random().nextInt(12);
      if (randomIndex != challengeIndices[currentStep] &&
          !choices.contains(allWords[randomIndex])) {
        choices.add(allWords[randomIndex]);
      }
    }

    // 선택지 섞기
    choices.shuffle();
    return choices;
  }

  // 단어 선택 처리
  void _handleWordSelection(String selectedWord) async {
    if (isVerifying) return;

    setState(() {
      isVerifying = true;
    });

    var cubit = context.read<CreateWalletCubit>();
    var allWords = cubit.state.mnemonic.split(" ");
    var correctWord = allWords[challengeIndices[currentStep]];

    if (selectedWord == correctWord) {
      // 정답일 경우
      if (currentStep == challengeIndices.length - 1) {
        // 모든 단계 완료
        var planet = await cubit.onGetRequiredPlanet();

        // 컴펌하던 페이지 지우고
        Navigator.pop(context);

        // 만약 수정해야할 플래닛이 있으면 닉네임 세팅 페이지 보여줌
        if (planet != null) {
          SetNicknameScreen.push(
            context,
            planet: Planet(
              networkType: cubit.state.networkType,
              mnemonic: cubit.state.mnemonic,
            ),
          );
        }
      } else {
        // 다음 단계로
        setState(() {
          currentStep++;
          isVerifying = false;
          shuffledWords = _getShuffledChoices();
        });
      }
    } else {
      // 오답일 경우
      DefaultDialog.showTimerDialog(context,
              description:
                  AppLocalizations.of(context)?.wallet_create_incorrect ?? '')
          .then((_) {
        setState(() {
          isVerifying = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CreateWalletCubit>();
    var state = cubit.state;
    var allWords = state.mnemonic.split(" ");

    // 첫 렌더링 시 선택지 초기화
    if (shuffledWords.isEmpty) {
      shuffledWords = _getShuffledChoices();
    }

    return Column(
      children: [
        // 진행 상태 표시
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              challengeIndices.length,
              (index) => Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: index <= currentStep
                      ? C.current.primary
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 안내 메시지
        Text(
          AppLocalizations.of(context)?.wallet_create_select_word(
                  challengeIndices[currentStep] + 1) ??
              '',
          style: fontR(18, color: C.current.mainText, height: 1.5),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        // 니모닉 단어 표시 (현재 검증 중인 단어는 ?로 표시)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              mainAxisExtent: 44,
            ),
            itemCount: 12,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              bool isCurrentChallenge = i == challengeIndices[currentStep];

              return Container(
                decoration: BoxDecoration(
                  color: C.current.lightBase,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrentChallenge
                        ? C.current.primary
                        : C.current.sub01.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    isCurrentChallenge ? '?' : "${i + 1}. ${allWords[i]}",
                    style: fontB(
                      14,
                      color: isCurrentChallenge
                          ? C.current.primary
                          : C.current.mainText,
                    ).copyWith(
                      fontWeight: isCurrentChallenge
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 42),

        // 선택지
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              mainAxisExtent: 50,
            ),
            itemCount: shuffledWords.length,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: isVerifying
                    ? null
                    : () => _handleWordSelection(shuffledWords[i]),
                child: Container(
                  decoration: BoxDecoration(
                    color: C.current.lightBase,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: 2,
                      color: Colors.grey[300]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      shuffledWords[i],
                      style: fontM(16, color: C.current.mainText),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
