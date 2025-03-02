import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/bloc.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/ui/add_planet/select_network_modal.dart';
import 'package:planet/ui/common/default_dialog.dart';
import 'package:planet/ui/common/planet_nickname_frame.dart';

import '../../../enum/screen_status.dart';
import '../../enum/network_type.dart';
import '../../util/app_ui.dart';
import 'cubit/add_planet_cubit.dart';

class AddPlanetScreen extends StatefulWidget {
  final NetworkType networkType;

  const AddPlanetScreen({
    super.key,
    required this.networkType,
  });

  static push(
    BuildContext context, {
    required NetworkType networkType,
  }) {
    AppUi.push(
        context,
        AddPlanetScreen(
          networkType: networkType,
        ));
  }

  @override
  State<AddPlanetScreen> createState() => _AddPlanetScreenState();
}

class _AddPlanetScreenState extends State<AddPlanetScreen> {
  late NetworkType networkType;

  @override
  void initState() {
    super.initState();
    networkType = widget.networkType;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var planets = (context.read<AppBloc>().state as AppLoaded).planets;

      if (planets.length < 20) {
        _updateNetwork();
      } else {
        DefaultDialog.show(context,
            description: "You can add up to 20 planets.");
      }
    });
  }

  _updateNetwork() {
    SelectNetworkModal.show(
      context,
      networkType: networkType,
      onSuccess: (network) {
        networkType = network;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AddPlanetCubit(
        appBloc: context.read<AppBloc>(),
        apiRepository: context.read<ApiRepository>(),
      )..initialize(),
      child: BlocListener<AddPlanetCubit, AddPlanetState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {
            Navigator.pop(context);
          }
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<AddPlanetCubit, AddPlanetState>(
          builder: (context, state) {
            var cubit = context.read<AddPlanetCubit>();
            return state.status != ScreenStatus.initial
                ? PlanetNicknameFrame(
                    status: state.status,
                    exception: state.exception,
                    nickname: state.nickname,
                    network: networkType,
                    onUpdateValue: (value) {
                      cubit.updateValue(value);
                    },
                    onChangeNetwork: () {
                      _updateNetwork();
                    },
                    onComplete: () {
                      cubit.onCreatePlanet(networkType);
                    },
                  )
                : Container();
          },
        ),
      ),
    );
  }
}
