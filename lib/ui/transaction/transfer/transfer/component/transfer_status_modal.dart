import 'package:flutter/material.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/enum/gas_priority.dart';

/// Loading dialog shown during transaction processing
class TransferLoadingDialog extends StatelessWidget {
  final GasPriority gasPriority;

  const TransferLoadingDialog({
    super.key,
    required this.gasPriority,
  });

  static Future<void> show(
    BuildContext context, {
    required GasPriority gasPriority,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TransferLoadingDialog(gasPriority: gasPriority),
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
              'Processing Transaction',
              style: fontSB(18, color: C.current.mainText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please wait while your transaction is being processed. This may take a few minutes.',
              style: fontR(14, color: C.current.sub01),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
