import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/token_balance.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/common/planet_address_bottom_sheet.dart';
import 'package:planet/ui/token_balance/token_history_tile.dart';
import 'package:planet/ui/transfer/transfer_screen.dart';

import '../../../enum/screen_status.dart';
import '../common/skeleton.dart';
import '../util/app_ui.dart';
import 'cubit/sample_cubit.dart';

class TokenHistoryScreen extends StatefulWidget {
  final TokenBalance info;

  const TokenHistoryScreen({
    super.key,
    required this.info,
  });

  static push(
    BuildContext context, {
    required TokenBalance info,
  }) {
    AppUi.push(context, TokenHistoryScreen(info: info));
  }

  @override
  State<TokenHistoryScreen> createState() => _TokenHistoryScreenState();
}

class _TokenHistoryScreenState extends State<TokenHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => TokenBalanceCubit(
        appBloc: context.read<AppBloc>(),
        initialValue: widget.info,
      )..initialize(),
      child: BlocListener<TokenBalanceCubit, TokenBalanceState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<TokenBalanceCubit, TokenBalanceState>(
          builder: (context, state) {
            return BaseScaffold(
              onBack: () {
                Navigator.pop(context);
              },
              title: widget.info.info.name,
              body: Container(
                height: double.infinity,
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<TokenBalanceCubit>().initialize();
                  },
                  color: C.current.mainText,
                  backgroundColor: Colors.transparent,
                  displacement: 40,
                  strokeWidth: 3,
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 50),
                      padding: EdgeInsets.symmetric(horizontal: hPadding),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 52),
                            child: Column(
                              children: [
                                Text(
                                  "${state.balance.balance} ${state.balance.info.symbol}",
                                  style: fontR(28, color: C.current.mainText),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "0.0 USD",
                                  style: fontR(16, color: C.current.sub01),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: DefaultButton(
                                  isReverse: true,
                                  title: "Address",
                                  onTap: () {
                                    PlanetAddressBottomSheet.show(context,
                                        planet: state.planet);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DefaultButton(
                                  title: "Transfer",
                                  onTap: () {
                                    TransferScreen.push(context,
                                        tokenBalance: state.balance);
                                    // DefaultDialog.showComingSoon(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          if (state.status == ScreenStatus.loading &&
                              state.items.isEmpty)
                            ...List.generate(5, (e) => Skeleton.historyTile),
                          ...state.items.map((e) => TokenHistoryTile(item: e)),
                          if (state.items.isEmpty &&
                              state.status == ScreenStatus.loaded)
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 50),
                              child: Text(
                                'Empty List',
                                style: fontR(16, color: C.current.sub01),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
