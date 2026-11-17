import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../common/components/app_icon.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';

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
    return TonalCard(
      onTap: onTap,
      child: Row(
        children: [
          AppIcon(
            name: name,
            icon: icon,
            size: 36,
            cacheKey: cacheKey,
            iconLoader: iconLoader,
          ),
          const SizedBox(width: AppTokens.s12),
          if (status != null) ...[
            StatusDot(status: status!.toLowerCase()),
            const SizedBox(width: AppTokens.s8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.titleM,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
