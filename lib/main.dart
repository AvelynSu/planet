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
        backgroundColor: CustomColors.current.appBarBackground,
        title: Text(
          "Suyeon's Planet",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CustomColors.current.appbarText,
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
              data: "parksuyeon",
              size: 200,
            ),
            const SizedBox(height: 40),
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
                  color: CustomColors.current.text,
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
