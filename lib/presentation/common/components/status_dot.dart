import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

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

class _StatusDotState extends State<StatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppTokens.dLoop,
  );

  bool get _shouldPulse {
    final status = widget.status.toLowerCase();
    return status == 'error' || status == 'failed' || status == 'dead';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shouldPulse && !context.reduceMotion) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant StatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.appColors.status(widget.status);
    final dot = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = _shouldPulse ? 0.55 + 0.45 * _controller.value : 1.0;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
    return Semantics(
      label: widget.semanticLabel ?? widget.status,
      child: ExcludeSemantics(child: dot),
    );
  }
}
