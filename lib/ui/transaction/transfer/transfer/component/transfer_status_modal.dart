import 'package:flutter/material.dart';
import 'package:planet/l10n/app_localizations.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/enum/gas_priority.dart';
import 'package:planet/ui/common/small_round_button.dart';

/// Loading dialog shown during transaction processing
class TransferLoadingDialog extends StatelessWidget {
  final GasPriority gasPriority;
  final VoidCallback? onCancel;

  const TransferLoadingDialog({
    super.key,
    required this.gasPriority,
    this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required GasPriority gasPriority,
    VoidCallback? onCancel,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TransferLoadingDialog(
        gasPriority: gasPriority,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: C.current.sub02,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: C.current.primary,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.transfer_processing ?? '',
              style: fontSB(18, color: C.current.mainText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)?.transfer_processing_wait ?? '',
              style: fontR(14, color: C.current.sub01),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            SmallRoundButton(
              title: AppLocalizations.of(context)!.confirm,
              onTap: () {
                Navigator.pop(context);

                // 취소 콜백 호출
                if (onCancel != null) {
                  onCancel!();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
