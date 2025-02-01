import 'package:flutter/material.dart';
import 'package:planet/service/token_service.dart';
import 'package:planet/ui/common/default_button.dart';

import '../../custom_theme.dart';
import '../../service/wallet_balance_service.dart';
import '../util/app_ui.dart';

class GetBalanceTestScreen extends StatefulWidget {
  const GetBalanceTestScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, GetBalanceTestScreen());
  }

  @override
  State<GetBalanceTestScreen> createState() => _GetBalanceTestScreenState();
}

class _GetBalanceTestScreenState extends State<GetBalanceTestScreen> {
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
      body: Container(
        child: Column(
          children: [
            DefaultButton(
                title: "지갑이 보유한 이더리움",
                onTap: () async {
                  final service = TokenService(
                    rpcUrl:
                        'https://mainnet.infura.io/v3/e2e92d65ad42465e880c01edc6969cba',
                  );
                  var tokens = await service.getWalletTokens(address);

                  service.dispose();
                }),
            DefaultButton(
              title: "내 잔액 확인",
              onTap: () async {
                final service = WalletBalanceService(
                  rpcUrl:
                      'https://mainnet.infura.io/v3/e2e92d65ad42465e880c01edc6969cba',
                );

                try {
                  // 모든 지원 토큰의 잔액 조회
                  final balances = await service.getAllTokenBalances(
                    walletAddress: address,
                    supportedTokens: SupportedTokens.mainnetTokens,
                  );

                  // 결과 출력
                  balances.forEach((symbol, balance) {
                    print('$symbol: $balance');
                  });
                } catch (e) {
                  print('Error: $e');
                } finally {
                  service.dispose(); // 리소스 해제
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
