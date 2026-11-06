import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import 'status_dot.dart';
import 'tonal_card.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.caption,
    this.captionMaxLines = 1,
    this.status,
    this.trailing,
    this.sparkline,
    this.onTap,
    this.onLongPress,
    this.accent,
  });

  final String title;
  final String value;
  final String? unit;
  final String? caption;
  final int captionMaxLines;
  final String? status;
  final Widget? trailing;
  final Widget? sparkline;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final valueColor = accent ?? scheme.onSurface;
    return TonalCard(
      onTap: onTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.all(AppTokens.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (status != null) ...[
                StatusDot(status: status!, size: 8),
                const SizedBox(width: AppTokens.s8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyS.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: _animatedValue(context, valueColor, scheme),
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: 2),
                Text(
                  caption!,
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: captionMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (sparkline != null) ...[
                const SizedBox(height: AppTokens.s8),
                SizedBox(height: 28, child: sparkline),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _animatedValue(
    BuildContext context,
    Color valueColor,
    ColorScheme scheme,
  ) {
    final style = AppTextStyles.numericLarge.copyWith(
      color: valueColor,
      fontSize: switch (value.length) {
        <= 4 => 28,
        <= 6 => 26,
        _ => 23,
      },
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final unitStyle = AppTextStyles.bodyS.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final match = RegExp(r'^(\d+(?:\.\d+)?)(.*)$').firstMatch(value);
    final number = match == null ? null : double.tryParse(match.group(1)!);
    if (number == null) {
      return _valueText(value, style, unitStyle);
    }
    final decimals = match!.group(1)!.contains('.')
        ? match.group(1)!.split('.').last.length
        : 0;
    final suffix = match.group(2)!;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: number),
      duration: context.motion(AppTokens.numberRoll),
      curve: AppTokens.curveBase,
      builder: (context, animated, _) => _valueText(
        '${animated.toStringAsFixed(decimals)}$suffix',
        style,
        unitStyle,
      ),
    );
  }

  Widget _valueText(String text, TextStyle style, TextStyle unitStyle) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text, style: style),
          if (unit != null) TextSpan(text: unit, style: unitStyle),
        ],
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class MetricRing extends StatelessWidget {
  const MetricRing({
    super.key,
    required this.value,
    required this.label,
    this.size = 64,
    this.strokeWidth = 8,
    this.color,
    this.center,
  });

  final double value;
  final String label;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final ringColor = color ?? scheme.primary;
    final normalized = (value.isFinite ? value : 0).clamp(0, 100) / 100;
    return Semantics(
      label: '$label ${value.toStringAsFixed(1)}%',
      child: RepaintBoundary(
        child: SizedBox(
          width: size,
          height: size,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: normalized),
            duration: context.motion(AppTokens.ringFill),
            curve: AppTokens.curveEmphasis,
            builder: (context, progress, _) => CustomPaint(
              painter: _RingPainter(
                progress: progress,
                color: ringColor,
                trackColor: scheme.surfaceContainerHighest,
                strokeWidth: strokeWidth,
              ),
              child: Center(
                child: SizedBox(
                  width: math.max(0, size - strokeWidth * 2 - 6),
                  height: math.max(0, size - strokeWidth * 2 - 6),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child:
                        center ??
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: AppTextStyles.bodyS.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
