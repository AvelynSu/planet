import 'package:flutter/material.dart';
import 'package:planet/ui/common/test_default_button.dart';

import '../../../custom_theme.dart';
import '../../../service/wallet/wallet_balance_service.dart';
import '../../util/app_ui.dart';
import '../../util/data/token_data.dart';

class TestGetBalanceTestScreen extends StatefulWidget {
  const TestGetBalanceTestScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const TestGetBalanceTestScreen());
  }

  @override
  State<TestGetBalanceTestScreen> createState() =>
      _TestGetBalanceTestScreenState();
}

class _TestGetBalanceTestScreenState extends State<TestGetBalanceTestScreen> {
  var address = "0x5a7094f64e580a73051e4f6171a77025ffaa92e8";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.current.background,
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: CustomColors.current.appbarText.withValues(alpha: 0.9)),
        backgroundColor: CustomColors.current.appBarBackground,
        title: Text(
          "잔액 불러오기",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CustomColors.current.appbarText.withValues(alpha: 0.9),
          ),
        ),
      ),
      body: Column(
        children: [
          // TestDefaultButton(
          //     title: "지갑이 보유한 이더리움",
          //     onTap: () async {
          //       final service = TokenService(
          //         rpcUrl:
          //             'https://mainnet.infura.io/v3/e2e92d65ad42465e880c01edc6969cba',
          //       );
          //       // var tokens = await service.getWalletTokens(address);
          //
          //       service.dispose();
          //     }),
          TestDefaultButton(
            title: "내 잔액 확인",
            onTap: () async {
              final service = WalletBalanceService();

              try {
                // 모든 지원 토큰의 잔액 조회
                final balances = await service.getAllTokenBalances(
                  walletAddress: address,
                  supportedTokens: TokenData.ethTokens,
                );

                // 결과 출력
                balances.forEach((symbol, balance) {
                  debugPrint('$symbol: $balance');
                });
              } catch (e) {
                debugPrint('Error: $e');
              } finally {
                service.dispose(); // 리소스 해제
              }
            },
          ),
        ],
      ),
    );
  }
}
