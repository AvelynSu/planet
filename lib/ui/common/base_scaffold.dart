import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../custom_theme.dart';
import '../util/app_ui.dart';
import 'custom_image.dart';
import 'custom_loading.dart';
import 'default_dialog.dart';

class BaseScaffold extends StatefulWidget {
  final String? title;
  final Color? backgroundColor;
  final bool showAppbarIcon;
  final Function? onBack;
  final Widget body;
  final Widget? suffix;
  final bool onLoading;
  final bool isFirstPage;
  final bool resizeToAvoidBottomInset;
  final bool isTransparentAppbar;
  final Color? appBarContentColor;
  final Widget? appBarContent;
  final bool convertBackIcon;
  final double? appBarHeight;

  const BaseScaffold({
    super.key,
    this.backgroundColor,
    this.showAppbarIcon = false,
    this.title,
    this.onBack,
    required this.body,
    this.onLoading = false,
    this.isFirstPage = false,
    this.resizeToAvoidBottomInset = true,
    this.isTransparentAppbar = false,
    this.suffix,
    this.appBarContentColor,
    this.appBarContent,
    this.convertBackIcon = false,
    this.appBarHeight,
  });

  @override
  State<BaseScaffold> createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  final double appbarHeight = 52.0;

  bool get enableBack => widget.onBack != null;

  bool get enableTitle => widget.title != null;

  bool get enableSuffix => widget.suffix != null;

  bool get exitAppbarContents => widget.appBarContent != null;

  bool get existAppBar {
    return widget.showAppbarIcon ||
        enableBack ||
        enableTitle ||
        enableSuffix ||
        exitAppbarContents;
  }

  @override
  Widget build(BuildContext context) {
    // aos 는 가장 마지막 페이지일때 앱 종료 문구를 보여줘아 하므로 분기 처리

    if (kIsWeb) {
      return body(context);
    }

    return Platform.isAndroid
        ? PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) {
                return;
              }
              if (widget.onBack != null) {
                widget.onBack!();
                return;
              }
              final NavigatorState navigator = Navigator.of(context);
              if (navigator.canPop()) {
                Navigator.pop(context);
              } else {
                await DefaultDialog.show(
                  context,
                  title: "앱 종료",
                  description: "앱을 종료하시겠습니까?",
                  onSecondAction: () {
                    SystemNavigator.pop();
                  },
                );
              }
            },
            child: body(context),
          )
        : body(context);
  }

  double appBarTopMargin(BuildContext context) {
    if (existAppBar) {
      var appBarHeight = widget.appBarHeight ?? appbarHeight;
      return widget.isTransparentAppbar
          ? 0
          : AppUi.statusBarHeight(context) + (existAppBar ? appBarHeight : 0);
    }
    return 0;
  }

  // 페이지 위에 로딩 페이지를 올려 줌
  Widget body(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // 실제 화면
        Scaffold(
          resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
          backgroundColor: widget.backgroundColor ?? Colors.white,
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              color: Colors.transparent,
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                children: [
                  // 화면
                  Container(
                    height: double.infinity,
                    margin: EdgeInsets.only(top: appBarTopMargin(context)),
                    child: widget.body,
                  ),

                  // 화면 위에 stack 으로 앱바 올림
                  _appBar(),
                ],
              ),
            ),
          ),
        ),

        // 로딩 화면
        if (widget.onLoading) const Loading(),
      ],
    );
  }

  _appBar() {
    if (existAppBar) {
      Color? color = widget.appBarContentColor ?? Colors.white;
      Color bgColor = widget.isTransparentAppbar
          ? Colors.transparent
          : (widget.backgroundColor ?? Colors.white);

      return Container(
        margin: EdgeInsets.only(top: AppUi.statusBarHeight(context)),
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        color: bgColor,
        height: widget.appBarHeight ?? appbarHeight,
        // alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Row(
              children: [
                if (enableBack ||
                    enableSuffix ||
                    exitAppbarContents ||
                    widget.showAppbarIcon)
                  Expanded(
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        enableBack
                            ? GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  widget.onBack!();
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 30,
                                    height: 45,
                                    alignment: Alignment.centerLeft,
                                    child: CustomImage(
                                        path: widget.convertBackIcon
                                            ? 'ic_close.png'
                                            : 'icons/ic_back.svg',
                                        width: 40,
                                        height: 40,
                                        color: color),
                                  ),
                                ),
                              )
                            : Container(),
                        if (widget.showAppbarIcon)
                          CustomImage(
                            path: "ic_logo_old.png",
                            width: 70,
                            height: 20,
                          ),
                      ],
                    ),
                  ),
                if (exitAppbarContents) Expanded(child: widget.appBarContent!),
                if (widget.suffix != null) widget.suffix!
              ],
            ),
            if (enableTitle)
              Container(
                alignment: Alignment.center,
                child: Text(
                  widget.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: fontB(17, color: color),
                ),
              ),
            if (widget.appBarContent != null) widget.appBarContent!
          ],
        ),
      );
    }
    return Container();
  }
}
