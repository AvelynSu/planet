import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planet/custom_theme.dart';
import 'package:planet/ui/common/custom_image.dart';

class FriendSearchField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChange;
  final String initialValue;

  const FriendSearchField({
    super.key,
    required this.controller,
    required this.onChange,
    required this.initialValue,
  });

  @override
  State<FriendSearchField> createState() => _FriendSearchFieldState();
}

class _FriendSearchFieldState extends State<FriendSearchField> {
  @override
  Widget build(BuildContext context) {
    var borderSide = const BorderSide(
      width: 1,
      color: Colors.transparent,
      style: BorderStyle.solid,
    );

    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: borderSide,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      height: 56,
      decoration: BoxDecoration(
        color: C.current.sub02,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        CustomImage(path: "icons/ic_search.svg"),
        Expanded(
          child: SizedBox(
            // height: widget.maxLine == null ? widget.height ?? 40 : null,
            child: TextFormField(
              controller: widget.controller,
              keyboardAppearance: Brightness.dark,
              textAlign: TextAlign.left,
              style: fontR(16, height: 1.3, color: C.current.mainText),
              cursorColor: primary,
              onChanged: (text) {
                widget.onChange(text);
                setState(() {});
              },
              decoration: InputDecoration(
                // fillColor: widget.backgroundColor,
                // filled: widget.backgroundColor != null,
                counterText: '',
                hintText: 'Enter Address or Planet name',
                hintStyle: fontR(16, color: C.current.sub01),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                disabledBorder: border,
                enabledBorder: border,
                focusedBorder: border,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final data = await Clipboard.getData('text/plain');
            if (data?.text != null) {
              widget.controller.text = data!.text ?? "";
              widget.onChange(data.text ?? "");
              setState(() {});
            }
          },
          child: CustomImage(
            path: "icons/ic_copy.svg",
            color: C.current.primary,
            width: 32,
          ),
        ),
      ]),
    );
  }
}
