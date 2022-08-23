class Mappers {
  static DateTime parseDate(dynamic data) {
    return DateTime.fromMillisecondsSinceEpoch(data);
  }
}
