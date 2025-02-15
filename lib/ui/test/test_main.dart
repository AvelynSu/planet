import 'package:flutter/material.dart';
import 'package:planet/ui/common/generate_planet.dart';
import 'package:planet/ui/common/test_default_button.dart';
import 'package:planet/ui/test/wallet/generate_wallet_screen.dart';
import 'package:planet/ui/test/wallet/get_balance_test_screen.dart';
import 'package:planet/ui/test/wallet/hd_wallet/generate_hd_wallet_screen.dart';
import 'package:planet/ui/test/wallet/withdrawal_sceren.dart';

import '../../custom_theme.dart';

void main() {
  CustomThemeMode.instance;
  runApp(const TestApp());
}

class TestApp extends StatefulWidget {
  const TestApp({super.key});

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: CustomThemeMode.themeMode,
      builder: (context, mode, child) {
        return MaterialApp(
          // MaterialApp 을 const 로 바꾸면 앱 색깔 안바뀜
          debugShowCheckedModeBanner: false,
          home: TestMainScreen(),
        );
      },
    );
  }
}

class TestMainScreen extends StatefulWidget {
  const TestMainScreen({super.key});

  @override
  State<TestMainScreen> createState() => _TestMainScreenState();
}

class _TestMainScreenState extends State<TestMainScreen> {
  String data = "Shift Function";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.current.appBarBackground,
        title: Text(
          "Shift Fn",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CustomColors.current.appbarText.withValues(alpha: 0.9),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: CustomColors.current.background,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlanetWidget(
              data: data,
              size: 200,
            ),
            const SizedBox(height: 40),
            TestDefaultButton(
              title: '행성 변경',
              onTap: () {
                data = DateTime.now().toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            TestDefaultButton(
              title: 'HD 월렛 테스트',
              onTap: () {
                GenerateHdWalletScreen.push(context);
              },
            ),
            const SizedBox(height: 12),
            TestDefaultButton(
              title: '월렛 테스트',
              onTap: () {
                TestGenerateWalletScreen.push(context);
              },
            ),
            const SizedBox(height: 12),
            TestDefaultButton(
              title: '잔액 불러오기 테스트',
              onTap: () {
                TestGetBalanceTestScreen.push(context);
              },
            ),
            TestDefaultButton(
              title: '출금',
              onTap: () {
                TestWithdrawScreen.push(context);
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
