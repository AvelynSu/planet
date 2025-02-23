import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/enum/gas_priority.dart';
import 'package:planet/model/transfer_fee.dart';
import 'package:planet/ui/common/custom_field.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/common/default_dialog.dart';
import 'package:web3dart/web3dart.dart';

import '../../../../util/app_ui.dart';
import '../../../common/custom_bottom_sheet_frame.dart';
import 'advanced_gas_selector.dart';

class AdvancedGasSettingsBottomSheet extends StatefulWidget {
  final Map<GasPriority, TransferFee> gasFees;
  final GasPriority selectedPriority;
  final Function(GasPriority) onPrioritySelected;
  final Function(BigInt, BigInt)? onCustomGasSet;

  const AdvancedGasSettingsBottomSheet({
    super.key,
    required this.gasFees,
    required this.selectedPriority,
    required this.onPrioritySelected,
    this.onCustomGasSet,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<GasPriority, TransferFee> gasFees,
    required GasPriority selectedPriority,
    required Function(GasPriority) onPrioritySelected,
    Function(BigInt, BigInt)? onCustomGasSet,
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedGasSettingsBottomSheet(
        gasFees: gasFees,
        selectedPriority: selectedPriority,
        onPrioritySelected: onPrioritySelected,
        onCustomGasSet: onCustomGasSet,
      ),
    );
  }

  @override
  State<AdvancedGasSettingsBottomSheet> createState() =>
      _AdvancedGasSettingsBottomSheetState();
}

class _AdvancedGasSettingsBottomSheetState
    extends State<AdvancedGasSettingsBottomSheet> {
  late TextEditingController _gasPriceController;
  late TextEditingController _gasLimitController;
  GasPriority _selectedPriority = GasPriority.medium;
  bool _useCustomGas = false;

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.selectedPriority;

    final currentFee = widget.gasFees[_selectedPriority]!;
    _gasPriceController =
        TextEditingController(text: currentFee.gasPrice.toString());
    _gasLimitController =
        TextEditingController(text: currentFee.gasLimit.toString());
  }

  void _updateGasFromPriority(GasPriority priority) {
    setState(() {
      _selectedPriority = priority;
      _useCustomGas = false;
    });

    final fee = widget.gasFees[priority]!;
    _gasPriceController.text = fee.gasPrice.toString();
    _gasLimitController.text = fee.gasLimit.toString();
  }

  BigInt _calculateEstimatedFee() {
    try {
      final gasPrice = BigInt.parse(_gasPriceController.text);
      final gasLimit = BigInt.parse(_gasLimitController.text);
      return gasPrice * gasLimit;
    } catch (e) {
      return BigInt.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estimatedFeeWei = _calculateEstimatedFee();
    final estimatedFeeEth =
        EtherAmount.fromBigInt(EtherUnit.wei, estimatedFeeWei)
            .getValueInUnit(EtherUnit.ether);

    return CustomBottomSheetFrame(
      backgroundColor: C.current.background,
      barColor: C.current.sub01,
      titleColor: C.current.mainText,
      title: "Advanced Gas Settings",
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header

            // Preset Gas Options
            Text(
              'Gas Price Presets',
              style: fontR(16, color: C.current.mainText),
            ),
            const SizedBox(height: 12),

            // Preset Gas Options List
            AdvancedGasSelector(
              onUpdateGasPriority: (item) {
                _updateGasFromPriority(item);
              },
              selectedPriority: _selectedPriority,
              useCustomGas: _useCustomGas,
              gasFees: widget.gasFees,
            ),

            const SizedBox(height: 24),

            // Custom Gas Input
            Row(
              children: [
                Text(
                  'Custom Gas Settings',
                  style: fontR(16, color: C.current.mainText),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _useCustomGas,
                  onChanged: (value) {
                    _useCustomGas = value;
                    setState(() {});
                  },
                  activeColor: C.current.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Gas Price Input
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gas Price (Wei)',
                        style: fontR(14, color: C.current.mainText),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: C.current.lightBase,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: C.current.sub01.withValues(alpha: 0.2),
                          ),
                        ),
                        child: CustomField(
                          controller: _gasPriceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          // enabled: _useCustomGas,
                          onChange: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gas Limit',
                        style: fontR(14, color: C.current.mainText),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: C.current.lightBase,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: C.current.sub01.withValues(alpha: 0.2),
                          ),
                        ),
                        child: CustomField(
                          controller: _gasLimitController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          // enabled: _useCustomGas,
                          onChange: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Estimated Fee
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: C.current.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: C.current.primary.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated Network Fee',
                    style: fontSB(14, color: C.current.mainText),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${estimatedFeeEth.toStringAsFixed(8)} ETH',
                    style: fontSB(16, color: C.current.primary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Apply Button
            DefaultButton(
              title: 'Apply',
              onTap: () {
                if (_useCustomGas && widget.onCustomGasSet != null) {
                  try {
                    final gasPrice = BigInt.parse(_gasPriceController.text);
                    final gasLimit = BigInt.parse(_gasLimitController.text);
                    widget.onCustomGasSet!(gasPrice, gasLimit);
                  } catch (e) {
                    // Show error dialog

                    DefaultDialog.show(context,
                        title: "Invalid Gas Settings",
                        description:
                            'Please enter valid gas price and gas limit values.');

                    return;
                  }
                } else {
                  widget.onPrioritySelected(_selectedPriority);
                }
                Navigator.pop(context);
              },
            ),
            SizedBox(height: AppUi.bottomPadding(context)),
          ],
        ),
      ),
    );
  }
}
