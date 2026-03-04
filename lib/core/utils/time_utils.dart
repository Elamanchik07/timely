/// Utility for human-readable relative time strings (Russian).
class TimeUtils {
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'только что';
    } else if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${_minuteWord(m)} назад';
    } else if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${_hourWord(h)} назад';
    } else if (diff.inDays == 1) {
      return 'вчера';
    } else if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d ${_dayWord(d)} назад';
    } else if (diff.inDays < 30) {
      final w = diff.inDays ~/ 7;
      return '$w ${_weekWord(w)} назад';
    } else if (diff.inDays < 365) {
      final m = diff.inDays ~/ 30;
      return '$m ${_monthWord(m)} назад';
    } else {
      final y = diff.inDays ~/ 365;
      return '$y ${_yearWord(y)} назад';
    }
  }

  static String _minuteWord(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'минуту';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) return 'минуты';
    return 'минут';
  }

  static String _hourWord(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'час';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) return 'часа';
    return 'часов';
  }

  static String _dayWord(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'день';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) return 'дня';
    return 'дней';
  }

  static String _weekWord(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'неделю';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) return 'недели';
    return 'недель';
  }

  static String _monthWord(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'месяц';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) return 'месяца';
    return 'месяцев';
  }

  static String _yearWord(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'год';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) return 'года';
    return 'лет';
  }
}
