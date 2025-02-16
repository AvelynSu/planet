import 'package:flutter/material.dart';
import 'package:planet/ui/home/sample_screen.dart';

import '../../enum/menu_type.dart';
import '../common/base_scaffold.dart';
import '../my/my_screen.dart';
import '../planets/sample_screen.dart';
import 'bottom_bar.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<StatefulWidget> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  MenuType type = MenuType.home;

  @override
  Widget build(BuildContext context) {
    // var user = (context.read<AppBloc>().state as AppLoaded).user;

    return BaseScaffold(
      // backgroundColor: Colors.red,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  child: _buildMainView(type),
                ),
              ),
            ),

            /// 바텀 바
            BottomBar(
              onTap: (type) {
                this.type = type;
                setState(() {});
              },
              selectedType: type,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView(MenuType menuType) {
    switch (menuType) {
      case MenuType.home:
        return const HomeScreen();
      case MenuType.planets:
        return const PlanetsScreen();
      case MenuType.my:
        return const MyScreen();
    }
  }
}
