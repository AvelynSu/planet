import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../enum/screen_status.dart';
import '../util/app_ui.dart';
import 'cubit/sample_cubit.dart';

class PlanetsScreen extends StatefulWidget {
  const PlanetsScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const PlanetsScreen());
  }

  @override
  State<PlanetsScreen> createState() => _PlanetsScreenState();
}

class _PlanetsScreenState extends State<PlanetsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => PlanetsCubit(),
      child: BlocListener<PlanetsCubit, PlanetsState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<PlanetsCubit, PlanetsState>(
          builder: (context, state) {
            return Container();
          },
        ),
      ),
    );
  }
}
