import 'dart:math' as math;

const double appEdgeFadeWidth = 28;

List<double> appEdgeFadeStops(double width) {
  final fade = (appEdgeFadeWidth / math.max(width, 1)).clamp(0.0, 0.5);
  return [0, fade, 1 - fade, 1];
}
