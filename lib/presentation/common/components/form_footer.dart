import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class FormFooter extends StatelessWidget {
  const FormFooter({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s12,
          AppTokens.s16,
          AppTokens.s16,
        ),
        child: child,
      ),
    );
  }
}
