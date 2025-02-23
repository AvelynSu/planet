import 'package:flutter/cupertino.dart';

import '../../../../custom_theme.dart';

class TransferLabel extends StatelessWidget {
  final String title;
  final String? value;
  final String? description;
  final Widget? body;

  const TransferLabel({
    super.key,
    required this.title,
    this.description,
    this.value,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: fontR(14, color: C.current.sub01),
            ),
          ),
          body ?? Container(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value ?? "",
                style: fontR(16, color: C.current.mainText),
              ),
              if (description != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Text(
                    description ?? "",
                    style: fontR(12, color: C.current.sub01),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
