import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/l10n/app_localizations.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/model/custom_exception.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/service/wallet/wallet_transfer/walltet_transfer_service.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/custom_error_card.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/common/default_dialog.dart';
import 'package:planet/ui/pin_screen.dart';
import 'package:planet/ui/transaction/transfer/transfer/trasnfer_success_screen.dart';

import '../../../../bloc/app/app_event.dart';
import '../../../../enum/screen_status.dart';
import '../../../../util/app_ui.dart';
import '../../../../util/app_util.dart';
import '../transfer_profile_component.dart';
import 'component/gas_selector.dart';
import 'component/transfer_label.dart';
import 'component/transfer_status_modal.dart';
import 'cubit/transfer_cubit.dart';

class TransferScreen extends StatefulWidget {
  final TokenInfo info;
  final String amount;
  final Planet toPlanet;

  const TransferScreen({
    super.key,
    required this.info,
    required this.amount,
    required this.toPlanet,
  });

  static push(
    BuildContext context, {
    required TokenInfo info,
    required String amount,
    required Planet toPlanet,
  }) {
    AppUi.push(context,
        TransferScreen(info: info, amount: amount, toPlanet: toPlanet));
  }

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TokenTransferCubit(
        appBloc: context.read<AppBloc>(),
        tokenInfo: widget.info,
        toPlanet: widget.toPlanet,
        amount: widget.amount,
      )..initialize(),
      child: BlocListener<TokenTransferCubit, TokenTransferState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {
            if (state.exception?.errType ==
                ExceptionType.failTransferInitailize) {
              Navigator.pop(context);
              DefaultDialog.show(context, description: state.exception?.errMsg);
            } else {
              DefaultDialog.show(context,
                  title: "Transcation Failed",
                  description: state.exception?.errMsg);
            }
          }
          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<TokenTransferCubit, TokenTransferState>(
          builder: (context, state) {
            var appState = (context.read<AppBloc>().state as AppLoaded);
            final cubit = context.read<TokenTransferCubit>();
            var currentFee = state.gasFees[state.selectedGasPriority];
            return BaseScaffold(
              onLoading: state.status == ScreenStatus.loading,
              title: AppLocalizations.of(context)
                      ?.transfer_token_send(state.balance.info.symbol) ??
                  '',
              onBack: () => Navigator.pop(context),
              body: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 52),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// 주소
                        (state.toPlanet.name.isEmpty)
                            ? AutoSizeText(
                                AppUtil.shortenWalletAddress(
                                    state.toPlanet.address),
                                maxLines: 1,
                                style: fontM(18, color: C.current.mainText),
                              )
                            : TransferProfileComponent(
                                planet: state.toPlanet,
                                size: 28,
                                enableAddress: false,
                              ),
                        const SizedBox(height: 12),

                        /// 입력한 양
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding:
                                    EdgeInsets.symmetric(horizontal: hPadding),
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: AutoSizeText(
                                  "${state.amount.isEmpty ? "0.0" : state.amount} ${widget.info.symbol}",
                                  maxLines: 1,
                                  style: fontM(28, color: C.current.mainText),
                                ),
                              ),
                              if (state.amount.isNotEmpty &&
                                  !state.isValidateAmount &&
                                  state.status != ScreenStatus.loading)
                                Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    AppLocalizations.of(context)
                                            ?.transfer_not_enough ??
                                        '',
                                    style: fontR(14, color: C.current.primary),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              Text(
                                AppUtil.tokenToCurrency(state.balance.price),
                                style: fontR(14, color: C.current.sub01),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TransferLabel(
                                title: AppLocalizations.of(context)
                                        ?.transfer_label_to ??
                                    '',
                                value: appState.current.name,
                                description: AppUtil.shortenWalletAddress(
                                    appState.current.address)),
                            TransferLabel(
                                title: AppLocalizations.of(context)
                                        ?.transfer_label_from ??
                                    '',
                                value: state.toPlanet.name.isEmpty
                                    ? AppUtil.shortenWalletAddress(
                                        appState.current.address)
                                    : state.toPlanet.name,
                                description: AppUtil.shortenWalletAddress(
                                    state.toPlanet.address)),
                            TransferLabel(
                              title: AppLocalizations.of(context)
                                      ?.transfer_label_fee ??
                                  '',
                              value:
                                  '${currentFee?.feeToUiValue(widget.info.networkType)} ${widget.info.networkType.symbol}',
                              description: AppLocalizations.of(context)
                                      ?.gas_settings_gas_price_title(
                                          "${currentFee?.gasPrice.toRadixString(10)}") ??
                                  '',
                            ),

                            if (state.gasFees.isNotEmpty &&
                                widget.info.networkType != NetworkType.solana)
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                child: GasPrioritySelector(
                                  gasFees: state.gasFees,
                                  selectedPriority: state.selectedGasPriority,
                                  onPrioritySelected: (priority) {
                                    cubit.updateGasPriority(priority);
                                  },
                                  onCustomGasSet: (gasPrice, gasLimit) {
                                    cubit.setCustomGas(gasPrice, gasLimit);
                                  },
                                ),
                              ),

                            // Show custom gas fee if using custom gas settings
                            if (state.useCustomGas &&
                                state.customGasFee != null)
                              Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: C.current.primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: C.current.primary.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)
                                              ?.using_custom_gas_settings ??
                                          '',
                                      style:
                                          fontSB(14, color: C.current.mainText),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            AppLocalizations.of(context)
                                                    ?.gas_settings_gas_price_title(
                                                        state.customGasFee!
                                                            .gasPrice) ??
                                                '' + "Wei",
                                            style: fontR(12,
                                                color: C.current.sub01),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            AppLocalizations.of(context)
                                                    ?.gas_settings_gas_limit_value(
                                                        state.customGasFee!
                                                            .gasLimit) ??
                                                '',
                                            style: fontR(12,
                                                color: C.current.sub01),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            if (!state.isValidateAmount &&
                                state.status != ScreenStatus.loading)
                              CustomErrorCard(
                                  iconPath: "",
                                  title: AppLocalizations.of(context)
                                          ?.transfer_invalid_amount ??
                                      ''),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom button
                  Container(
                    margin:
                        EdgeInsets.only(bottom: AppUi.bottomPadding(context)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DefaultButton(
                      title: AppLocalizations.of(context)?.transfer_send ?? '',
                      onTap: state.isFormValid
                          ? () async {
                              _confirmAndExecuteTransfer(context, cubit);
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

  Future<void> _confirmAndExecuteTransfer(
      BuildContext context, TokenTransferCubit cubit) async {
    var appState = (context.read<AppBloc>().state as AppLoaded);
    // 로딩 다이얼로그가 취소되었는지 확인하는 플래그
    bool isCancelled = false;

    final confirmed = await DefaultDialog.show(
          context,
          title: AppLocalizations.of(context)?.transfer_confirm ?? '',
          description: AppLocalizations.of(context)?.transfer_confirm_message(
                  appState.current.name,
                  cubit.state.balance.info.symbol,
                  cubit.state.toPlanet.name.isEmpty
                      ? AppUtil.shortenWalletAddress(
                          cubit.state.toPlanet.address)
                      : cubit.state.toPlanet.name) ??
              '',
          onSecondAction: () {},
        ) ??
        false;

    if (confirmed == true) {
      var enablePin = await PinScreen.push(
        context,
        onBack: () {
          Navigator.pop(context);
        },
        enableSuccessPop: true,
        onSuccess: (val) {},
        mode: PinMode.validate,
      );
      if (enablePin ?? false) {
        setState(() {});
        await Future.delayed(Duration(milliseconds: 100));
        final loadingDialog = TransferLoadingDialog.show(
          context,
          gasPriority: cubit.state.selectedGasPriority,
          onCancel: () {
            // 취소 플래그 설정
            isCancelled = true;

            /// 금액 확인 부분
            Navigator.pop(context);

            /// 친구 선택 확인 부분
            Navigator.pop(context);
          },
        );

        try {
          await Future.delayed(Duration(milliseconds: 50));
          final success = await cubit.executeTransfer();

          // isCancelled가 true면 이미 다이얼로그가 닫혔으므로 추가 pop을 하지 않음
          if (!isCancelled) {
            // Hide loading dialog
            Navigator.pop(context);

            /// 최종 확인 화면
            Navigator.pop(context);

            if (success != TransactionConfirmationStatus.unconfirmed) {
              /// 금액 확인 부분
              Navigator.pop(context);

              /// 친구 선택 확인 부분
              Navigator.pop(context);

              var currentFee =
                  cubit.state.gasFees[cubit.state.selectedGasPriority];
              TransferSuccessScreen.push(
                context,
                status: success,
                transactionId: "",
                amount: cubit.state.amount,
                tokenInfo: cubit.state.balance.info,
                fee: currentFee!,
                recipient: cubit.state.toPlanet,
              );

              context.read<AppBloc>().add(AppUpdate(
                    updatePlanets: false,
                    updateBalanceToken: widget.info,
                  ));
            }
          }
        } catch (e) {
          // isCancelled가 true면 이미 다이얼로그가 닫혔으므로 추가 pop을 하지 않음
          if (!isCancelled) {
            // Hide loading dialog
            Navigator.pop(context);

            // amount 입력 페이지로 이동
            Navigator.pop(context);
            await DefaultDialog.show(
              context,
              title: AppLocalizations.of(context)?.error_title ?? '',
              description:
                  AppLocalizations.of(context)?.error_message(e.toString()) ??
                      '',
              // confirmText: "OK",
            );
          }
        }
      }
    }
  }
}
