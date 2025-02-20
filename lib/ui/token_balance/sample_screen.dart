import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/model/token_balance.dart';

import '../../../enum/screen_status.dart';
import '../util/app_ui.dart';
import 'cubit/sample_cubit.dart';

class TokenHistoryScreen extends StatefulWidget {
  final TokenBalance info;

  const TokenHistoryScreen({
    super.key,
    required this.info,
  });

  static push(
    BuildContext context, {
    required TokenBalance info,
  }) {
    AppUi.push(context, TokenHistoryScreen(info: info));
  }

  @override
  State<TokenHistoryScreen> createState() => _TokenHistoryScreenState();
}

class _TokenHistoryScreenState extends State<TokenHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => TokenBalanceCubit(
        appBloc: context.read<AppBloc>(),
        initialValue: widget.info,
      )..initialize(),
      child: BlocListener<TokenBalanceCubit, TokenBalanceState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<TokenBalanceCubit, TokenBalanceState>(
          builder: (context, state) {
            return Container();
          },
        ),
      ),
    );
  }
}
