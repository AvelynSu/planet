import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/default_button.dart';

import '../../../../enum/screen_status.dart';
import '../../../../util/app_ui.dart';
import '../../../../util/app_util.dart';
import '../transfer_profile_component.dart';
import 'cubit/transfer_amount_input_cubit.dart';
import 'custom_number_keypad.dart';

class TransferAmountInputScreen extends StatefulWidget {
  final TokenInfo tokenInfo;
  final Planet toPlanet;
  final Function(String) onSelect;

  const TransferAmountInputScreen({
    super.key,
    required this.tokenInfo,
    required this.toPlanet,
    required this.onSelect,
  });

  static Future<String?> push(
    BuildContext context, {
    required TokenInfo tokenInfo,
    required Planet toPlanet,
    required Function(String) onSelect,
  }) async {
    return await AppUi.push(
      context,
      TransferAmountInputScreen(
        tokenInfo: tokenInfo,
        toPlanet: toPlanet,
        onSelect: onSelect,
      ),
    );
  }

  @override
  State<TransferAmountInputScreen> createState() =>
      _TransferAmountInputScreenState();
}

class _TransferAmountInputScreenState extends State<TransferAmountInputScreen> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => TransferAmountInputCubit(
        tokenInfo: widget.tokenInfo,
        appBloc: context.read<AppBloc>(),
        apiRepository: context.read<ApiRepository>(),
      )..initialize(),
      child: BlocListener<TransferAmountInputCubit, TransferAmountInputState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<TransferAmountInputCubit, TransferAmountInputState>(
          builder: (context, state) {
            var cubit = context.read<TransferAmountInputCubit>();
            return BaseScaffold(
              titleWidget: widget.toPlanet.name.isEmpty
                  ? null
                  : TransferProfileComponent(
                      planet: widget.toPlanet,
                      isSimpleMode: true,
                    ),
              onBack: () {
                Navigator.pop(context);
              },
              title: widget.toPlanet.name.isEmpty
                  ? AppUtil.shortenWalletAddress(widget.toPlanet.address)
                  : null,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // 사용 가능한 잔액
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: hPadding),
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: AutoSizeText(
                                    "${state.balance.balance} ${widget.tokenInfo.symbol}",
                                    maxLines: 1,
                                    style: fontM(18, color: C.current.mainText),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // 입력한 양
                          return Container(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: hPadding),
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: AutoSizeText(
                                    "${state.amount.isEmpty ? "0.0" : state.amount} ${widget.tokenInfo.symbol}",
                                    maxLines: 1,
                                    style: fontM(40, color: C.current.mainText),
                                  ),
                                ),
                                if (state.amount.isNotEmpty &&
                                    !state.isValidateAmount)
                                  Container(
                                    margin: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      AppLocalizations.of(context)
                                              ?.transfer_not_enough ??
                                          '',
                                      style:
                                          fontR(14, color: C.current.primary),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Text(
                                  AppUtil.tokenToCurrency(double.parse(
                                          state.amount.isEmpty
                                              ? "0"
                                              : state.amount) *
                                      state.balance.info.tokenPrice),
                                  style: fontR(14, color: C.current.sub01),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Container(
                    height: min(360, MediaQuery.of(context).size.height * 0.4),
                    child: CustomNumberKeyPad(
                      initialValue: state.amount,
                      onUpdateValue: (amount) {
                        cubit.updateAmount(amount);
                      },
                    ),
                  ),
                  Container(
                    color: C.current.sub02,
                    padding: EdgeInsets.only(
                      left: hPadding,
                      right: hPadding,
                      bottom: AppUi.bottomPadding(context),
                    ),
                    child: DefaultButton(
                      title:
                          AppLocalizations.of(context)?.transfer_submit ?? '',
                      onTap: state.isValidateAmount
                          ? () {
                              widget.onSelect(state.amount);
                            }
                          : null,
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
