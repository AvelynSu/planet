import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_state.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/enum/gas_priority.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/model/transfer_fee.dart';
import 'package:planet/service/wallet/wallet_balance_service.dart';
import 'package:planet/service/wallet/walltet_transfer_service.dart';
import 'package:planet/ui/common/default_button.dart';
import 'package:planet/ui/util/app_ui.dart';
import 'package:planet/ui/util/data/token_data.dart';

class TestTransferScreen extends StatefulWidget {
  const TestTransferScreen({super.key});

  @override
  State<TestTransferScreen> createState() => _TestTransferScreenState();
}

class _TestTransferScreenState extends State<TestTransferScreen> {
  PlanetDto? planet;
  String address = "0x5A7094F64E580a73051E4F6171A77025FfaA92E8";

  @override
  void initState() {
    super.initState();

    planet = (context.read<AppBloc>().state as AppLoaded).current;

    getBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Column(
        children: [
          SizedBox(
            height: AppUi.statusBarHeight(context),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...balance
                    .map(
                      (i, e) => MapEntry(
                        i,
                        vertical(
                          title: i,
                          value: "$e",
                        ),
                      ),
                    )
                    .values
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...gas
                    .map(
                      (i, e) => MapEntry(
                        i,
                        vertical(
                          title: i.name,
                          value: e.formatted,
                        ),
                      ),
                    )
                    .values
              ],
            ),
          ),
          const SizedBox(height: 12),
          _label(title: "받는 주소", value: address),
          // _label(title: "자산", value: "$balance"),
          // _label(title: "자산", value: "$balance"),
          // _label(title: "자산", value: "$balance"),
          // _label(title: "자산", value: "$balance"),
          // _label(title: "자산", value: "$balance"),
          const SizedBox(height: 12),
          DefaultButton(
            title: "가스비 산출",
            onTap: () {
              getGasFee();
            },
          ),
          const SizedBox(height: 12),
          DefaultButton(
            title: "보내기",
            onTap: () {
              getBalance();
            },
          ),
        ],
      ),
    );
  }

  Map<String, double> balance = {};

  getBalance() async {
    WalletBalanceService service = WalletBalanceService();

    final balance = await service.getAllTokenBalances(
      walletAddress: planet?.address ?? "",
      supportedTokens: TokenData.ethTokens,
    );
    this.balance = balance;
    setState(() {});
  }

  getGasFee() async {
    var service = WalletTransferService();
    var res = await service.estimateGasFeesByPriority();
    gas = res;
    setState(() {});
  }

  Map<GasPriority, TransferFee> gas = {};

  vertical({
    required String title,
    required String value,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            title,
            style: fontR(12, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: fontR(16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  _label({required String title, required String value}) {
    return Container(
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title ",
            style: fontR(13, color: Colors.white),
          ),
          Expanded(
            child: Text(
              value,
              style: fontR(12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
