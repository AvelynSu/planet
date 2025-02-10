import 'package:flutter/material.dart';
import 'package:planet/generate_planet/generate_planet.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/wallet/generate_wallet_screen.dart';
import 'package:planet/ui/wallet/get_balance_test_screen.dart';
import 'package:planet/ui/wallet/hd_wallet/generate_hd_wallet_screen.dart';
import 'package:planet/ui/wallet/withdrawal_sceren.dart';

import 'custom_theme.dart';

void main() {
  CustomThemeMode.instance;
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: CustomThemeMode.themeMode,
      builder: (context, mode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: FirstScreen(),
        );
      },
    );
  }
}

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
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
            DefaultButton(
              title: '행성 변경',
              onTap: () {
                data = DateTime.now().toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            DefaultButton(
              title: 'HD 월렛 테스트',
              onTap: () {
                GenerateHdWalletScreen.push(context);
              },
            ),
            const SizedBox(height: 12),
            DefaultButton(
              title: '월렛 테스트',
              onTap: () {
                GenerateWalletScreen.push(context);
              },
            ),
            const SizedBox(height: 12),
            DefaultButton(
              title: '잔액 불러오기 테스트',
              onTap: () {
                GetBalanceTestScreen.push(context);
              },
            ),
            DefaultButton(
              title: '출금',
              onTap: () {
                WithdrawScreen.push(context);
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
