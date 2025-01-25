import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:planet/test_screen.dart';

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
        return const MaterialApp(
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.getAppBarBackground(),
        title: Container(),
      ),
      backgroundColor: CustomColors.getBackground,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                CustomThemeMode.change();
              },
              child: Text(
                'Planet Wallet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.getText(l: Colors.yellow), // 여기서 색상 적용
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const TestScreen(),
                  ),
                );
              },
              child: const Text('다음 화면'),
            ),
          ],
        ),
      ),
    );
  }
}
