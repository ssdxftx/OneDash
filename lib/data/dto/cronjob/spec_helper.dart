import '../../../core/localization/generated/app_localizations.dart';

/// 将 cron 表达式解析为可读描述。
String describeSpec(String spec, AppLocalizations l10n) {
  if (spec.isEmpty) return '';

  final parts = spec.split(' ');

  // @every Ns / @every Nm 格式
  if (parts.length == 2) {
    if (parts[1].endsWith('m')) {
      final n = parts[1].replaceAll('m', '');
      return l10n.cronjobs_everyMinutes(n);
    }
    if (parts[1].endsWith('s')) {
      final n = parts[1].replaceAll('s', '');
      return l10n.cronjobs_everySeconds(n);
    }
  }

  if (parts.length != 5) return spec;

  final minute = parts[0];
  final hour = parts[1];
  final dayOfMonth = parts[2];
  final month = parts[3];
  final dayOfWeek = parts[4];

  // 每小时: M * * * *
  if (hour == '*' && dayOfMonth == '*' && month == '*' && dayOfWeek == '*') {
    return l10n.cronjobs_everyHourAtMinute(minute);
  }

  // 每天: M H * * *
  if (dayOfMonth == '*' && month == '*' && dayOfWeek == '*') {
    if (hour.startsWith('*/')) {
      final n = hour.replaceAll('*/', '');
      return l10n.cronjobs_everyHours(n);
    }
    return l10n.cronjobs_dailyAt('${_pad(hour)}:${_pad(minute)}');
  }

  // 每周: M H * * W
  if (dayOfMonth == '*' && month == '*' && dayOfWeek != '*') {
    final weekName = _weekName(dayOfWeek, l10n);
    return l10n.cronjobs_weeklyAt(weekName, '${_pad(hour)}:${_pad(minute)}');
  }

  // 每月: M H D * *
  if (month == '*' && dayOfWeek == '*') {
    return l10n.cronjobs_monthlyAt(dayOfMonth, '${_pad(hour)}:${_pad(minute)}');
  }

  // 每 N 天: M H */N * *
  if (dayOfMonth.startsWith('*/') && month == '*' && dayOfWeek == '*') {
    final n = dayOfMonth.replaceAll('*/', '');
    return l10n.cronjobs_everyDaysAt(n, '${_pad(hour)}:${_pad(minute)}');
  }

  return spec;
}

String _pad(String s) {
  if (s.length == 1) return '0$s';
  return s;
}

String _weekName(String day, AppLocalizations l10n) {
  switch (day) {
    case '0':
      return l10n.cronjobs_weekdaySun;
    case '1':
      return l10n.cronjobs_weekdayMon;
    case '2':
      return l10n.cronjobs_weekdayTue;
    case '3':
      return l10n.cronjobs_weekdayWed;
    case '4':
      return l10n.cronjobs_weekdayThu;
    case '5':
      return l10n.cronjobs_weekdayFri;
    case '6':
      return l10n.cronjobs_weekdaySat;
    default:
      return l10n.cronjobs_weekdayFallback(day);
  }
}

/// 根据计划类型构建 cron 表达式。
String buildSpec({
  required String specType,
  int week = 0,
  int day = 0,
  int hour = 0,
  int minute = 0,
  int second = 0,
}) {
  switch (specType) {
    case 'perMonth':
      return '$minute $hour $day * *';
    case 'perWeek':
      return '$minute $hour * * $week';
    case 'perNDay':
      return '$minute $hour */$day * *';
    case 'perDay':
      return '$minute $hour * * *';
    case 'perNHour':
      return '$minute */$hour * * *';
    case 'perHour':
      return '$minute * * * *';
    case 'perNMinute':
      return '@every ${minute}m';
    case 'perNSecond':
      return '@every ${second}s';
    default:
      return '';
  }
}
