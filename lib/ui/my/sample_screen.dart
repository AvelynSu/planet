import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../enum/screen_status.dart';
import '../util/app_ui.dart';
import 'cubit/sample_cubit.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const MyScreen());
  }

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => MyCubit(),
      child: BlocListener<MyCubit, MyState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<MyCubit, MyState>(
          builder: (context, state) {
            return Container();
          },
        ),
      ),
    );
  }
}
