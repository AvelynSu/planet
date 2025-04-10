import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/model/token_balance.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/common/default_dialog.dart';
import 'package:planet/ui/common/planet_address_bottom_sheet.dart';
import 'package:planet/ui/transaction/transaction_history/token_history_tile.dart';
import 'package:planet/ui/transaction/transaction_history/transaction_history_detail_screen.dart';

import '../../../enum/screen_status.dart';
import '../../../util/app_ui.dart';
import '../../../util/app_util.dart';
import '../../common/skeleton.dart';
import '../transfer/select_friend/select_friend_screen.dart';
import '../transfer/transfer/transfer_screen.dart';
import '../transfer/transfer_amount_input/transfer_amount_input_screen.dart';
import 'cubit/transaction_history_cubit.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final TokenBalance info;

  const TransactionHistoryScreen({
    super.key,
    required this.info,
  });

  static push(
    BuildContext context, {
    required TokenBalance info,
  }) {
    AppUi.push(context, TransactionHistoryScreen(info: info));
  }

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => TransactionBalanceCubit(
        appBloc: context.read<AppBloc>(),
        initialValue: widget.info,
      )..initialize(),
      child: BlocListener<TransactionBalanceCubit, TransactionHistoryState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {
            DefaultDialog.show(context, description: state.exception.errMsg);
          }

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<TransactionBalanceCubit, TransactionHistoryState>(
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
                    context.read<TransactionBalanceCubit>().initialize();
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
                            margin: const EdgeInsets.symmetric(vertical: 52),
                            child: Column(
                              children: [
                                AutoSizeText(
                                  "${state.balance.balanceToString} ${state.balance.info.symbol}",
                                  maxLines: 1,
                                  style: fontR(28, color: C.current.mainText),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  AppUtil.tokenToCurrency(
                                      state.balance.balance *
                                          state.balance.info.tokenPrice),
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
                                  title: AppLocalizations.of(context)
                                          ?.transfer_address ??
                                      '',
                                  onTap: () {
                                    PlanetAddressBottomSheet.show(context,
                                        planet: state.planet);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DefaultButton(
                                  title: AppLocalizations.of(context)
                                          ?.transaction_transfer ??
                                      '',
                                  onTap: () {
                                    if (state.status != ScreenStatus.loaded) {
                                      return;
                                    }

                                    /// 친구 고르기
                                    SelectFriendScreen.push(
                                      context,
                                      nework: widget.info.info.networkType,
                                      onSelect: (planet) {
                                        /// 물량 입력하기
                                        TransferAmountInputScreen.push(
                                          context,
                                          tokenInfo: widget.info.info,
                                          toPlanet: planet,
                                          onSelect: (amount) {
                                            print(amount);

                                            /// 가스비 설정
                                            TransferScreen.push(
                                              context,
                                              info: widget.info.info,
                                              amount: amount,
                                              toPlanet: planet,
                                            );
                                          },
                                        );
                                      },
                                    );

                                    // TransferScreen.push(context,
                                    //     tokenBalance: state.balance);
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
                          ...state.items.map(
                            (e) => GestureDetector(
                                onTap: () {
                                  TransactionHistoryDetailScreen.push(context,
                                      info: state.balance.info, item: e);
                                },
                                child: TransactionHistoryTile(
                                  item: e,
                                  info: state.balance.info,
                                )),
                          ),
                          if (state.items.isEmpty &&
                              state.status == ScreenStatus.loaded)
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 50),
                              child: Text(
                                state.planet.networkType == NetworkType.solana
                                    ? AppLocalizations.of(context)!
                                        .sol_history_not_supported
                                    : AppLocalizations.of(context)!
                                        .transaction_empty_list,
                                textAlign: TextAlign.center,
                                style: fontR(16,
                                    color: C.current.sub01, height: 1.3),
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
