import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/custom_field.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/common/small_round_button.dart';

import '../../../../enum/screen_status.dart';
import '../../../util/app_ui.dart';
import '../set_nickname/set_nickname_screen.dart';
import 'cubit/import_wallet_cubit.dart';

class ImportWalletScreen extends StatefulWidget {
  const ImportWalletScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const ImportWalletScreen());
  }

  @override
  State<ImportWalletScreen> createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {
  late TextEditingController _controller;
  bool _isValidInput = false;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  void _validateInput(String text) {
    final wordCount =
        text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    _isValidInput =
        (wordCount == 12 || wordCount == 24) && text.trim().isNotEmpty;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ImportWalletCubit(
        appBloc: context.read<AppBloc>(),
        apiRepository: context.read<ApiRepository>(),
      ),
      child: BlocListener<ImportWalletCubit, ImportWalletState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}
          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<ImportWalletCubit, ImportWalletState>(
          builder: (context, state) {
            var cubit = context.read<ImportWalletCubit>();

            return BaseScaffold(
              onLoading: state.status == ScreenStatus.loading,
              title: AppLocalizations.of(context)?.wallet_import_title ?? '',
              //                  "복구 문구 입력",
              onBack: () {
                Navigator.pop(context);
              },
              backgroundColor: C.current.background,
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 안내 메시지
                            // Container(
                            //   padding: const EdgeInsets.all(16),
                            //   decoration: BoxDecoration(
                            //     color: C.current.primary.withValues(alpha: 0.1),
                            //     borderRadius: BorderRadius.circular(12),
                            //     border: Border.all(
                            //       color: C.current.primary.withValues(alpha: 0.15),
                            //       width: 1,
                            //     ),
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       Icon(
                            //         Icons.info_outline,
                            //         color: C.current.primary,
                            //         size: 24,
                            //       ),
                            //       const SizedBox(width: 12),
                            //       Expanded(
                            //         child: Text(
                            //           '회복 문구는 12개 또는 24개의 단어로 구성됩니다. 단어를 띄어쓰기로 구분하여 올바른 순서로 입력해주세요.',
                            //           style: fontR(14,
                            //               color: C.current.primary, height: 1.5),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            const SizedBox(height: 16),

                            // 입력 필드 라벨
                            Text(
                              AppLocalizations.of(context)
                                      ?.wallet_import_recovery_phrase ??
                                  '',
                              //   '복구 문구',
                              style: fontR(16, color: C.current.mainText),
                            ),

                            const SizedBox(height: 16),

                            // 입력 필드
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: C.current.sub02,
                                // border: Border.all(
                                //   color: C.current.sub01.withValues(alpha: 0.7),
                                // ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomField(
                                    controller: _controller,
                                    maxLine: 5,
                                    hintText: AppLocalizations.of(context)
                                            ?.wallet_import_placeholder ??
                                        '',
                                    onChange: (text) {
                                      _validateInput(text);
                                      cubit.updateMnimonic(text);
                                    },
                                  ),

                                  const SizedBox(height: 12),

                                  // 붙여넣기 버튼
                                  SmallRoundButton(
                                    onTap: () async {
                                      final data =
                                          await Clipboard.getData('text/plain');
                                      if (data?.text != null) {
                                        _controller.text = data!.text!;
                                        _validateInput(_controller.text);
                                        cubit.updateMnimonic(_controller.text);
                                      }
                                    },
                                    iconPath: "icons/ic_copy.svg",
                                    title: AppLocalizations.of(context)
                                            ?.wallet_import_paste ??
                                        '',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 단어 수 표시
                            Text(
                              AppLocalizations.of(context)
                                      ?.wallet_import_word_count(
                                          _controller.text.trim().isEmpty
                                              ? 0
                                              : _controller.text
                                                  .trim()
                                                  .split(RegExp(r'\s+'))
                                                  .where((w) => w.isNotEmpty)
                                                  .length) ??
                                  '',
                              style: fontR(14, color: C.current.sub01),
                            ),

                            const SizedBox(height: 40),

                            // 경고 메시지
                            if (_controller.text.isNotEmpty && !_isValidInput)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      C.current.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: C.current.primary,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.red[700],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)
                                                ?.recovery_phrase_requirement ??
                                            '',
                                        style: fontR(14,
                                            color: C.current.primary,
                                            height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(bottom: AppUi.bottomPadding(context)),
                    padding: EdgeInsets.symmetric(horizontal: hPadding),
                    child: Column(
                      children: [
                        // 버튼
                        DefaultButton(
                          title: AppLocalizations.of(context)
                                  ?.wallet_import_restore ??
                              '',
                          onTap: _isValidInput
                              ? () async {
                                  var planet =
                                      await cubit.getRequiredNicknamePlanet();
                                  Navigator.pop(context);
                                  if (planet != null && planet.name.isEmpty) {
                                    SetNicknameScreen.push(context,
                                        planet: planet);
                                  }
                                }
                              : null,
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
