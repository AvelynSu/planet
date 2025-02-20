import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/custom_field.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/create_wallet/set_nickname/set_nickname_screen.dart';
import 'package:planet/ui/import_wallet/cubit/import_wallet_cubit.dart';

import '../../../../enum/screen_status.dart';
import '../util/app_ui.dart';

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

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
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
            Widget page = Container();

            return BaseScaffold(
              onLoading: state.status == ScreenStatus.loading,
              title: "복구 문구를 입력하세요.",
              onBack: () {
                Navigator.pop(context);
              },
              backgroundColor: C.current.background,
              body: Container(
                child: Column(
                  children: [
                    Text(
                      '회복 문구는 12개 또는 24개의 단어로 구성됩니다. 단어를 띄어쓰기로 구분하여 올바른 순서로 입력해주세요.',
                      style: fontR(14, color: C.current.background),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: hPadding, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: C.current.sub01.withValues(alpha: 0.7),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        child: Column(
                          children: [
                            CustomField(
                              controller: _controller,
                              maxLine: 3,
                              hintText:
                                  "word1 word2 word3 word4 word5 word6 ...",
                              onChange: (text) {
                                var item = cubit.getTestValue();
                                _controller.text = item;
                                cubit.updateMnimonic(item);
                                setState(() {});
                              },
                            ),
                            Text(
                              '붙여넣기',
                              style: fontR(14, color: C.current.mainText),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DefaultButton(
                      title: "지갑만들기",
                      onTap: () async {
                        var planet = await cubit.getAddress();
                        if (planet != PlanetDto.empty) {
                          if (planet.name.isEmpty) {
                            Navigator.pop(context);
                            SetNicknameScreen.push(context, planetDto: planet);
                          } else {
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
