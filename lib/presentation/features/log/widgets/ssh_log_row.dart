import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../common/components/status_pill.dart';
import '../../../common/components/tonal_card.dart';
import '../models/ssh_log_item.dart';
import 'log_row_parts.dart';

class SshLogRow extends StatelessWidget {
  const SshLogRow({super.key, required this.item, this.onTap});

  final SshLogItem item;
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
            StatusIconBlock(tone: tone, icon: TablerIcons.terminal_2),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
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
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: AppTokens.s12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (item.hasArea)
                        MetaInfo(icon: TablerIcons.map_pin, text: item.area),
                      if (item.authMode.isNotEmpty)
                        SourceChip(label: item.authMode),
                      if (item.port.isNotEmpty) SourceChip(label: item.port),
                      MetaInfo(
                        icon: TablerIcons.clock,
                        text: formatLogTime(item.date),
                      ),
                    ],
                  ),
                  if (!item.isSuccess && item.message.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    LogErrorText(text: item.message),
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
