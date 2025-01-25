import 'package:flutter/material.dart';

import 'custom_theme.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Container(
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
            ),
          ],
        ),
      ),
    );
  }
}
