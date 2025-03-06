import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/service/local_storage_service.dart';
import 'package:planet/ui/common/custom_bottom_sheet_frame.dart';
import 'package:planet/util/app_constant.dart';
import 'package:planet/util/app_ui.dart';
import 'package:planet/util/data/planet_name_data.dart';

import '../../service/global_service.dart';

class ChangeLocaleBottomSheet extends StatefulWidget {
  const ChangeLocaleBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeLocaleBottomSheet(),
    );
  }

  @override
  State<ChangeLocaleBottomSheet> createState() =>
      _ChangeCurrenyBottomSheetState();
}

class _ChangeCurrenyBottomSheetState extends State<ChangeLocaleBottomSheet> {
  Locale locale = Locale("en");

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    var locale = SharedPrefsUtil.getString(AppConstant.locale) ?? "en";
    this.locale = Locale(locale);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheetFrame(
      title: "Localization",
      topPadding: 0,
      child: Column(
        children: [
          ...Data.locale.map(
            (e) => _row(title: e.title, key: e.key),
          ),
          SizedBox(height: AppUi.bottomPadding(context)),
        ],
      ),
    );
  }

  _row({required String title, required String key}) {
    final settings = context.watch<GlobalService>();
    return GestureDetector(
      onTap: () async {
        locale = Locale(key);
        setState(() {});
        await SharedPrefsUtil.setString(AppConstant.locale, key);
        settings.onUpdateLocale(locale);
        Navigator.pop(context);
      },
      child: Container(
        height: 52,
        color: Colors.transparent,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        child: Text(
          title,
          style: fontR(16, color: Colors.black).copyWith(
              fontWeight: locale.languageCode == key ? FontWeight.w600 : null),
        ),
      ),
    );
  }
}
