import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'app_util.dart';

class BoldMsgGenerator {
  static AutoSizeText toRichText({
    required String text,
    required TextStyle style,
    required TextStyle boldStyle,
    TextAlign? textAlign,
    int? maxLine,
  }) {
    List<InlineSpan> texts = [];
    var msg = GuideMessageGenerator.fromBold(text);

    for (var i = 0; i < msg.length; i++) {
      texts.add(
        TextSpan(
          text: msg[i].message,
          style: msg[i].isSigned ? boldStyle : style,
        ),
      );
    }

    return AutoSizeText.rich(
      TextSpan(
        children: texts,
      ),
      minFontSize: 1,
      textAlign: textAlign,
      maxLines: maxLine ?? AppUtil.getTextLine(text),
    );
  }
}

class QuotesMsgGenerator {
  static AutoSizeText toRichText({
    required String text,
    required TextStyle style,
    required TextStyle quotesStyle,
    TextAlign? signedTextAlign,
    TextAlign? textAlign,
    int? maxLine,
  }) {
    List<InlineSpan> texts = [];
    var msg = GuideMessageGenerator.fromQuotes(text);

    for (var i = 0; i < msg.length; i++) {
      texts.add(
        TextSpan(
          text:
              msg[i].isSigned ? '\n\n"${msg[i].message}"\n\n' : msg[i].message,
          style: msg[i].isSigned ? quotesStyle : style,
        ),
      );
    }

    return AutoSizeText.rich(
      TextSpan(children: texts),
      minFontSize: 1,
      textAlign: textAlign,
      maxLines: maxLine ?? AppUtil.getTextLine(text),
    );
  }
}

class GuideMessage {
  final String message;
  final bool isSigned;

  GuideMessage({required this.message, this.isSigned = false});
}

class GuideMessageGenerator {
  static const boldSign = '*';
  static const quotesSign = '"';

  static List<GuideMessage> fromBold(String msg) {
    if (msg.split('').where((e) => e == boldSign).toList().length % 2 != 0) {
      msg = msg + boldSign;
    }

    int startIdx = 0;
    List<int> signIdxs = [];
    while (startIdx != -1) {
      startIdx = msg.indexOf(boldSign, startIdx) + 1;
      if (startIdx != 0) {
        signIdxs.add(startIdx);
      } else {
        break;
      }
    }

    if (signIdxs.isEmpty) {
      return [GuideMessage(message: msg)];
    }

    List<GuideMessage> result = [];
    for (var i = 0; i < signIdxs.length / 2; i++) {
      var idx = 0;
      try {
        idx = signIdxs[2 * i - 1];
        // ignore: empty_catches
      } catch (err) {}
      result
          .add(GuideMessage(message: msg.substring(idx, signIdxs[2 * i] - 1)));
      result.add(GuideMessage(
          message: msg.substring(signIdxs[2 * i], signIdxs[2 * i + 1] - 1),
          isSigned: true));

      if (i == signIdxs.length / 2 - 1 && signIdxs[i] != msg.length) {
        result.add(
            GuideMessage(message: msg.substring(signIdxs.last, msg.length)));
      }
    }

    result = result.where((e) => e.message != '').toList();
    return result;
  }

  static List<GuideMessage> fromQuotes(String msg) {
    if (msg.split('').where((e) => e == quotesSign).toList().length % 2 != 0) {
      msg = msg + quotesSign;
    }

    int startIdx = 0;
    List<int> signIdxs = [];
    while (startIdx != -1) {
      startIdx = msg.indexOf(quotesSign, startIdx) + 1;
      if (startIdx != 0) {
        signIdxs.add(startIdx);
      } else {
        break;
      }
    }

    if (signIdxs.isEmpty) {
      return [GuideMessage(message: msg)];
    }

    List<GuideMessage> result = [];
    for (var i = 0; i < signIdxs.length / 2; i++) {
      var idx = 0;
      try {
        idx = signIdxs[2 * i - 1];
        // ignore: empty_catches
      } catch (err) {}
      result
          .add(GuideMessage(message: msg.substring(idx, signIdxs[2 * i] - 1)));
      result.add(GuideMessage(
          message: msg.substring(signIdxs[2 * i], signIdxs[2 * i + 1] - 1),
          isSigned: true));

      if (i == signIdxs.length / 2 - 1 && signIdxs[i] != msg.length) {
        result.add(
            GuideMessage(message: msg.substring(signIdxs.last, msg.length)));
      }
    }

    result = result.where((e) => e.message != '').toList();
    return result;
  }
}
