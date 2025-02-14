import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/create_wallet/cubit/create_wallet_cubit.dart';

import '../../../../enum/screen_status.dart';
import '../util/app_ui.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const CreateWalletScreen());
  }

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => CreateWalletCubit(),
      child: BlocListener<CreateWalletCubit, CreateWalletState>(
        listener: (context, state) async {
          if (state.status == ScreenStatus.fail) {}

          if (state.status == ScreenStatus.success) {}
        },
        listenWhen: (pre, cur) => pre.status != cur.status,
        child: BlocBuilder<CreateWalletCubit, CreateWalletState>(
          builder: (context, state) {
            return BaseScaffold(
              onBack: () {
                Navigator.pop(context);
              },
              backgroundColor: CustomColors.current.background,
              body: Container(
                padding: EdgeInsets.symmetric(horizontal: hPadding),
                child: Column(
                  children: [
                    // GridView.builder(
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   gridDelegate:
                    //       const SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: 3, // 한 행에 3개의 아이템
                    //     mainAxisSpacing: 10.0, // 수직 간격
                    //     crossAxisSpacing: 10.0, // 수평 간격
                    //     // childAspectRatio 대신 mainAxisExtent 사용
                    //     mainAxisExtent: 40, // 각 아이템의 높이를 100으로 고정
                    //   ),
                    //   shrinkWrap: true,
                    //   itemBuilder: (context, i) {
                    //     var items = state.mnemonic.split(" ");
                    //     var item = items.length > i ? items[i] : "";
                    //     return Container(
                    //       decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         borderRadius: BorderRadius.circular(8),
                    //         border: Border.all(color: Colors.grey[300]!),
                    //       ),
                    //       child: Center(
                    //         child: Text(item),
                    //       ),
                    //     );
                    //   },
                    // )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
