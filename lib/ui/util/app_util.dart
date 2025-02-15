import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class AppUtil {
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }

  static String shortenWalletAddress(String address) {
    if (address.length <= 15) {
      // 너무 짧은 주소는 전체 표시
      return address;
    }

    String firstPart = address.substring(0, 5); // 앞 10자리
    String lastPart = address.substring(address.length - 5); // 뒤 5자리

    return '$firstPart...$lastPart';
  }

  static List<dynamic> aDifferenceB({
    required List<dynamic> a,
    required List<dynamic> b,
  }) {
    var aSet = a.toSet();
    var bSet = b.toSet();

    return aSet.difference(bSet).toList();
  }

  static String formatTime(DateTime? createdTime,
      {bool enableMultiline = true}) {
    if (createdTime == null) return "";
    final now = DateTime.now();
    final difference = now.difference(createdTime);

    if (difference.inHours < 12) {
      // 12시간 이하로 차이날 경우
      return '${difference.inHours}h';
    } else if (difference.inHours < 24) {
      // 24시간 이내일 경우
      final formattedTime = DateFormat.Hm().format(createdTime);
      return formattedTime; // "14:44" 형식
    } else {
      // 24시간 이후일 경우
      final formattedDateTime =
          DateFormat('yy.MM.dd${enableMultiline ? "\n" : " "}HH:mm')
              .format(createdTime);
      return formattedDateTime; // "yy-MM-dd HH:mm" 형식
    }
  }

  static String formatNumberWithComma(int number) {
    String formattedNumber = number.toString();
    String result = '';

    while (formattedNumber.length > 3) {
      result =
          ',${formattedNumber.substring(formattedNumber.length - 3)}$result';
      formattedNumber =
          formattedNumber.substring(0, formattedNumber.length - 3);
    }

    result = formattedNumber + result;
    return result;
  }

  static String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static List<T> getRandomNumbers<T>(List<T> list, int count) {
    if (count > list.length) {
      return [];
    }

    List<T> randomList = List.from(list);
    randomList.shuffle();

    return randomList.sublist(0, count);
  }

  static int getTextLine(String text) {
    if (text.contains('\n')) {
      return text.split('\n').length;
    } else {
      return 1;
    }
  }
}
