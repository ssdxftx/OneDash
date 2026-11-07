import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/cronjob/cronjob_dto.dart';
import '../../../../data/repositories_impl/cronjob_repository_impl.dart';
import '../../../common/components/action_sheet.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/removable_list_item.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/formatters/enum_labels.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/entry_animation.dart';
import '../../../common/states/error_toast.dart';
import 'cronjob_form_page.dart';
import '../providers/cronjobs_provider.dart';
import '../widgets/cronjob_records_sheet.dart';
import '../../../common/formatters/value_labels.dart';

class CronjobsPage extends ConsumerStatefulWidget {
  const CronjobsPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<CronjobsPage> createState() => _CronjobsPageState();
}

class _CronjobsPageState extends ConsumerState<CronjobsPage>
    with EntryAnimation<CronjobsPage> {
  final Set<int> _removing = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cronjobs = ref.watch(cronjobsProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.cronjobs_title,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(cronjobsProvider),
          ),
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.cronjobs_create,
            onPressed: () =>
                context.push('/s/${widget.serverId}/more/cronjobs/form'),
          ),
        ],
      ),
      body: AsyncStateView(
        value: cronjobs,
        onRetry: () => ref.invalidate(cronjobsProvider),
        loading: const SkeletonList(itemCount: 8),
        isEmpty: (data) => data.items.isEmpty,
        empty: EmptyState(
          icon: TablerIcons.clock,
          title: l10n.cronjobs_empty_title,
          message: l10n.cronjobs_empty_message,
          actionLabel: l10n.cronjobs_create,
          onAction: () =>
              context.push('/s/${widget.serverId}/more/cronjobs/form'),
        ),
        builder: (data) {
          stopEntryAnimation(data.items.isNotEmpty);
          return ListView.builder(
            padding: EdgeInsets.all(context.pagePadding),
            itemCount: data.items.length,
            itemBuilder: (context, index) {
              final item = data.items[index];
              return RemovableListItem(
                key: ValueKey('cronjob-${item.id}'),
                removing: _removing.contains(item.id),
                animateIn: entryAnimationEnabled,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.s12),
                  child: _CronjobCard(
                    item: item,
                    onTap: () => _showActions(context, ref, item),
                    onLongPress: () => _showActions(context, ref, item),
                  ),
                ),
              );
            },
          );
        },
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
    final colors = context.appColors;
    await showAppSheet<void>(
      context: context,
      maxHeightFactor: 0.85,
      builder: (sheetContext) => ActionSheetScaffold(
        infoCard: ActionSheetInfoCard(
          leading: Container(
            decoration: BoxDecoration(
              color: (enabled ? colors.success : colors.info).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(AppTokens.rMd),
            ),
            child: Icon(
              TablerIcons.clock,
              color: enabled ? colors.success : colors.info,
              size: AppTokens.iconNav,
            ),
          ),
          title: item.name,
          subtitle: item.spec,
          trailing: ActionSheetStatusPill(
            label: enabled ? l10n.cronjobs_enabled : l10n.cronjobs_disabled,
            color: enabled ? colors.success : colors.info,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActionSheetSection(
              title: l10n.cronjobs_actions,
              icon: TablerIcons.player_play,
              children: [
                ActionSheetRow(
                  icon: TablerIcons.player_play,
                  iconColor: colors.success,
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
                ActionSheetRow(
                  icon: enabled
                      ? TablerIcons.player_pause
                      : TablerIcons.player_play,
                  iconColor: colors.warning,
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
                ActionSheetRow(
                  icon: TablerIcons.clock_stop,
                  iconColor: colors.warning,
                  title: l10n.cronjobs_stopRunning,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _run(context, ref, item, () async {
                      final repository = await ref.read(
                        cronjobRepositoryProvider.future,
                      );
                      await repository.stopCronjob(item.id);
                    });
                  },
                ),
              ],
            ),
            ActionSheetSection(
              title: l10n.cronjobs_records,
              icon: TablerIcons.history,
              children: [
                ActionSheetRow(
                  icon: TablerIcons.edit,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.cronjobs_edit,
                  onTap: () => showCronjobFormSheet(
                    sheetContext,
                    serverId: widget.serverId,
                    cronjobId: item.id,
                  ),
                ),
                ActionSheetRow(
                  icon: TablerIcons.history,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.cronjobs_records,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    showAppSheet<void>(
                      context: context,
                      maxHeightFactor: 0.85,
                      builder: (sheetContext) =>
                          CronjobRecordsSheet(cronjob: item),
                    );
                  },
                ),
              ],
            ),
            ActionSheetSection(
              title: l10n.containers_groupDanger,
              icon: TablerIcons.alert_triangle,
              children: [
                ActionSheetRow(
                  icon: TablerIcons.trash,
                  iconColor: colors.danger,
                  title: l10n.action_delete,
                  danger: true,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final confirmed = await showConfirmSheet(
                      context,
                      title: l10n.cronjobs_deleteTitle(item.name),
                      message: l10n.cronjobs_deleteMessage,
                      confirmLabel: l10n.action_delete,
                      requireText: item.name,
                    );
                    if (!confirmed || !context.mounted) return;
                    await _run(context, ref, item, () async {
                      final repository = await ref.read(
                        cronjobRepositoryProvider.future,
                      );
                      await repository.deleteCronjob([item.id]);
                    }, removeId: item.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    CronjobDto item,
    Future<void> Function() action, {
    int? removeId,
  }) async {
    final l10n = AppLocalizations.of(context);
    try {
      await action();
      if (!context.mounted) return;
      if (removeId != null) {
        setState(() => _removing.add(removeId));
        await Future<void>.delayed(context.motion(AppTokens.dBase));
        if (!context.mounted) return;
      }
      AppToast.success(context, l10n.action_done);
      ref.invalidate(cronjobsProvider);
      if (removeId != null) {
        await ref.read(cronjobsProvider.future);
      }
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    } finally {
      if (removeId != null && mounted) {
        setState(() => _removing.remove(removeId));
      }
    }
  }
}

class _CronjobCard extends StatelessWidget {
  const _CronjobCard({
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  final CronjobDto item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    return TonalCard(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
                  cronjobTypeLabel(item.type, l10n),
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Text(
            displayValue(context, item.spec),
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
                      : formatListTime(
                          DateTime.tryParse(item.lastRecordTime),
                          l10n,
                          fallback: item.lastRecordTime,
                        ),
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (item.lastRecordStatus.isNotEmpty) ...[
                StatusDot(status: item.lastRecordStatus.toLowerCase()),
                const SizedBox(width: 4),
                Text(
                  taskStatusLabel(item.lastRecordStatus, l10n),
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
