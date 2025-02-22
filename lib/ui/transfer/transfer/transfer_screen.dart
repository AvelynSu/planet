import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/custom_exception.dart';
import 'package:planet/model/token_balance.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/custom_field.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/common/default_dialog.dart';
import 'package:planet/ui/util/app_ui.dart';
import 'package:planet/ui/util/app_util.dart';

import '../../../enum/screen_status.dart';
import 'component/gas_selector.dart';
import 'component/transfer_status_modal.dart';
import 'cubit/transfer_cubit.dart';

class TransferScreen extends StatefulWidget {
  final TokenBalance tokenBalance;

  const TransferScreen({
    super.key,
    required this.tokenBalance,
  });

  static push(
    BuildContext context, {
    required TokenBalance tokenBalance,
  }) {
    AppUi.push(context, TransferScreen(tokenBalance: tokenBalance));
  }

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TokenTransferCubit(
        appBloc: context.read<AppBloc>(),
        tokenBalance: widget.tokenBalance,
      )..initialize(),
      child: BlocListener<TokenTransferCubit, TokenTransferState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {
            if (state.exception?.errType ==
                ExceptionType.failTransferInitailize) {
              Navigator.pop(context);
              DefaultDialog.show(context, description: state.exception?.errMsg);
            } else {
              DefaultDialog.show(context, description: state.exception?.errMsg);
            }
          }
          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<TokenTransferCubit, TokenTransferState>(
          builder: (context, state) {
            final cubit = context.read<TokenTransferCubit>();

            return BaseScaffold(
              onLoading: state.status == ScreenStatus.loading,
              title: "Send ${widget.tokenBalance.info.symbol}",
              onBack: () => Navigator.pop(context),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Balance display
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: C.current.lightBase,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: C.current.sub01.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Available Balance",
                                    style: fontR(14, color: C.current.sub01),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "${widget.tokenBalance.balance} ${widget.tokenBalance.info.symbol}",
                                    style:
                                        fontSB(24, color: C.current.mainText),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Recipient address input
                            Text(
                              "Recipient Address",
                              style: fontR(16, color: C.current.mainText),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: C.current.lightBase,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: C.current.sub01.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomField(
                                      controller: _addressController,
                                      hintText: "0x...",
                                      onChange: (text) {
                                        cubit.updateRecipientAddress(text);
                                      },
                                    ),
                                  ),
                                  BounceButton(
                                    onTap: () async {
                                      final data =
                                          await Clipboard.getData('text/plain');
                                      if (data?.text != null) {
                                        _addressController.text = data!.text!;
                                        cubit.updateRecipientAddress(
                                            _addressController.text);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: C.current.sub01
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.content_paste_rounded,
                                        color: C.current.mainText,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Amount input
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Amount",
                                  style: fontR(16, color: C.current.mainText),
                                ),
                                BounceButton(
                                  onTap: () {
                                    // Set max available amount
                                    _amountController.text =
                                        "${widget.tokenBalance.balance}";
                                    cubit.updateAmount(_amountController.text);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: C.current.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "MAX",
                                      style:
                                          fontSB(12, color: C.current.primary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: C.current.lightBase,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: C.current.sub01.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomField(
                                      controller: _amountController,
                                      hintText: "0.0",
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d*$')),
                                      ],
                                      onChange: (text) {
                                        cubit.updateAmount(text);
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      widget.tokenBalance.info.symbol,
                                      style:
                                          fontSB(14, color: C.current.mainText),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Gas Priority Selection
                            Text(
                              "Gas Fee",
                              style: fontR(16, color: C.current.mainText),
                            ),
                            const SizedBox(height: 12),

                            if (state.gasFees.isNotEmpty)
                              GasPrioritySelector(
                                gasFees: state.gasFees,
                                selectedPriority: state.selectedGasPriority,
                                onPrioritySelected: (priority) {
                                  cubit.updateGasPriority(priority);
                                },
                                onCustomGasSet: (gasPrice, gasLimit) {
                                  cubit.setCustomGas(gasPrice, gasLimit);
                                },
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
                                      'Using Custom Gas Settings',
                                      style:
                                          fontSB(14, color: C.current.mainText),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Gas Price: ${state.customGasFee!.gasPrice} Wei',
                                            style: fontR(12,
                                                color: C.current.sub01),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Gas Limit: ${state.customGasFee!.gasLimit}',
                                            style: fontR(12,
                                                color: C.current.sub01),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            if (!state.isValidateAddress &&
                                _addressController.text.isNotEmpty)
                              _buildErrorMessage(
                                  "Please enter a valid recipient address"),

                            if (!state.isValidateAmount &&
                                _amountController.text.isNotEmpty)
                              _buildErrorMessage("Please enter a valid amount"),
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
                      title: "Send",
                      onTap: state.isFormValid
                          ? () => _confirmAndExecuteTransfer(context, cubit)
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

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: fontR(14, color: Colors.red.shade700, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndExecuteTransfer(
      BuildContext context, TokenTransferCubit cubit) async {
    final confirmed = await DefaultDialog.show(
          context,
          title: "Confirm Transfer",
          description:
              "Are you sure you want to send ${_amountController.text} ${widget.tokenBalance.info.symbol} to\n${AppUtil.shortenWalletAddress(_addressController.text)}?",
          onSecondAction: () {},
          // cancelText: "Cancel",
          // confirmText: "Confirm",
        ) ??
        false;

    if (confirmed == true) {
      final loadingDialog = TransferLoadingDialog.show(context);

      try {
        final success = await cubit.executeTransfer();

        // Hide loading dialog
        Navigator.pop(context);

        if (success) {
          await TransferSuccessDialog.show(
            context,
            amount: _amountController.text,
            symbol: widget.tokenBalance.info.symbol,
            recipient: _addressController.text,
          );

          // Return to previous screen
          Navigator.pop(context);
        } else {
          await DefaultDialog.show(
            context,
            title: "Transfer Failed",
            description:
                "Your transaction failed to complete. Please try again.",
            // confirmText: "OK",
          );
        }
      } catch (e) {
        // Hide loading dialog
        Navigator.pop(context);

        await DefaultDialog.show(
          context,
          title: "Error",
          description: "An error occurred: ${e.toString()}",
          // confirmText: "OK",
        );
      }
    }
  }
}
