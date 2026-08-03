import 'package:intl/intl.dart';

abstract final class Fmt {
  static final _fullDate = DateFormat('MMM dd, yyyy');
  static final _shortDate = DateFormat('dd/MM/yyyy');
  static final _dateTime = DateFormat('MMM dd, yyyy • hh:mm a');
  static final _time = DateFormat('hh:mm a');
  static final _dayMonth = DateFormat('dd MMM');
  static final _monthYear = DateFormat('MMM yyyy');

  static String formatFull(DateTime date) => _fullDate.format(date);
  static String formatShort(DateTime date) => _shortDate.format(date);
  static String formatWithTime(DateTime date) => _dateTime.format(date);
  static String formatTime(DateTime date) => _time.format(date);
  static String formatDayMonth(DateTime date) => _dayMonth.format(date);
  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m min${m == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h hour${h == 1 ? '' : 's'} ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return '$w week${w == 1 ? '' : 's'} ago';
    }
    return formatFull(date);
  }

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static (DateTime, DateTime) todayRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    return (start, end);
  }

  static (DateTime, DateTime) thisWeekRange() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(monday.year, monday.month, monday.day);
    final end = start.add(const Duration(days: 7)).subtract(const Duration(milliseconds: 1));
    return (start, end);
  }

  static (DateTime, DateTime) thisMonthRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1));
    return (start, end);
  }

  static List<String> weekDayLabels() => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
}
