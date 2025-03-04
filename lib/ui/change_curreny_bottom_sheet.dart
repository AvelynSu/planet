import 'package:flutter/material.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/service/local_storage_service.dart';
import 'package:planet/ui/common/custom_bottom_sheet_frame.dart';
import 'package:planet/util/app_constant.dart';
import 'package:planet/util/app_ui.dart';

class ChangeCurrencyBottomSheet extends StatefulWidget {
  const ChangeCurrencyBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeCurrencyBottomSheet(),
    );
  }

  @override
  State<ChangeCurrencyBottomSheet> createState() =>
      _ChangeCurrenyBottomSheetState();
}

class _ChangeCurrenyBottomSheetState extends State<ChangeCurrencyBottomSheet> {
  String currency = "";

  @override
  void initState() {
    currency = SharedPrefsUtil.getString(AppConstant.currency) ?? "USD";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheetFrame(
      title: "Curreny",
      topPadding: 0,
      child: Column(
        children: [
          _row(title: "KRW"),
          _row(title: "USD"),
          SizedBox(height: AppUi.bottomPadding(context)),
        ],
      ),
    );
  }

  _row({required String title}) {
    return GestureDetector(
      onTap: () async {
        currency = title;
        setState(() {});
        await SharedPrefsUtil.setString(AppConstant.currency, title);
        setState(() {});
        Navigator.pop(context);
      },
      child: Container(
        height: 52,
        color: Colors.transparent,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        child: Text(
          title,
          style: fontR(16, color: C.current.mainText)
              .copyWith(fontWeight: currency == title ? FontWeight.w600 : null),
        ),
      ),
    );
  }
}
