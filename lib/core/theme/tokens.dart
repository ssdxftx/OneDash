import 'package:flutter/material.dart';

/// OneDash 设计 token。所有页面禁止出现魔法数字。
abstract final class AppTokens {
  static const Color seed = Color(0xFF3F7F5F);

  static const Color consoleBackground = Color(0xFF0B0F0C);
  static const Color consoleToolbar = Color(0xFF141A16);
  static const Color consoleForeground = Color(0xFFD7E4DA);
  static const Color consoleMuted = Color(0xFF8A9A90);

  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;

  static const double rXs = 6;
  static const double rSm = 10;
  static const double rMd = 14;
  static const double rLg = 18;
  static const double rXl = 24;
  static const double rSheet = 28;
  static const double rFull = 999;

  static const double iconList = 20;
  static const double iconLeading = 22;
  static const double iconNav = 24;
  static const double iconEmpty = 28;

  static const double appBarHeight = 64;
  static const double menuRowHeight = 40;
  static const double appBarLargeHeight = 84;

  static const double bottomNavHeight = 72;
  static const double bottomNavMaxWidth = 480;
  static const double bottomNavClearance = 96;

  static const double rowOneLine = 56;
  static const double rowTwoLine = 72;
  static const double rowThreeLine = 88;
  static const double minTapTarget = 48;
  static const double buttonHeight = 48;

  static const double pagePadding = 16;
  static const double pagePaddingWide = 24;
  static const double contentMaxWidth = 640;

  static const Duration dInstant = Duration.zero;
  static const Duration dFast = Duration(milliseconds: 120);
  static const Duration dBase = Duration(milliseconds: 200);
  static const Duration dEmphasis = Duration(milliseconds: 280);
  static const Duration dPage = Duration(milliseconds: 320);
  static const Duration dLoop = Duration(milliseconds: 1200);
  static const Duration numberRoll = Duration(milliseconds: 400);
  static const Duration ringFill = Duration(milliseconds: 600);
  static const Duration chartReveal = Duration(milliseconds: 500);
  static const Duration chartMorph = Duration(milliseconds: 300);

  static const Curve curveFast = Curves.easeOutCubic;
  static const Curve curveBase = Curves.easeOutCubic;
  static const Curve curveEmphasis = Curves.easeOutQuart;

  static const SpringDescription sheetSpring = SpringDescription(
    mass: 1,
    stiffness: 420,
    damping: 32,
  );

  static const int chartHistoryPoints = 120;
  static const double chartHeight = 160;
  static const double chartCompactHeight = 28;
  static const double iconBadge = 32;
  static const double miniRing = 38;
  static const double spinner = 20;
  static const double spinnerStroke = 2;
  static const double chipPaddingY = 2;
  static const double logPanelMaxHeight = 260;
  static const double toastMargin = 12;
  static const Duration toastDuration = Duration(milliseconds: 2400);
  static const int logBufferLines = 5000;
  static const int pageSizePhone = 20;
  static const int pageSizeTablet = 30;
}

/// 语义色扩展。页面只能通过 `context.appColors` 或 `Theme.of(context).colorScheme`
/// 取色，禁止直接使用 `Colors.red` 等 Material 调色板。
@immutable
class OneDashColors extends ThemeExtension<OneDashColors> {
  const OneDashColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.neutral,
    required this.chart1,
    required this.chart2,
    required this.chart3,
    required this.chart4,
    required this.chart5,
    required this.chart6,
  });

  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color neutral;
  final Color chart1;
  final Color chart2;
  final Color chart3;
  final Color chart4;
  final Color chart5;
  final Color chart6;

  static const light = OneDashColors(
    success: Color(0xFF2E7D4F),
    warning: Color(0xFFA35F00),
    danger: Color(0xFFB3261E),
    info: Color(0xFF2F6F8F),
    neutral: Color(0xFF4A5A50),
    chart1: Color(0xFF3F7F5F),
    chart2: Color(0xFF4A7BA7),
    chart3: Color(0xFFB07A3C),
    chart4: Color(0xFF8A5FA8),
    chart5: Color(0xFF4F9E9A),
    chart6: Color(0xFFA85A5A),
  );

  static const dark = OneDashColors(
    success: Color(0xFF7FD3A0),
    warning: Color(0xFFF2B25C),
    danger: Color(0xFFFFB4AB),
    info: Color(0xFF8FCBE0),
    neutral: Color(0xFFB7C5BB),
    chart1: Color(0xFF7FD3A0),
    chart2: Color(0xFF8FB8DC),
    chart3: Color(0xFFE0B07A),
    chart4: Color(0xFFC4A0DE),
    chart5: Color(0xFF8FD4CF),
    chart6: Color(0xFFD79A9A),
  );

  Color status(String status) {
    return switch (status.toLowerCase()) {
      'running' || 'running ' || 'active' || 'healthy' || 'success' => success,
      'stopped' || 'inactive' || 'exited' || 'paused' => neutral,
      'offline' || 'disconnected' || 'unreachable' => danger,
      'error' || 'failed' || 'failure' || 'dead' || 'unhealthy' => danger,
      'pending' ||
      'starting' ||
      'waiting' ||
      'restarting' ||
      'installing' ||
      'upgrading' => warning,
      _ => info,
    };
  }

  @override
  OneDashColors copyWith({
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? neutral,
    Color? chart1,
    Color? chart2,
    Color? chart3,
    Color? chart4,
    Color? chart5,
    Color? chart6,
  }) {
    return OneDashColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      neutral: neutral ?? this.neutral,
      chart1: chart1 ?? this.chart1,
      chart2: chart2 ?? this.chart2,
      chart3: chart3 ?? this.chart3,
      chart4: chart4 ?? this.chart4,
      chart5: chart5 ?? this.chart5,
      chart6: chart6 ?? this.chart6,
    );
  }

  @override
  OneDashColors lerp(ThemeExtension<OneDashColors>? other, double t) {
    if (other is! OneDashColors) return this;
    return OneDashColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      chart1: Color.lerp(chart1, other.chart1, t)!,
      chart2: Color.lerp(chart2, other.chart2, t)!,
      chart3: Color.lerp(chart3, other.chart3, t)!,
      chart4: Color.lerp(chart4, other.chart4, t)!,
      chart5: Color.lerp(chart5, other.chart5, t)!,
      chart6: Color.lerp(chart6, other.chart6, t)!,
    );
  }
}

abstract final class AppTextStyles {
  static const _tabular = <FontFeature>[FontFeature.tabularFigures()];

  static const display = TextStyle(
    fontFamily: 'MiSans',
    fontSize: 34,
    height: 1.18,
    fontWeight: FontWeight.w600,
    fontFeatures: _tabular,
  );
  static const headline = TextStyle(
    fontFamily: 'MiSans',
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );
  static const titleL = TextStyle(
    fontFamily: 'MiSans',
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );
  static const titleM = TextStyle(
    fontFamily: 'MiSans',
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );
  static const titleS = TextStyle(
    fontFamily: 'MiSans',
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w600,
  );
  static const bodyL = TextStyle(
    fontFamily: 'MiSans',
    fontSize: 16,
    height: 1.5,
  );
  static const bodyM = TextStyle(
    fontFamily: 'MiSans',
    fontSize: 14,
    height: 1.5,
  );
  static const bodyS = TextStyle(
    fontFamily: 'MiSans',
    fontSize: 13,
    height: 1.45,
  );
  static const label = TextStyle(
    fontFamily: 'MiSans',
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );
  static const caption = TextStyle(
    fontFamily: 'MiSans',
    fontSize: 12,
    height: 1.35,
  );
  static const numeric = TextStyle(
    fontFamily: 'MiSans',
    fontSize: 14,
    height: 1.5,
    fontFeatures: _tabular,
  );
  static const numericLarge = TextStyle(
    fontFamily: 'MiSans',
    fontSize: 34,
    height: 1.18,
    fontWeight: FontWeight.w600,
    fontFeatures: _tabular,
  );
}

extension AppThemeContextX on BuildContext {
  OneDashColors get appColors =>
      Theme.of(this).extension<OneDashColors>() ?? OneDashColors.light;

  ColorScheme get scheme => Theme.of(this).colorScheme;

  TextTheme get texts => Theme.of(this).textTheme;

  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);

  /// Page padding grows on tablet-sized windows.
  double get pagePadding => MediaQuery.sizeOf(this).width >= 600
      ? AppTokens.pagePaddingWide
      : AppTokens.pagePadding;

  Duration motion(Duration duration) => reduceMotion ? Duration.zero : duration;
}
