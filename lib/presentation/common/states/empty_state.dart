import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 56 : 72,
              height: compact ? 56 : 72,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: compact ? 26 : 32, color: scheme.primary),
            ),
            const SizedBox(height: AppTokens.s16),
            Text(
              title,
              style: AppTextStyles.titleM,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppTokens.s8),
              Text(
                message!,
                style: AppTextStyles.bodyM.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTokens.s24),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
