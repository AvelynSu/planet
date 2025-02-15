class FBFormatter {
  static String? toJsonDate(DateTime? date) {
    return date?.toIso8601String();
  }

// JSON(문자열)을 DateTime으로 변환
  static DateTime? fromJsonDate(String? item) {
    return (item != null) ? DateTime.parse(item) : null;
  }

  static List<T> fromJsonList<T>(List<dynamic>? json) {
    return json?.map((e) => e as T).toList() ?? [];
  }
}
