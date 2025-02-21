import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/enum/gas_priority.dart';
import 'package:planet/model/transfer_fee.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/custom_field.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:web3dart/web3dart.dart';

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

    // Initialize controllers with current values
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

  String _formatEth(TransferFee fee) {
    final ethValue = EtherAmount.fromBigInt(EtherUnit.wei, fee.estimatedFee)
        .getValueInUnit(EtherUnit.ether);
    return ethValue.toStringAsFixed(8);
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

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: C.current.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Advanced Gas Settings',
                style: fontSB(18, color: C.current.mainText),
              ),
              BounceButton(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close,
                  color: C.current.mainText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Preset Gas Options
          Text(
            'Gas Price Presets',
            style: fontR(16, color: C.current.mainText),
          ),
          const SizedBox(height: 12),

          // Preset Gas Options List
          Container(
            decoration: BoxDecoration(
              color: C.current.lightBase,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: C.current.sub01.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: GasPriority.values.map((priority) {
                final isSelected =
                    priority == _selectedPriority && !_useCustomGas;
                final fee = widget.gasFees[priority];

                if (fee == null) return const SizedBox.shrink();

                return InkWell(
                  onTap: () => _updateGasFromPriority(priority),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? C.current.primary.withOpacity(0.05)
                          : null,
                      border: Border(
                        bottom: priority != GasPriority.fast
                            ? BorderSide(
                                color: C.current.sub01.withOpacity(0.1))
                            : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio(
                          value: true,
                          groupValue: isSelected,
                          onChanged: (_) => _updateGasFromPriority(priority),
                          activeColor: C.current.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                priority.name.toUpperCase(),
                                style: fontSB(14, color: C.current.mainText),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gas Price: ${fee.gasPrice} Wei',
                                style: fontR(12, color: C.current.sub01),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${_formatEth(fee)} ETH',
                          style: fontSB(14, color: C.current.mainText),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
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
                  setState(() {
                    _useCustomGas = value;
                  });
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
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Invalid Gas Settings'),
                      content: Text(
                          'Please enter valid gas price and gas limit values.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
              } else {
                widget.onPrioritySelected(_selectedPriority);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
