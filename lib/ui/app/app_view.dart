import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/ui/common/default_button.dart';

import '../../enum/menu_type.dart';
import '../common/base_scaffold.dart';
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
                child: _buildMainView(type),
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
        return Container();
      case MenuType.planets:
        return Container();
      case MenuType.my:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DefaultButton(
                title: "로그아웃",
                onTap: () {
                  context.read<AppBloc>().add(AppSignOut());
                },
              ),
            ],
          ),
        );
    }
  }
}
