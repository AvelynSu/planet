import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/create_wallet/cubit/create_wallet_cubit.dart';
import 'package:planet/ui/create_wallet/page/create_wallet_confirm_mnemonic_page.dart';
import 'package:planet/ui/create_wallet/page/create_wallet_show_mnemonic_page.dart';

import '../../../../enum/screen_status.dart';
import '../util/app_ui.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const CreateWalletScreen());
  }

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => CreateWalletCubit()..initialize(),
      child: BlocListener<CreateWalletCubit, CreateWalletState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<CreateWalletCubit, CreateWalletState>(
          builder: (context, state) {
            var cubit = context.read<CreateWalletCubit>();
            Widget page = Container();

            switch (state.page) {
              case 0:
                page = CreateWalletShowMnemonicPage();
                break;
              case 1:
                page = CreateWalletConfirmMnemonicPage();
            }

            return BaseScaffold(
              isTransparentAppbar: false,
              onBack: () {
                if (state.page == 0) {
                  Navigator.pop(context);
                } else {
                  context.read<CreateWalletCubit>().updatePage(state.page - 1);
                }
              },
              backgroundColor: C.current.background,
              body: Container(
                child: Column(
                  children: [
                    Expanded(
                      child: page,
                    ),
                    if (state.page == 0)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: hPadding),
                        child: DefaultButton(
                          showBottomPadding: true,
                          title: "Next",
                          onTap: () {
                            if (state.page == 0) {
                              cubit.updatePage(state.page + 1);
                            }
                          },
                        ),
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
