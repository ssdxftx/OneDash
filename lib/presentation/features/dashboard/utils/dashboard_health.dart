import '../../../../core/localization/generated/app_localizations.dart';

/// 健康分：纯函数，便于单测。
double healthScore({
  required double cpuPercent,
  required double memoryPercent,
  required double diskPercent,
  required double load1,
  required int cores,
}) {
  double penalty(double value, double threshold, double factor, double max) {
    if (value <= threshold) return 0;
    final raw = (value - threshold) * factor;
    return raw.clamp(0, max).toDouble();
  }

  final cpuPenalty = penalty(cpuPercent, 80, 1.2, 30);
  final memPenalty = penalty(memoryPercent, 85, 1.5, 25);
  final diskPenalty = penalty(diskPercent, 90, 2.0, 25);
  final loadRatio = cores <= 0 ? 0.0 : load1 / cores;
  final loadPenalty = penalty(loadRatio, 1.5, 10, 20);

  return (100 - cpuPenalty - memPenalty - diskPenalty - loadPenalty)
      .clamp(0, 100)
      .toDouble();
}

String healthLabel(double score, AppLocalizations l10n) {
  if (score >= 85) return l10n.dashboard_health_excellent;
  if (score >= 70) return l10n.dashboard_health_good;
  if (score >= 50) return l10n.dashboard_health_fair;
  return l10n.dashboard_health_poor;
}

String formatUptime(int seconds, AppLocalizations l10n) {
  if (seconds <= 0) return '-';
  final days = seconds ~/ 86400;
  final hours = (seconds % 86400) ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  if (days > 0) return l10n.dashboard_uptimeDaysHours(days, hours);
  if (hours > 0) return l10n.dashboard_uptimeHoursMinutes(hours, minutes);
  return l10n.dashboard_uptimeMinutes(minutes);
}

String formatPercent(double value) => '${value.toStringAsFixed(1)}%';
