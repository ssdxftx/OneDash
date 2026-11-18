import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../common/components/app_icon.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/formatters/status_labels.dart';

/// Shared app card used by the app store installed list and dashboard launcher.
class InstalledAppCard extends StatelessWidget {
  const InstalledAppCard({
    super.key,
    required this.name,
    this.icon,
    this.cacheKey,
    this.iconLoader,
    this.subtitle,
    this.status,
    this.canUpdate = false,
    this.updateLabel,
    this.onTap,
  });

  final String name;
  final String? icon;
  final String? cacheKey;
  final Future<Uint8List> Function()? iconLoader;
  final String? subtitle;
  final String? status;
  final bool canUpdate;
  final String? updateLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final l10n = AppLocalizations.of(context);
    return TonalCard(
      onTap: onTap,
      child: Row(
        children: [
          AppIcon(
            name: name,
            icon: icon,
            size: AppTokens.iconAppSmall,
            cacheKey: cacheKey,
            iconLoader: iconLoader,
          ),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: AppTextStyles.titleM,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (status != null) ...[
                      const SizedBox(width: AppTokens.s8),
                      ExcludeSemantics(
                        child: StatusDot(
                          status: status!.toLowerCase(),
                          size: AppTokens.rXs,
                        ),
                      ),
                      const SizedBox(width: AppTokens.s4),
                      Flexible(
                        child: Text(
                          appStatusLabel(status!, l10n),
                          style: AppTextStyles.caption.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty)
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodyS.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (canUpdate && updateLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.s8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: context.appColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTokens.rXs),
              ),
              child: Text(
                updateLabel!,
                style: AppTextStyles.caption.copyWith(
                  color: context.appColors.warning,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
