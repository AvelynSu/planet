import 'package:flutter/material.dart';
import 'package:planet/generate_planet/generate_planet.dart';

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
            InkWell(
              onTap: () {
                data = DateTime.now().toString();
                setState(() {});
                // CustomThemeMode.change();
              },
              child: Text(
                'Planet Wallet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.current.text.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
