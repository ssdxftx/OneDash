import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../common/components/status_pill.dart';
import '../../../common/components/tonal_card.dart';
import '../models/operation_log_item.dart';
import 'log_row_parts.dart';

class OperationLogRow extends StatelessWidget {
  const OperationLogRow({super.key, required this.item, this.onTap});

  final OperationLogItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final tone = item.isSuccess ? colors.success : colors.danger;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.s8),
      child: TonalCard(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusIconBlock(
              tone: tone,
              icon: item.isSuccess
                  ? TablerIcons.clipboard_check
                  : TablerIcons.clipboard_x,
            ),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleS,
                        ),
                      ),
                      const SizedBox(width: AppTokens.s8),
                      StatusPill(
                        label: item.isSuccess
                            ? l10n.common_success
                            : l10n.common_failed,
                        tone: tone,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s8),
                  Wrap(
                    spacing: AppTokens.s12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (item.source.isNotEmpty)
                        SourceChip(label: item.source),
                      MetaInfo(
                        icon: TablerIcons.clock,
                        text: formatLogTime(item.createdAt),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
