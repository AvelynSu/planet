import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:planet/generate_planet/generate_planet.dart';
import 'package:planet/ui/common/test_default_button.dart';
import 'package:planet/ui/test/test_wallet_service.dart';
import 'package:planet/ui/util/app_ui.dart';
import 'package:web3dart/credentials.dart';

import '../../../custom_theme.dart';

class TestGenerateWalletScreen extends StatefulWidget {
  const TestGenerateWalletScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const TestGenerateWalletScreen());
  }

  @override
  State<TestGenerateWalletScreen> createState() =>
      _TestGenerateWalletScreenState();
}

class _TestGenerateWalletScreenState extends State<TestGenerateWalletScreen> {
  String mnemonic = "";
  Uint8List seed = Uint8List(0);
  EthPrivateKey? privateKey;
  String publicKey = "";
  String address = "";

  TestWalletService walletService = TestWalletService();

  @override
  Widget build(BuildContext context) {
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
              address.isEmpty
                  ? Container(
                      alignment: Alignment.center,
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      child: Text(
                        "?",
                        style: fontR(100),
                      ),
                    )
                  : PlanetWidget(
                      data: address,
                      size: 200,
                    ),
              const SizedBox(height: 20),
              _label(title: "니모닉", value: mnemonic),
              _label(title: "씨드", value: "$seed"),
              _label(title: "개인키", value: "${privateKey?.privateKey}"),
              _label(title: "공개키", value: publicKey),
              _label(title: "주소", value: address),
              const SizedBox(height: 12),

              TestDefaultButton(
                title: "지갑 생성",
                onTap: () async {
                  var value = walletService.generateMnemonic();
                  mnemonic = value;
                  seed = walletService.mnemonicToSeed(value);
                  privateKey = walletService.seedToPrivateKey(seed);
                  publicKey = walletService.privateKeyToPublicKey(privateKey!);
                  address = walletService.publicKeyToAddress(publicKey);
                  setState(() {});
                },
              ),

              /// 지갑주소 순차적으로 생성하는거..
              // Column(
              //   children: [
              //     DefaultButton(
              //       title: "니모닉 생성",
              //       onTap: () {
              //         var value = walletService.generateMnemonic();
              //         mnemonic = value;
              //
              //         seed = Uint8List(0);
              //         private = null;
              //         public = "";
              //         address = "";
              //
              //         setState(() {});
              //       },
              //     ),
              //     const SizedBox(height: 12),
              //     DefaultButton(
              //       title: "씨드 생성",
              //       onTap: () {
              //         var value = walletService.mnemonicToSeed(mnemonic);
              //         seed = value;
              //
              //         private = null;
              //         public = "";
              //         address = "";
              //
              //         setState(() {});
              //       },
              //     ),
              //     const SizedBox(height: 12),
              //     DefaultButton(
              //       title: "개인키 생성",
              //       onTap: () {
              //         var value = walletService.seedToPrivateKey(seed);
              //         private = value;
              //
              //         public = "";
              //         address = "";
              //         setState(() {});
              //       },
              //     ),
              //     const SizedBox(height: 12),
              //     DefaultButton(
              //       title: "공개키 생성",
              //       onTap: () {
              //         var value = walletService.privateKeyToPublicKey(private!);
              //         public = value;
              //
              //         address = "";
              //         setState(() {});
              //       },
              //     ),
              //     const SizedBox(height: 12),
              //     DefaultButton(
              //       title: "지갑주소 생성",
              //       onTap: () {
              //         var value = walletService.publicKeyToAddress(public);
              //         address = value;
              //         setState(() {});
              //       },
              //     ),
              //   ],
              // ),
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
