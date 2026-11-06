import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import 'status_pulse.dart';

class StatusDot extends StatefulWidget {
  const StatusDot({
    super.key,
    required this.status,
    this.size = 8,
    this.semanticLabel,
  });

  final String status;
  final double size;
  final String? semanticLabel;

  @override
  State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot> {
  bool _attached = false;

  bool get _shouldPulse {
    final status = widget.status.toLowerCase();
    return status == 'error' || status == 'failed' || status == 'dead';
  }

  bool get _pulsing =>
      _shouldPulse &&
      !context.reduceMotion &&
      TickerMode.valuesOf(context).enabled;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pulsing && !_attached) {
      StatusPulse.attach();
      _attached = true;
    } else if (!_pulsing && _attached) {
      StatusPulse.detach();
      _attached = false;
    }
  }

  @override
  void didUpdateWidget(covariant StatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) didChangeDependencies();
  }

  @override
  void dispose() {
    if (_attached) StatusPulse.detach();
    super.dispose();
  }

  Widget _dot(Color color, double opacity) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.appColors.status(widget.status);
    final dot = _pulsing
        ? ValueListenableBuilder<double>(
            valueListenable: StatusPulse.value,
            builder: (context, pulse, _) => _dot(color, 0.55 + 0.45 * pulse),
          )
        : _dot(color, 1);
    return Semantics(
      label: widget.semanticLabel ?? widget.status,
      child: ExcludeSemantics(child: dot),
    );
  }
}
