import 'package:flutter/material.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import 'error_mapper.dart';

class ErrorState extends StatefulWidget {
  const ErrorState({
    super.key,
    required this.data,
    this.onRetry,
    this.onSecondaryAction,
    this.compact = false,
  });

  final ErrorViewData data;
  final VoidCallback? onRetry;
  final VoidCallback? onSecondaryAction;
  final bool compact;

  @override
  State<ErrorState> createState() => _ErrorStateState();
}

class _ErrorStateState extends State<ErrorState> {
  bool _showDetail = false;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final l10n = AppLocalizations.of(context);
    final color = errorColor(context, widget.data.kind);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: widget.compact ? 56 : 72,
              height: widget.compact ? 56 : 72,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.data.icon,
                size: widget.compact ? 26 : 32,
                color: color,
              ),
            ),
            const SizedBox(height: AppTokens.s16),
            Text(
              widget.data.title,
              style: AppTextStyles.titleM,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.s8),
            Text(
              widget.data.message,
              style: AppTextStyles.bodyM.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.onRetry != null || widget.onSecondaryAction != null) ...[
              const SizedBox(height: AppTokens.s24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.onSecondaryAction != null &&
                      widget.data.secondaryActionLabel != null)
                    OutlinedButton(
                      onPressed: widget.onSecondaryAction,
                      child: Text(widget.data.secondaryActionLabel!),
                    ),
                  if (widget.onSecondaryAction != null &&
                      widget.onRetry != null)
                    const SizedBox(width: AppTokens.s12),
                  if (widget.onRetry != null)
                    FilledButton(
                      onPressed: widget.onRetry,
                      child: Text(widget.data.actionLabel ?? l10n.common_retry),
                    ),
                ],
              ),
            ],
            if (widget.data.detail != null) ...[
              const SizedBox(height: AppTokens.s16),
              TextButton.icon(
                onPressed: () => setState(() => _showDetail = !_showDetail),
                icon: Icon(
                  _showDetail ? Icons.expand_less : Icons.expand_more,
                  size: AppTokens.iconList,
                ),
                label: Text(l10n.error_details),
              ),
              if (_showDetail)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: AppTokens.s8),
                  padding: const EdgeInsets.all(AppTokens.s12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppTokens.rMd),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: SelectableText(
                    widget.data.detail!,
                    style: AppTextStyles.bodyS.copyWith(
                      fontFamily: 'monospace',
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
