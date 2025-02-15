import 'package:flutter/material.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/service/wallet/wallet_service.dart';
import 'package:planet/ui/common/test_default_button.dart';
import 'package:planet/ui/test/wallet/hd_wallet/hd_wallet_tile.dart';
import 'package:planet/ui/util/app_ui.dart';

import '../../../../custom_theme.dart';
import '../../../util/data/test_hd_wallet.dart';

class RestoreHdWalletScreen extends StatefulWidget {
  const RestoreHdWalletScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const RestoreHdWalletScreen());
  }

  @override
  State<RestoreHdWalletScreen> createState() => _RestoreHdWalletScreenState();
}

class _RestoreHdWalletScreenState extends State<RestoreHdWalletScreen> {
  WalletService walletService = WalletService();

  List<PlanetDto> ethAddress = [];
  List<PlanetDto> btcAddress = [];
  List<PlanetDto> solAddress = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.current.background,
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: CustomColors.current.appbarText.withValues(alpha: 0.9)),
        backgroundColor: CustomColors.current.appBarBackground,
        title: Text(
          "Restore Wallet",
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
              TestDefaultButton(
                  title: "복구 하기",
                  onTap: () async {
                    List<Future<List<PlanetDto>>> tasks = [];
                    tasks.add(walletService.recoverAddresses(
                        NetworkType.ethereum,
                        TestHdWallet.mnemonic,
                        TestHdWallet.ethIdx));

                    tasks.add(walletService.recoverAddresses(
                      NetworkType.solana,
                      TestHdWallet.mnemonic,
                      TestHdWallet.solIdx,
                    ));
                    tasks.add(walletService.recoverAddresses(
                        NetworkType.bitcoin,
                        TestHdWallet.mnemonic,
                        TestHdWallet.btcIdx));

                    var result = await Future.wait(tasks);
                    ethAddress = result[0];
                    solAddress = result[1];
                    btcAddress = result[2];
                    setState(() {});
                  }),
              const SizedBox(height: 24),

              // 행성들
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "ETH\n",
                          style: fontB(16, color: CustomColors.current.text),
                        ),
                        ...ethAddress.reversed
                            .map((e) => HdWalletTile(address: e)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "BTC\n",
                          style: fontB(16, color: CustomColors.current.text),
                        ),
                        ...btcAddress.reversed
                            .map((e) => HdWalletTile(address: e)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "SOL\n",
                          style: fontB(16, color: CustomColors.current.text),
                        ),
                        ...solAddress.reversed.map(
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
