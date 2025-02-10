import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../enum/screen_status.dart';
import '../../util/app_ui.dart';
import 'cubit/sample_cubit.dart';

class SampleScreen extends StatefulWidget {
  const SampleScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const SampleScreen());
  }

  @override
  State<SampleScreen> createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SampleCubit(),
      child: BlocListener<SampleCubit, SampleState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<SampleCubit, SampleState>(
          builder: (context, state) {
            return Container();
          },
        ),
      ),
    );
  }
}
