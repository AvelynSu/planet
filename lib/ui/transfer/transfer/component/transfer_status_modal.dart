import 'package:flutter/material.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/util/app_util.dart';

/// Loading dialog shown during transaction processing
class TransferLoadingDialog extends StatelessWidget {
  const TransferLoadingDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TransferLoadingDialog(),
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
          color: C.current.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
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

/// Success dialog shown after transaction is completed
class TransferSuccessDialog extends StatelessWidget {
  final String amount;
  final String symbol;
  final String recipient;

  const TransferSuccessDialog({
    super.key,
    required this.amount,
    required this.symbol,
    required this.recipient,
  });

  static Future<void> show(
    BuildContext context, {
    required String amount,
    required String symbol,
    required String recipient,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TransferSuccessDialog(
        amount: amount,
        symbol: symbol,
        recipient: recipient,
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
          color: C.current.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.green, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Transaction Successful',
              style: fontSB(18, color: C.current.mainText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: fontR(14, color: C.current.sub01),
                children: [
                  const TextSpan(text: 'You have successfully sent '),
                  TextSpan(
                    text: '$amount $symbol',
                    style: fontSB(14, color: C.current.mainText),
                  ),
                  const TextSpan(text: ' to '),
                  TextSpan(
                    text: AppUtil.shortenWalletAddress(recipient),
                    style: fontSB(14, color: C.current.mainText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            BounceButton(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: C.current.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Done',
                    style: fontSB(16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
