import 'package:intl/intl.dart';

import '../localization/generated/app_localizations.dart';
import 'formatter.dart';

String formatBytes(dynamic bytes) => Formatter.compactBytes(bytes);

String formatByteRate(dynamic bytesPerSecond) =>
    Formatter.compactSpeed(bytesPerSecond);

String formatRelativeTime(DateTime? time, AppLocalizations l10n) {
  if (time == null) return l10n.format_relativeUnknown;
  final diff = DateTime.now().difference(time.toLocal());
  final isFuture = diff.isNegative;
  final absDiff = diff.abs();

  if (isFuture) {
    return switch (absDiff) {
      Duration(inMinutes: < 1) => l10n.format_relativeSoon,
      Duration(inHours: < 1) => l10n.format_relativeMinutesLater(
        absDiff.inMinutes,
      ),
      Duration(inDays: < 1) => l10n.format_relativeHoursLater(absDiff.inHours),
      _ => l10n.format_relativeDaysLater(absDiff.inDays),
    };
  } else {
    return switch (absDiff) {
      Duration(inMinutes: < 1) => l10n.format_relativeJustNow,
      Duration(inHours: < 1) => l10n.format_relativeMinutesAgo(
        absDiff.inMinutes,
      ),
      Duration(inDays: < 1) => l10n.format_relativeHoursAgo(absDiff.inHours),
      _ => l10n.format_relativeDaysAgo(absDiff.inDays),
    };
  }
}

String formatTimeAgo(DateTime? time, AppLocalizations l10n, {String? prefix}) {
  final label = formatRelativeTime(time, l10n);
  return '${prefix ?? l10n.format_timeAgoPrefixBackup}$label';
}

/// 将数值权限（如 755）转换为符号权限（如 drwxr-xr-x）。
String formatPermissions(String mode, bool isDir) {
  // 1. 直接尝试解析八进制，如果失败或为空，默认退化为 0
  final intMode = int.tryParse(mode, radix: 8) ?? 0;

  const perms = ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'];

  // 2. 提取各项权限
  final type = isDir ? 'd' : '-';
  final u = perms[(intMode >> 6) & 7]; // User 权限
  final g = perms[(intMode >> 3) & 7]; // Group 权限
  final o = perms[intMode & 7]; // Other 权限

  // 3. 使用字符串插值返回
  return '$type$u$g$o';
}

/// 解析八进制权限字符串（如 0644）为布尔矩阵 [Owner, Group, Others] [Read, Write, Execute]
List<List<bool>> parseOctalMode(String modeStr) {
  // 处理类似 0644 或 644
  final cleanMode = modeStr.startsWith('0') ? modeStr.substring(1) : modeStr;
  final fallback = [
    [false, false, false],
    [false, false, false],
    [false, false, false],
  ];

  if (cleanMode.length != 3) return fallback;

  final result = <List<bool>>[];
  for (var i = 0; i < 3; i++) {
    final val = int.tryParse(cleanMode[i]) ?? 0;
    result.add([
      (val & 4) != 0, // Read
      (val & 2) != 0, // Write
      (val & 1) != 0, // Execute
    ]);
  }
  return result;
}

/// 将布尔矩阵转换为八进制权限字符串（带 0 前缀，如 0644）
String octalModeToString(List<List<bool>> perms) {
  var result = '0';
  for (final role in perms) {
    var val = 0;
    if (role[0]) val += 4;
    if (role[1]) val += 2;
    if (role[2]) val += 1;
    result += val.toString();
  }
  return result;
}

/// 格式化 ISO 8601 时间字符串，自动转换为设备本地时区。
String formatLocalDateTime(
  String value, {
  String fallback = '-',
  String? locale,
  bool includeSeconds = true,
}) {
  if (value.trim().isEmpty) return fallback;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;

  final formatter = includeSeconds
      ? DateFormat.yMd(locale).add_Hms()
      : DateFormat.yMd(locale).add_Hm();
  return formatter.format(parsed.toLocal());
}

/// 格式化文件修改时间，自动转换为本地时区
String formatFileModTime(String modTimeStr) {
  if (modTimeStr.isEmpty) return '-';
  try {
    // 1Panel 后端通常返回类似 2024-04-27T06:12:37Z 的 ISO 8601 字符串
    final utcTime = DateTime.parse(modTimeStr);
    final localTime = utcTime.toLocal();

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final y = localTime.year;
    final m = twoDigits(localTime.month);
    final d = twoDigits(localTime.day);
    final h = twoDigits(localTime.hour);
    final min = twoDigits(localTime.minute);
    final s = twoDigits(localTime.second);

    return '$y/$m/$d $h:$min:$s';
  } catch (e) {
    return modTimeStr; // 解析失败则返回原字符串
  }
}

/// 中间省略文本。适用于长文件名，保留开头和结尾（后缀）。
String truncateMiddle(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  if (maxLength <= 3) return '${text.substring(0, 1)}...';

  final half = ((maxLength - 3) / 2).floor();
  final firstHalf = text.substring(0, half);
  final lastHalf = text.substring(text.length - half);
  return '$firstHalf...$lastHalf';
}
