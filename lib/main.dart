import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/ui/start/set_nickname/set_nickname_screen.dart';

import 'bloc/app/app_bloc.dart';
import 'bloc/app/app_event.dart';
import 'custom_theme.dart';

void main() {
  CustomThemeMode.instance;
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiRepository>(
          create: (_) => ApiRepository(),
        ),
      ],
      child: App(),
    ),
  );
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
        return BlocProvider<AppBloc>(
          create: (context) => AppBloc(
            apiRepository: context.read<ApiRepository>(),
          )..add(AppInitialize()),
          child: MaterialApp(
            title: "Planet Wallet",
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'WorkSans',
            ),
            home: AppScreen(),
          ),
        );
      },
    );
  }
}

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  @override
  Widget build(BuildContext context) {
    return const SetNicknameScreen();
  }
}
