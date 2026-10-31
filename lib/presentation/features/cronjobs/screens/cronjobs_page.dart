import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/common/page_result.dart';
import '../../../../data/dto/cronjob/cronjob_dto.dart';
import '../../../../data/repositories_impl/cronjob_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

final _cronjobsProvider = FutureProvider.autoDispose<PageResult<CronjobDto>>((
  ref,
) {
  return ref
      .watch(cronjobRepositoryProvider.future)
      .then(
        (repository) => repository.searchCronjobs({'page': 1, 'pageSize': 100}),
      );
}, name: 'cronjobsProvider');

class CronjobsPage extends ConsumerWidget {
  const CronjobsPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cronjobs = ref.watch(_cronjobsProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.cronjobs_title,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_cronjobsProvider),
          ),
        ],
      ),
      body: AsyncStateView(
        value: cronjobs,
        onRetry: () => ref.invalidate(_cronjobsProvider),
        loading: const SkeletonList(itemCount: 8),
        isEmpty: (data) => data.items.isEmpty,
        empty: EmptyState(
          icon: TablerIcons.clock,
          title: l10n.cronjobs_empty_title,
          message: l10n.cronjobs_empty_message,
        ),
        builder: (data) => ListView.builder(
          padding: const EdgeInsets.all(AppTokens.s16),
          itemCount: data.items.length,
          itemBuilder: (context, index) {
            final item = data.items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.s12),
              child: _CronjobCard(
                item: item,
                onLongPress: () => _showActions(context, ref, item),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    CronjobDto item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final enabled = item.status.toLowerCase() == 'enable';
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s4),
          Text(
            item.spec,
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.player_play),
                title: l10n.cronjobs_runOnce,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _run(context, ref, item, () async {
                    final repository = await ref.read(
                      cronjobRepositoryProvider.future,
                    );
                    await repository.handleOnce(item.id);
                  });
                },
              ),
              SplitListTile(
                leading: Icon(
                  enabled ? TablerIcons.player_pause : TablerIcons.player_play,
                ),
                title: enabled ? l10n.cronjobs_disable : l10n.cronjobs_enable,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _run(context, ref, item, () async {
                    final repository = await ref.read(
                      cronjobRepositoryProvider.future,
                    );
                    await repository.updateStatus(
                      item.id,
                      enabled ? 'disable' : 'enable',
                    );
                  });
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.trash),
                title: l10n.action_delete,
                danger: true,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final confirmed = await showConfirmSheet(
                    context,
                    title: l10n.action_delete,
                    message: item.name,
                    confirmLabel: l10n.action_delete,
                  );
                  if (!confirmed) return;
                  if (!context.mounted) return;
                  await _run(context, ref, item, () async {
                    final repository = await ref.read(
                      cronjobRepositoryProvider.future,
                    );
                    await repository.deleteCronjob([item.id]);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
        ],
      ),
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    CronjobDto item,
    Future<void> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await action();
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_cronjobsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _CronjobCard extends StatelessWidget {
  const _CronjobCard({required this.item, required this.onLongPress});

  final CronjobDto item;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final enabled = item.status.toLowerCase() == 'enable';
    return TonalCard(
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusDot(status: enabled ? 'running' : 'stopped'),
              const SizedBox(width: AppTokens.s8),
              Expanded(
                child: Text(
                  item.name,
                  style: AppTextStyles.titleM,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.s8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppTokens.rXs),
                ),
                child: Text(
                  item.type,
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Text(
            item.spec.isEmpty ? '-' : item.spec,
            style: AppTextStyles.bodyS.copyWith(
              color: scheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTokens.s8),
          Row(
            children: [
              Icon(
                TablerIcons.history,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.lastRecordTime.isEmpty
                      ? l10n.cronjobs_neverRun
                      : item.lastRecordTime,
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (item.lastRecordStatus.isNotEmpty)
                StatusDot(status: item.lastRecordStatus.toLowerCase()),
            ],
          ),
        ],
      ),
    );
  }
}
