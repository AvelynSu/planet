import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/ui/app/app_view.dart';
import 'package:planet/ui/common/splash_screen.dart';
import 'package:planet/ui/start/start/start_screen.dart';

import 'bloc/app/app_bloc.dart';
import 'bloc/app/app_event.dart';
import 'custom_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) async {},
      listenWhen: (pre, cur) => cur != pre,
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          Widget screen = const SplashScreen();
          if (state is AppUnInitialized) {
            if (state.requiredSign) {
              screen = const StartScreen();
            } else if (state.requiredFirstPlanetNickname) {}
          } else if (state is AppLoaded) {
            screen = const AppView();
          }

          return screen;
        },
      ),
    );
  }
}
