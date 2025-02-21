import 'package:flutter/material.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/enum/gas_priority.dart';
import 'package:planet/model/transfer_fee.dart';
import 'package:web3dart/web3dart.dart';

import 'advanced_gas.dart';

class GasPrioritySelector extends StatelessWidget {
  final Map<GasPriority, TransferFee> gasFees;
  final GasPriority selectedPriority;
  final Function(GasPriority) onPrioritySelected;
  final Function(BigInt, BigInt)? onCustomGasSet;

  const GasPrioritySelector({
    super.key,
    required this.gasFees,
    required this.selectedPriority,
    required this.onPrioritySelected,
    this.onCustomGasSet,
  });

  String _getPriorityLabel(GasPriority priority) {
    switch (priority) {
      case GasPriority.slow:
        return 'Slow';
      case GasPriority.medium:
        return 'Average';
      case GasPriority.fast:
        return 'Fast';
    }
  }

  String _formatEth(TransferFee fee) {
    // Convert from Wei to ETH (1 ETH = 10^18 Wei)
    final ethValue = EtherAmount.fromBigInt(EtherUnit.wei, fee.estimatedFee)
        .getValueInUnit(EtherUnit.ether);
    return ethValue.toStringAsFixed(8);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
              final isSelected = priority == selectedPriority;
              final fee = gasFees[priority];

              if (fee == null) return const SizedBox.shrink();

              return InkWell(
                onTap: () => onPrioritySelected(priority),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? C.current.primary.withOpacity(0.05) : null,
                    border: Border(
                      bottom: priority != GasPriority.fast
                          ? BorderSide(color: C.current.sub01.withOpacity(0.1))
                          : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio(
                        value: priority,
                        groupValue: selectedPriority,
                        onChanged: (val) =>
                            onPrioritySelected(val as GasPriority),
                        activeColor: C.current.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getPriorityLabel(priority),
                              style: fontSB(14, color: C.current.mainText),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Estimated confirmation time: ${_getEstimatedTime(priority)}',
                              style: fontR(12, color: C.current.sub01),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_formatEth(fee)} ETH',
                            style: fontSB(14, color: C.current.mainText),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gas: ${fee.gasPrice.toRadixString(10)}',
                            style: fontR(12, color: C.current.sub01),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Advanced Gas Settings Button
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: InkWell(
            onTap: () {
              // Show advanced gas settings bottomsheet
              AdvancedGasSettingsBottomSheet.show(
                context,
                gasFees: gasFees,
                selectedPriority: selectedPriority,
                onPrioritySelected: onPrioritySelected,
                onCustomGasSet: onCustomGasSet,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.settings,
                  size: 16,
                  color: C.current.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  "Advanced Gas Settings",
                  style: fontR(14, color: C.current.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getEstimatedTime(GasPriority priority) {
    switch (priority) {
      case GasPriority.slow:
        return '~5 min';
      case GasPriority.medium:
        return '~2 min';
      case GasPriority.fast:
        return '< 30 sec';
    }
  }
}
