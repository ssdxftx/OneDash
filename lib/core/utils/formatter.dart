/// 通用格式化工具（字节、时长、百分比）。
class Formatter {
  const Formatter._();

  static const _units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];

  /// 字节数转人类可读字符串，固定保留 [fraction] 位小数，如 `1.23 GB`。
  static String bytes(num value, {int fraction = 2}) {
    return _formatBytes(value, (_, _) => fraction);
  }

  /// 字节数转紧凑格式，适用于文件列表等密集 UI，如 `10 MB` / `1.5 GB`。
  static String compactBytes(dynamic value) {
    return _formatBytes(value, (amount, unitIndex) {
      if (unitIndex == 0 || amount >= 10) return 0;
      return 1;
    });
  }

  /// 字节数转自适应精度格式，适用于 dashboard 指标展示。
  static String adaptiveBytes(num value) {
    return _formatBytes(value, (amount, unitIndex) {
      if (unitIndex <= 1) return 0;
      if (amount >= 100) return 0;
      if (amount >= 10) return 1;
      return 2;
    });
  }

  /// 秒转为 `Xd Yh Zm` 形式的运行时长。
  static String uptime(int seconds) {
    if (seconds <= 0) return '0m';
    final d = seconds ~/ 86400;
    final h = (seconds % 86400) ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final parts = <String>[];
    if (d > 0) parts.add('${d}d');
    if (h > 0) parts.add('${h}h');
    if (d == 0 && m > 0) parts.add('${m}m');
    return parts.isEmpty ? '${seconds}s' : parts.join(' ');
  }

  /// 百分比保留 1 位小数，带 `%` 后缀。
  static String percent(double value, {int fraction = 1}) {
    return '${value.toStringAsFixed(fraction)}%';
  }

  /// 字节速率转人类可读字符串，如 `1.23 MB/s`。
  static String speed(num bytesPerSecond, {int fraction = 2}) {
    return '${bytes(bytesPerSecond, fraction: fraction)}/s';
  }

  /// 字节速率转紧凑格式，如 `10 MB/s` / `1.5 GB/s`。
  static String compactSpeed(dynamic bytesPerSecond) {
    return '${compactBytes(bytesPerSecond)}/s';
  }

  static String _formatBytes(
    dynamic value,
    int Function(double amount, int unitIndex) fractionFor,
  ) {
    if (value is String) return value;
    if (value is! num || value <= 0) return '0 B';

    var amount = value.toDouble();
    var unitIndex = 0;
    while (amount >= 1024 && unitIndex < _units.length - 1) {
      amount /= 1024;
      unitIndex++;
    }

    final fraction = fractionFor(amount, unitIndex);
    return '${amount.toStringAsFixed(fraction)} ${_units[unitIndex]}';
  }
}
