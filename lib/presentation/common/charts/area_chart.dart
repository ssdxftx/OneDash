import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class AreaChart extends StatelessWidget {
  const AreaChart({
    super.key,
    required this.seriesA,
    this.seriesB,
    this.colorA,
    this.colorB,
    this.maxY,
    this.minY = 0,
    this.showGrid = true,
    this.strokeWidth = 2,
    this.fill = true,
    this.placeholder,
  });

  final List<double> seriesA;
  final List<double>? seriesB;
  final Color? colorA;
  final Color? colorB;
  final double? maxY;
  final double minY;
  final bool showGrid;
  final double strokeWidth;
  final bool fill;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.appColors;
    final sampleCount = math.max(seriesA.length, seriesB?.length ?? 0);
    if (sampleCount < 3 && placeholder != null) {
      return RepaintBoundary(
        child: Center(
          child: Text(
            placeholder!,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _AreaChartPainter(
              seriesA: seriesA,
              seriesB: seriesB,
              colorA: colorA ?? colors.chart1,
              colorB: colorB ?? colors.chart2,
              maxY: maxY,
              minY: minY,
              gridColor: scheme.outlineVariant.withValues(alpha: 0.35),
              showGrid: showGrid,
              strokeWidth: strokeWidth,
              fill: fill,
            ),
          );
        },
      ),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  _AreaChartPainter({
    required this.seriesA,
    required this.seriesB,
    required this.colorA,
    required this.colorB,
    required this.maxY,
    required this.minY,
    required this.gridColor,
    required this.showGrid,
    required this.strokeWidth,
    required this.fill,
  });

  final List<double> seriesA;
  final List<double>? seriesB;
  final Color colorA;
  final Color colorB;
  final double? maxY;
  final double minY;
  final Color gridColor;
  final bool showGrid;
  final double strokeWidth;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final all = <double>[...seriesA, if (seriesB != null) ...seriesB!];
    final dataMax = all.isEmpty ? 1.0 : all.reduce(math.max);
    final upper = (maxY ?? math.max(dataMax, 1)) * 1.1;
    final lower = minY;
    final range = math.max(upper - lower, 0.0001);

    if (showGrid) {
      final gridPaint = Paint()
        ..color = gridColor
        ..strokeWidth = 1;
      for (var i = 0; i <= 2; i++) {
        final y = size.height * i / 2;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    void drawSeries(List<double> data, Color color, bool withFill) {
      final points = _downsample(data, size.width.round());
      if (points.isEmpty) return;
      if (points.length == 1) {
        final normalized = ((points.first - lower) / range).clamp(0.0, 1.0);
        final y = size.height - normalized * size.height;
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          Paint()
            ..color = color.withValues(alpha: 0.45)
            ..strokeWidth = strokeWidth,
        );
        return;
      }
      final path = Path();
      final fillPath = Path();
      for (var i = 0; i < points.length; i++) {
        final x = size.width * i / (points.length - 1);
        final normalized = ((points[i] - lower) / range).clamp(0.0, 1.0);
        final y = size.height - normalized * size.height;
        if (i == 0) {
          path.moveTo(x, y);
          fillPath.moveTo(x, size.height);
          fillPath.lineTo(x, y);
        } else {
          path.lineTo(x, y);
          fillPath.lineTo(x, y);
        }
      }
      if (withFill && fill) {
        fillPath
          ..lineTo(size.width, size.height)
          ..close();
        final rect = Offset.zero & size;
        final gradient = ui.Gradient.linear(rect.topLeft, rect.bottomLeft, [
          color.withValues(alpha: 0.18),
          color.withValues(alpha: 0.0),
        ]);
        canvas.drawPath(
          fillPath,
          Paint()
            ..shader = gradient
            ..style = PaintingStyle.fill,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    if (seriesB != null) drawSeries(seriesB!, colorB, false);
    drawSeries(seriesA, colorA, true);
  }

  List<double> _downsample(List<double> data, int width) {
    if (data.length <= 2 || width <= 2) return data;
    final target = math.min(width, data.length);
    if (target >= data.length) return data;
    final step = data.length / target;
    final result = <double>[];
    for (var i = 0; i < target; i++) {
      final start = (i * step).floor();
      final end = math.min(((i + 1) * step).ceil(), data.length);
      var sum = 0.0;
      for (var j = start; j < end; j++) {
        sum += data[j];
      }
      result.add(sum / math.max(end - start, 1));
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) {
    return oldDelegate.seriesA != seriesA ||
        oldDelegate.seriesB != seriesB ||
        oldDelegate.colorA != colorA ||
        oldDelegate.colorB != colorB ||
        oldDelegate.maxY != maxY ||
        oldDelegate.showGrid != showGrid;
  }
}

class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    this.color,
    this.strokeWidth = 1.5,
    this.minValue,
    this.maxValue,
    this.placeholder,
  });

  final List<double> values;
  final Color? color;
  final double strokeWidth;
  final double? minValue;
  final double? maxValue;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    if (values.length < 3) {
      if (placeholder == null) return const SizedBox.shrink();
      return RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _DashedBaselinePainter(
                color: context.scheme.outlineVariant,
              ),
            ),
            if (placeholder != null)
              Center(
                child: Text(
                  placeholder!,
                  style: AppTextStyles.caption.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      );
    }
    return RepaintBoundary(
      child: CustomPaint(
        painter: _SparklinePainter(
          values: values,
          color: color ?? context.appColors.chart1,
          strokeWidth: strokeWidth,
          minValue: minValue,
          maxValue: maxValue,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _DashedBaselinePainter extends CustomPainter {
  _DashedBaselinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final y = size.height / 2;
    const dash = 4.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + dash, size.width), y),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBaselinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.color,
    required this.strokeWidth,
    this.minValue,
    this.maxValue,
  });

  final List<double> values;
  final Color color;
  final double strokeWidth;
  final double? minValue;
  final double? maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.width <= 0 || size.height <= 0) return;
    final upper = maxValue ?? values.reduce(math.max);
    final lower = minValue ?? values.reduce(math.min);
    final range = math.max(upper - lower, 0.0001);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final normalized = ((values[i] - lower) / range).clamp(0.0, 1.0);
      final y = size.height - normalized * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.color != color ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue;
  }
}
