import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/service/local_storage_service.dart';
import 'package:planet/ui/common/custom_bottom_sheet_frame.dart';
import 'package:planet/ui/common/default_dialog.dart';
import 'package:planet/util/app_constant.dart';
import 'package:planet/util/app_ui.dart';
import 'package:planet/util/date.dart';

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

  Future<void> updateCurrency(String newValue) async {
    var value = SharedPrefsUtil.getString(AppConstant.currencyCount) ?? "";
    if (value.isEmpty) {
      /// 업데이트 하기
      update(newValue, 1);
    } else {
      var date = extractDate(value);
      var count = extractCount(value);

      if (Date.isSame(date, DateTime.now())) {
        if (count < 3) {
          /// 업데이트 하기
          update(newValue, count + 1);
        } else {
          /// 횟수 초과 팝업
          DefaultDialog.show(context,
              description:
                  AppLocalizations.of(context)?.modify_currency_daily_limit ??
                      '');
        }
      } else {
        update(newValue, 1);
      }
    }
  }

  DateTime extractDate(String key) {
    List<String> parts = key.split('-');
    if (parts.length < 3) return DateTime(1970, 1, 1); // 유효하지 않은 형식 처리

    String dateStr = "${parts[0]}-${parts[1]}-${parts[2]}"; // "yyyy-MM-dd" 조합
    return DateTime.tryParse(dateStr) ?? DateTime(1970, 1, 1);
  }

  int extractCount(String key) {
    String countStr = key.split('-').last; // "count" 부분 추출
    return int.tryParse(countStr) ?? 0; // 숫자로 변환 (실패 시 0 반환)
  }

  update(String title, int count) async {
    currency = title;
    setState(() {});
    await SharedPrefsUtil.setString(AppConstant.currencyCount,
        "${Date.dateFormat(pattern: "yyyy-MM-dd", date: DateTime.now())}-$count");
    await SharedPrefsUtil.setString(AppConstant.currency, title);
    setState(() {});
    Navigator.pop(context);
    context.read<AppBloc>().add(AppUpdate(
          updateBalance: false,
          updatePlanets: false,
          updatePrice: true,
        ));
  }

  _row({required String title}) {
    return GestureDetector(
      onTap: () async {
        updateCurrency(title);
      },
      child: Container(
        height: 52,
        color: Colors.transparent,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        child: Text(
          title,
          style: fontR(16, color: Colors.black)
              .copyWith(fontWeight: currency == title ? FontWeight.w600 : null),
        ),
      ),
    );
  }
}
