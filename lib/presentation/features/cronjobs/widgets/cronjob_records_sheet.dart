import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/cronjob/cronjob_dto.dart';
import '../../../../data/repositories_impl/cronjob_repository_impl.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../providers/cronjobs_provider.dart';

class CronjobRecordsSheet extends ConsumerWidget {
  const CronjobRecordsSheet({super.key, required this.cronjob});

  final CronjobDto cronjob;

  Future<void> _clean(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.cronjobs_cleanRecords,
      message: l10n.cronjobs_cleanRecordsConfirm(cronjob.name),
      confirmLabel: l10n.cronjobs_cleanRecords,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(cronjobRepositoryProvider.future);
      await repository.cleanRecords(cronjobID: cronjob.id);
      ref.invalidate(cronjobRecordsProvider(cronjob.id));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showLog(
    BuildContext context,
    WidgetRef ref,
    CronjobRecordDto record,
  ) async {
    try {
      final repository = await ref.read(cronjobRepositoryProvider.future);
      final log = await repository.getRecordLog(record.id);
      if (!context.mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.85,
        builder: (sheetContext) {
          final l10n = AppLocalizations.of(sheetContext);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.cronjobs_recordLog, style: AppTextStyles.titleL),
              const SizedBox(height: AppTokens.s12),
              SelectableText(
                log.isEmpty ? l10n.cronjobs_recordLogEmpty : log,
                style: AppTextStyles.caption.copyWith(fontFamily: 'monospace'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final records = ref.watch(cronjobRecordsProvider(cronjob.id));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.cronjobs_records, style: AppTextStyles.titleL),
                  Text(
                    cronjob.name,
                    style: AppTextStyles.bodyS.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SecondaryButton(
              label: l10n.cronjobs_cleanRecords,
              expanded: false,
              onPressed: () => _clean(context, ref),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s16),
        SizedBox(
          height: (MediaQuery.sizeOf(context).height * 0.45)
              .clamp(200.0, 420.0)
              .toDouble(),
          child: AsyncStateView(
            value: records,
            onRetry: () => ref.invalidate(cronjobRecordsProvider(cronjob.id)),
            loading: const SkeletonList(itemCount: 4, itemHeight: 64),
            isEmpty: (data) => data.items.isEmpty,
            empty: EmptyState(
              icon: TablerIcons.history,
              title: l10n.cronjobs_noRecords,
              message: l10n.cronjobs_noRecordsHint,
            ),
            builder: (data) => SingleChildScrollView(
              child: SplitListGroup(
                children: [
                  for (final record in data.items)
                    SplitListTile(
                      leading: StatusDot(status: record.status.toLowerCase()),
                      title: formatLocalDateTime(
                        record.startTime,
                        locale: AppLocalizations.of(context).localeName,
                      ),
                      subtitle: record.message.isEmpty
                          ? record.status
                          : record.message,
                      trailing: const Icon(TablerIcons.chevron_right),
                      onTap: () => _showLog(context, ref, record),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
