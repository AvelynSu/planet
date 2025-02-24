import 'package:flutter/material.dart';
import 'package:planet/model/transfer_fee.dart';
import 'package:web3dart/web3dart.dart';

import '../../../../../custom_theme.dart';
import '../../../../../enum/gas_priority.dart';

class AdvancedGasSelector extends StatefulWidget {
  final Function(GasPriority) onUpdateGasPriority;
  final GasPriority selectedPriority;
  final bool useCustomGas;
  final Map<GasPriority, TransferFee> gasFees;

  const AdvancedGasSelector({
    super.key,
    required this.onUpdateGasPriority,
    required this.selectedPriority,
    required this.useCustomGas,
    required this.gasFees,
  });

  @override
  State<AdvancedGasSelector> createState() => _AdvancedGasSelectorState();
}

class _AdvancedGasSelectorState extends State<AdvancedGasSelector> {
  String _formatEth(TransferFee fee) {
    final ethValue = EtherAmount.fromBigInt(EtherUnit.wei, fee.estimatedFee)
        .getValueInUnit(EtherUnit.ether);
    return ethValue.toStringAsFixed(8);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              priority == widget.selectedPriority && !widget.useCustomGas;
          final fee = widget.gasFees[priority];

          if (fee == null) return const SizedBox.shrink();

          return InkWell(
            onTap: () => widget.onUpdateGasPriority(priority),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? C.current.primary.withOpacity(0.05) : null,
                border: Border(
                  bottom: priority != GasPriority.fast
                      ? BorderSide(color: C.current.sub01.withOpacity(0.1))
                      : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Radio(
                    value: true,
                    groupValue: isSelected,
                    onChanged: (_) => widget.onUpdateGasPriority(priority),
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
    );
  }
}
