import 'package:flutter/material.dart';
import 'package:planet/data/test_hd_wallet.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/service/hd_wallet_service.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/test/wallet/hd_wallet/hd_wallet_tile.dart';
import 'package:planet/ui/test/wallet/hd_wallet/restore_hd_wallet_screen.dart';
import 'package:planet/ui/util/app_ui.dart';

import '../../../../custom_theme.dart';

class GenerateHdWalletScreen extends StatefulWidget {
  const GenerateHdWalletScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const GenerateHdWalletScreen());
  }

  @override
  State<GenerateHdWalletScreen> createState() => _GenerateHdWalletScreenState();
}

class _GenerateHdWalletScreenState extends State<GenerateHdWalletScreen> {
  HDWalletService walletService = HDWalletService();

  @override
  void initState() {
    TestHdWallet.initialize();
    TestHdWallet.mnemonic = walletService.generateMnemonic();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(TestHdWallet.btcAddress);
    return Scaffold(
      backgroundColor: CustomColors.current.background,
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: CustomColors.current.appbarText.withValues(alpha: 0.9)),
        backgroundColor: CustomColors.current.appBarBackground,
        title: Text(
          "Create Wallet",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CustomColors.current.appbarText.withValues(alpha: 0.9),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _label(title: "니모닉", value: TestHdWallet.mnemonic),
              const SizedBox(height: 12),
              DefaultButton(
                  title: "복구 테스트",
                  onTap: () {
                    RestoreHdWalletScreen.push(context);
                  }),
              const SizedBox(height: 12),

              /// 버튼들
              Row(
                children: [
                  Expanded(
                    child: DefaultButton(
                      title: "이더리움",
                      onTap: () async {
                        var address = await walletService.generateHDAddress(
                            NetworkType.ethereum,
                            TestHdWallet.mnemonic,
                            TestHdWallet.ethIdx);
                        TestHdWallet.ethIdx += 1;
                        TestHdWallet.ethAddress.add(address);
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DefaultButton(
                      title: "비트코인",
                      onTap: () async {
                        var address = await walletService.generateHDAddress(
                            NetworkType.bitcoin,
                            TestHdWallet.mnemonic,
                            TestHdWallet.btcIdx);
                        TestHdWallet.btcIdx += 1;
                        TestHdWallet.btcAddress.add(address);
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DefaultButton(
                      title: "솔라나",
                      onTap: () async {
                        var address = await walletService.generateHDAddress(
                            NetworkType.solana,
                            TestHdWallet.mnemonic,
                            TestHdWallet.solIdx);
                        TestHdWallet.solIdx += 1;
                        TestHdWallet.solAddress.add(address);
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 행성들
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        ...TestHdWallet.ethAddress.reversed
                            .map((e) => HdWalletTile(address: e)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        ...TestHdWallet.btcAddress.reversed
                            .map((e) => HdWalletTile(address: e)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        ...TestHdWallet.solAddress.reversed.map(
                          (e) => HdWalletTile(address: e),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _label({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: fontR(14,
                color: CustomColors.current.text.withValues(alpha: 0.5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: fontR(14, color: CustomColors.current.text, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
