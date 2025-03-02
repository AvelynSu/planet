import 'package:flutter/material.dart';

import '../../custom_theme.dart';

class MnemonicPharseComponent extends StatelessWidget {
  final String mnemonic;

  const MnemonicPharseComponent({
    super.key,
    required this.mnemonic,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        padding: const EdgeInsets.all(0),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
          mainAxisExtent: 44,
        ),
        itemCount: mnemonic.split(" ").length,
        shrinkWrap: true,
        itemBuilder: (context, i) {
          var items = mnemonic.split(" ");
          var item = items.length > i ? items[i] : "";
          return Container(
            decoration: BoxDecoration(
              color: C.current.lightBase,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: C.current.sub01.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "${i + 1}. $item",
                style: fontM(14, color: C.current.mainText),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }
}
