import 'package:flutter/material.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/service/hd_wallet_service.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/util/app_ui.dart';

import '../../custom_theme.dart';
import '../../generate_planet/generate_planet.dart';

class GenerateHdWalletScreen extends StatefulWidget {
  const GenerateHdWalletScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const GenerateHdWalletScreen());
  }

  @override
  State<GenerateHdWalletScreen> createState() => _GenerateHdWalletScreenState();
}

class _GenerateHdWalletScreenState extends State<GenerateHdWalletScreen> {
  String mnemonic = "";
  int ethIdx = 0;
  List<String> ethAddress = [];

  int btcIdx = 0;
  List<String> btcAddress = [];

  int solIdx = 0;
  List<String> solAddress = [];

  HDWalletService walletService = HDWalletService();

  @override
  void initState() {
    mnemonic = walletService.generateMnemonic();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(btcAddress);
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
              _label(title: "니모닉", value: mnemonic),
              const SizedBox(height: 12),

              /// 버튼들
              Row(
                children: [
                  Expanded(
                    child: DefaultButton(
                      title: "이더리움",
                      onTap: () async {
                        var address = await walletService.generateHDAddress(
                            NetworkType.ethereum, mnemonic, ethIdx);
                        ethIdx += 1;
                        ethAddress.add(address);
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
                            NetworkType.bitcoin, mnemonic, btcIdx);
                        btcIdx += 1;
                        btcAddress.add(address);
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
                            NetworkType.solana, mnemonic, solIdx);
                        solIdx += 1;
                        solAddress.add(address);
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
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
                        ...ethAddress.reversed.map((e) => _planetTile(e)),
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
                        ...btcAddress.reversed.map((e) => _planetTile(e)),
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
                        ...solAddress.reversed.map((e) => _planetTile(e)),
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

  _planetTile(String address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          PlanetWidget(
            data: address,
            size: 50,
          ),
          const SizedBox(height: 24),
          Text(
            address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: fontR(12,
                color: CustomColors.current.text.withValues(alpha: 0.4)),
          ),
        ],
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
