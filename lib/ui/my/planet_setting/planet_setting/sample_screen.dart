import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/custom_image.dart';
import 'package:planet/ui/common/generate_planet.dart';
import 'package:planet/ui/common/planet_address_bottom_sheet.dart';
import 'package:planet/ui/common/setting_row_tile.dart';
import 'package:planet/ui/my/planet_setting/planet_setting/backup_mnemonic_screen.dart';

import '../../../../enum/screen_status.dart';
import '../../../../util/app_ui.dart';
import '../../../../util/app_util.dart';
import '../../change_nickname/change_nickname_screen.dart';
import 'backup_privacte_key_screen.dart';
import 'cubit/sample_cubit.dart';

class PlanetSettingScreen extends StatefulWidget {
  const PlanetSettingScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const PlanetSettingScreen());
  }

  @override
  State<PlanetSettingScreen> createState() => _PlanetSettingScreenState();
}

class _PlanetSettingScreenState extends State<PlanetSettingScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => PlanetSettingCubit(
        apiRepository: context.read<ApiRepository>(),
        appBloc: context.read<AppBloc>(),
      )..initialize(),
      child: BlocListener<PlanetSettingCubit, PlanetSettingState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<PlanetSettingCubit, PlanetSettingState>(
          builder: (context, state) {
            return BaseScaffold(
              onBack: () {
                Navigator.pop(context);
              },
              body: Container(
                child: Column(
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            ChangeNicknameScreen.push(context,
                                planet: state.planet);
                          },
                          child: _name(state.planet),
                        ),

                        ///
                        SettingRowTile(
                          onTap: () {
                            PlanetAddressBottomSheet.show(context,
                                planet: state.planet);
                          },
                          title: "Address",
                          subText: AppUtil.shortenWalletAddress(
                              state.planet.address),
                          showArrow: false,
                        ),
                        SettingRowTile(
                          onTap: () {
                            BackupMnemonicScreen.push(context,
                                planet: state.planet);
                          },
                          title: "Backup Mnemonic Phrase",
                        ),
                        SettingRowTile(
                          onTap: () {
                            BackupPrivateKeyScreen.push(context,
                                planet: state.planet);
                          },
                          title: "Backup Private Key",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _name(Planet planet) {
    return Container(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 50),
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ETHERIUM",
                  style: fontR(16, color: C.current.sub01),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      planet.name,
                      style: fontM(24, color: C.current.mainText),
                    ),
                    const SizedBox(width: 8),
                    CustomImage(
                      path: "icons/ic_edit.svg",
                      color: C.current.sub01,
                    ),
                  ],
                ),
              ],
            ),
          ),
          PlanetWidget(
            data: planet.name,
            size: 40,
          ),
        ],
      ),
    );
  }
}
