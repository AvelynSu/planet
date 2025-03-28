import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/bounce_button.dart';
import 'package:planet/ui/common/custom_image.dart';
import 'package:planet/ui/common/default_dialog.dart';
import 'package:planet/ui/common/generate_planet.dart';
import 'package:planet/ui/transaction/transfer/select_friend/qr_scanner_screen.dart';

import '../../../../enum/screen_status.dart';
import '../../../../util/app_ui.dart';
import '../../../../util/app_util.dart';
import '../../../common/small_round_button.dart';
import 'cubit/select_friends_cubit.dart';
import 'friend_search_field.dart';

class SelectFriendScreen extends StatefulWidget {
  final Function(Planet) onSelect;

  const SelectFriendScreen({
    super.key,
    required this.onSelect,
  });

  static Future<Planet?> push(
    BuildContext context, {
    required Function(Planet) onSelect,
  }) async {
    return await AppUi.push(context, SelectFriendScreen(onSelect: onSelect));
  }

  @override
  State<SelectFriendScreen> createState() => _SelectFriendScreenState();
}

class _SelectFriendScreenState extends State<SelectFriendScreen> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SelectFriendsCubit(
        appBloc: context.read<AppBloc>(),
        apiRepository: context.read<ApiRepository>(),
      )..initialize(),
      child: BlocListener<SelectFriendsCubit, SelectFriendsState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<SelectFriendsCubit, SelectFriendsState>(
          builder: (context, state) {
            var cubit = context.read<SelectFriendsCubit>();
            return BaseScaffold(
              onBack: () {
                Navigator.pop(context);
              },
              suffix: CustomImage(
                width: 32,
                path: "icons/ic_capture.svg",
                onTap: () async {
                  var result = await QrScannerScreen.push(context);
                  if (result != null) {
                    cubit.onUpdateSearchValue(result);
                  }
                },
              ),
              title: AppLocalizations.of(context)?.transaction_transfer ?? '',
              body: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 텍스트 필드
                        FriendSearchField(
                          controller: controller,
                          onChange: (text) {
                            cubit.onUpdateSearchValue(text);
                          },
                          initialValue: state.searchText,
                        ),

                        /// 검색결과 없는 경우 주소 보여주기 (플레이스홀더 플래닛)
                        if (state.searchText.isNotEmpty &&
                            state.filtered.isEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _listGroupTitle(AppLocalizations.of(context)
                                      ?.transfer_address ??
                                  ''),
                              _unregisteredPlanetTile(
                                Planet(address: state.searchText),
                                () {
                                  if (AppUtil.isValidEthereumAddress(
                                      state.searchText)) {
                                    widget.onSelect(
                                        Planet(address: state.searchText));
                                  } else {
                                    DefaultDialog.showTimerDialog(context,
                                        description: AppLocalizations.of(
                                                    context)
                                                ?.transfer_invalid_address ??
                                            '');
                                  }
                                },
                              ),
                            ],
                          ),

                        /// 친구 목록
                        if (state.filtered.isNotEmpty)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _listGroupTitle(AppLocalizations.of(context)
                                        ?.transfer_planets_list ??
                                    ''),
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    // 리스트 아이템 + 하단 패딩을 위한 추가 항목
                                    itemCount: state.filtered.length + 1,
                                    itemBuilder: (context, index) {
                                      // 마지막 인덱스는 하단 패딩
                                      if (index == state.filtered.length) {
                                        return SizedBox(
                                            height:
                                                AppUi.bottomPadding(context));
                                      }

                                      // 일반 리스트 아이템
                                      return _planetTile(
                                        state.filtered[index],
                                        () {
                                          widget
                                              .onSelect(state.filtered[index]);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      bottom: AppUi.bottomPadding(context),
                    ),
                    child: SmallRoundButton(
                      onTap: () async {
                        // final data =
                        // await Clipboard.getData('text/plain');
                        // if (data?.text != null) {
                        //   _controller.text = data!.text!;
                        //   _validateInput(_controller.text);
                        //   cubit.updateMnimonic(_controller.text);
                        // }
                      },
                      iconPath: "icons/ic_copy.svg",
                      title:
                          AppLocalizations.of(context)?.wallet_import_paste ??
                              '',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _listGroupTitle(String title) {
    return Container(
      padding:
          EdgeInsets.only(left: hPadding, right: hPadding, top: 24, bottom: 12),
      child: Text(
        title,
        style: fontR(16, color: C.current.sub01),
      ),
    );
  }

  _unregisteredPlanetTile(Planet planet, Function onTap) {
    return BounceButton(
      onTap: () {
        onTap();
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: hPadding),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Stack(alignment: Alignment.center, children: [
                    PlanetComponent(
                      network: planet.networkType,
                      data: "planetWallet",
                      size: 40,
                    ),
                    Positioned.fill(
                      child: Container(
                        color: C.current.background.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      "?",
                      style: fontB(20,
                          color: C.current.mainText.withValues(alpha: 0.6)),
                    )
                  ]),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      planet.address,
                      style: fontR(16, color: C.current.mainText),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CustomImage(
              path: "icons/ic_small_arrow.svg",
              width: 16,
            )
          ],
        ),
      ),
    );
  }

  _planetTile(
    Planet planet,
    Function onTap,
  ) {
    return BounceButton(
      onTap: () {
        onTap();
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: hPadding),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  PlanetComponent(
                    network: planet.networkType,
                    data: planet.name,
                    size: 40,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planet.name,
                        style: fontR(16, color: C.current.mainText),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        AppUtil.shortenWalletAddress(planet.address),
                        style: fontR(14, color: C.current.sub01),
                      ),
                    ],
                  )
                ],
              ),
            ),
            CustomImage(
              path: "icons/ic_small_arrow.svg",
              width: 16,
            )
          ],
        ),
      ),
    );
  }
}
