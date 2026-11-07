import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tokens.dart';

/// Three-part capsule app bar: back, centred title and primary action.
class PillAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PillAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actionLabel,
    this.onAction,
    this.actionBusy = false,
  });

  final String title;
  final VoidCallback? onBack;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool actionBusy;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            const SizedBox(width: 12),
            _Pill(
              background: scheme.surfaceContainerHighest,
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: const Icon(TablerIcons.arrow_left, size: 18),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleS,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _Pill(
              background: scheme.primaryContainer,
              onTap: actionBusy ? null : onAction,
              child: actionBusy
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      actionLabel ?? '',
                      style: AppTextStyles.label.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.background,
    required this.onTap,
    required this.child,
  });

  final Color background;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppTokens.rFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.rFull),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.s16,
            vertical: AppTokens.s8,
          ),
          child: child,
        ),
      ),
    );
  }
}
