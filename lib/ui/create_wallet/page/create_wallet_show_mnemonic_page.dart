import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/ui/create_wallet/cubit/create_wallet_cubit.dart';

class CreateWalletShowMnemonicPage extends StatefulWidget {
  const CreateWalletShowMnemonicPage({super.key});

  @override
  State<CreateWalletShowMnemonicPage> createState() =>
      _CreateWalletShowMnemonicPageState();
}

class _CreateWalletShowMnemonicPageState
    extends State<CreateWalletShowMnemonicPage> {
  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CreateWalletCubit>();
    var state = cubit.state;

    return Column(
      children: [
        const SizedBox(height: 100),
        if (state.mnemonic.isNotEmpty)
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 한 행에 3개의 아이템
              mainAxisSpacing: 10.0, // 수직 간격
              crossAxisSpacing: 10.0, // 수평 간격
              // childAspectRatio 대신 mainAxisExtent 사용
              mainAxisExtent: 40, // 각 아이템의 높이를 100으로 고정
            ),
            itemCount: state.mnemonic.split(" ").length,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              var items = state.mnemonic.split(" ");
              var item = items.length > i ? items[i] : "";
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Text(item),
                ),
              );
            },
          ),
      ],
    );
  }
}
