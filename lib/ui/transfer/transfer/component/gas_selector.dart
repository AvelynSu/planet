import 'package:flutter/material.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/enum/gas_priority.dart';
import 'package:planet/model/transfer_fee.dart';
import 'package:web3dart/web3dart.dart';

import 'advanced_gas.dart';

class GasPrioritySelector extends StatefulWidget {
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

  @override
  State<GasPrioritySelector> createState() => _GasPrioritySelectorState();
}

class _GasPrioritySelectorState extends State<GasPrioritySelector> {
  // 슬라이더 위치 0.0(slow) ~ 1.0(fast)
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _initSliderValue();
  }

  @override
  void didUpdateWidget(GasPrioritySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 외부에서 selectedPriority가 변경되면 슬라이더 값도 업데이트
    if (oldWidget.selectedPriority != widget.selectedPriority) {
      _initSliderValue();
    }
  }

  void _initSliderValue() {
    // 선택된 우선순위에 따라 슬라이더 초기값 설정
    switch (widget.selectedPriority) {
      case GasPriority.slow:
        _sliderValue = 0.0;
        break;
      case GasPriority.medium:
        _sliderValue = 0.5;
        break;
      case GasPriority.fast:
        _sliderValue = 1.0;
        break;
    }
  }

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

  // 슬라이더 값에 따라 현재 선택된 우선순위 반환
  GasPriority _getCurrentPriority() {
    if (_sliderValue < 0.33) {
      return GasPriority.slow;
    } else if (_sliderValue < 0.66) {
      return GasPriority.medium;
    } else {
      return GasPriority.fast;
    }
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

  @override
  Widget build(BuildContext context) {
    final currentPriority = _getCurrentPriority();
    final currentFee = widget.gasFees[currentPriority]!;

    return Container(
      decoration: BoxDecoration(
        color: C.current.lightBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: C.current.sub01.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 선택된 우선순위 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getPriorityLabel(currentPriority),
                style: fontSB(16, color: C.current.mainText),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_formatEth(currentFee)} ETH',
                    style: fontSB(14, color: C.current.mainText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gas: ${currentFee.gasPrice.toRadixString(10)}',
                    style: fontR(12, color: C.current.sub01),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 예상 시간 표시
          Text(
            'Estimated confirmation time: ${_getEstimatedTime(currentPriority)}',
            style: fontR(12, color: C.current.sub01),
          ),

          const SizedBox(height: 16),

          // 슬라이더 부분
          Column(
            children: [
              // 슬라이더 위 텍스트 라벨
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Slow',
                    style: fontR(12,
                        color: currentPriority == GasPriority.slow
                            ? C.current.primary
                            : C.current.sub01),
                  ),
                  Text(
                    'Average',
                    style: fontR(12,
                        color: currentPriority == GasPriority.medium
                            ? C.current.primary
                            : C.current.sub01),
                  ),
                  Text(
                    'Fast',
                    style: fontR(12,
                        color: currentPriority == GasPriority.fast
                            ? C.current.primary
                            : C.current.sub01),
                  ),
                ],
              ),

              // 슬라이더
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  activeTrackColor: C.current.primary,
                  inactiveTrackColor: C.current.primary.withOpacity(0.2),
                  thumbColor: C.current.primary,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  overlayColor: C.current.primary.withOpacity(0.2),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20,
                  ),
                ),
                child: Slider(
                  value: _sliderValue,
                  min: 0.0,
                  max: 1.0,
                  divisions: 2, // 3개의 위치(slow, medium, fast)
                  onChanged: (value) {
                    setState(() {
                      _sliderValue = value;
                    });

                    // 변경된 우선순위 콜백 호출
                    final newPriority = _getCurrentPriority();
                    if (newPriority != widget.selectedPriority) {
                      widget.onPrioritySelected(newPriority);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Advanced Gas Settings 버튼
          InkWell(
            onTap: () {
              // Show advanced gas settings bottomsheet
              AdvancedGasSettingsBottomSheet.show(
                context,
                gasFees: widget.gasFees,
                selectedPriority: currentPriority,
                onPrioritySelected: widget.onPrioritySelected,
                onCustomGasSet: widget.onCustomGasSet,
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
        ],
      ),
    );
  }
}
