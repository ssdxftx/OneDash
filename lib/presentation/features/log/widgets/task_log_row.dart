import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../common/components/status_pill.dart';
import '../../../common/components/tonal_card.dart';
import '../models/task_log_item.dart';
import 'log_row_parts.dart';

class TaskLogRow extends StatelessWidget {
  const TaskLogRow({super.key, required this.item, this.onTap});

  final TaskLogItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final tone = item.isExecuting
        ? colors.warning
        : (item.isSuccess ? colors.success : colors.danger);
    final label = item.isExecuting
        ? l10n.taskLog_executing
        : (item.isSuccess ? l10n.common_success : l10n.common_failed);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.s8),
      child: TonalCard(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusIconBlock(
              tone: tone,
              icon: item.isExecuting
                  ? TablerIcons.clock_play
                  : (item.isSuccess
                        ? TablerIcons.list_check
                        : TablerIcons.playlist_x),
            ),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleS,
                        ),
                      ),
                      const SizedBox(width: AppTokens.s8),
                      StatusPill(label: label, tone: tone),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: AppTokens.s12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (item.subtitle.trim().isNotEmpty)
                        MetaInfo(
                          icon: TablerIcons.activity,
                          text: item.subtitle,
                        ),
                      MetaInfo(
                        icon: TablerIcons.clock,
                        text: formatLogTime(item.createdAt),
                      ),
                    ],
                  ),
                  if (!item.isSuccess &&
                      !item.isExecuting &&
                      item.errorMsg.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    LogErrorText(text: item.errorMsg),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
