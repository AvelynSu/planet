import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/start/create_wallet/page/create_wallet_confirm_mnemonic_page.dart';
import 'package:planet/ui/start/create_wallet/page/create_wallet_show_mnemonic_page.dart';

import '../../../../enum/screen_status.dart';
import '../../../util/app_ui.dart';
import 'cubit/create_wallet_cubit.dart';

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
      create: (BuildContext context) => CreateWalletCubit(
        appBloc: context.read<AppBloc>(),
        apiRepository: context.read<ApiRepository>(),
      )..initialize(),
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
                page = const CreateWalletShowMnemonicPage();
                break;
              case 1:
                page = const CreateWalletConfirmMnemonicPage();
            }

            return BaseScaffold(
              isTransparentAppbar: false,
              onLoading: state.status == ScreenStatus.loading,
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
                          title: AppLocalizations.of(context)
                                  ?.wallet_create_next ??
                              '',
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
