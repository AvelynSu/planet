import 'package:flutter/cupertino.dart';

import '../../../../custom_theme.dart';

class TransferLabel extends StatelessWidget {
  final String title;
  final String? value;
  final Widget? body;

  const TransferLabel({
    super.key,
    required this.title,
    this.value,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: fontR(14, color: C.current.sub01),
            ),
          ),
          Text(
            value ?? "",
            style: fontR(16, color: C.current.mainText),
          ),
          body ?? Container(),
        ],
      ),
    );
  }
}
