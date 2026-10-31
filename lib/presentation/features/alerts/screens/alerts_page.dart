import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/alert/alert_dto.dart';
import '../../../../data/repositories_impl/alert_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';

final _alertsProvider = FutureProvider.autoDispose<List<AlertInfo>>((
  ref,
) async {
  final repository = await ref.watch(alertRepositoryProvider.future);
  final result = await repository.searchAlerts(
    const AlertSearchReq(page: 1, pageSize: 100),
  );
  return result.items;
}, name: 'alertsProvider');

final _alertLogsProvider = FutureProvider.autoDispose<List<AlertLogInfo>>((
  ref,
) async {
  final repository = await ref.watch(alertRepositoryProvider.future);
  final result = await repository.searchAlertLogs(
    const AlertLogSearchReq(page: 1, pageSize: 50),
  );
  return result.items;
}, name: 'alertLogsProvider');

class AlertsPage extends ConsumerWidget {
  const AlertsPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.panelSettings_alerts,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () {
              ref.invalidate(_alertsProvider);
              ref.invalidate(_alertLogsProvider);
            },
          ),
        ],
      ),
      body: SegmentedTabsView(
        labels: [
          l10n.panelSettings_alertList,
          l10n.panelSettings_alertLogs,
          l10n.panelSettings_notificationMethods,
        ],
        children: const [_AlertListTab(), _AlertLogTab(), _AlertSettingsTab()],
      ),
    );
  }
}

class _AlertListTab extends ConsumerWidget {
  const _AlertListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final alerts = ref.watch(_alertsProvider);
    return AsyncStateView(
      value: alerts,
      onRetry: () => ref.invalidate(_alertsProvider),
      loading: const SkeletonList(itemCount: 6),
      builder: (items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: TablerIcons.bell_off,
            title: l10n.panelSettings_noAlertRules,
            message: l10n.panelSettings_webPanelRequired,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppTokens.s16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
          itemBuilder: (context, index) {
            final alert = items[index];
            return _AlertCard(
              alert: alert,
              onToggle: () async {
                try {
                  final repository = await ref.read(
                    alertRepositoryProvider.future,
                  );
                  await repository.updateAlertStatus(
                    alert.id,
                    alert.status == 'Enable' ? 'Disable' : 'Enable',
                  );
                  ref.invalidate(_alertsProvider);
                } catch (error) {
                  if (!context.mounted) return;
                  AppToast.error(
                    context,
                    '${l10n.panelSettings_operationFailed}: $error',
                  );
                }
              },
              onDelete: () async {
                final confirmed = await showConfirmSheet(
                  context,
                  title: l10n.common_delete,
                  message: l10n.panelSettings_deleteAlertConfirm(
                    alert.title.isEmpty ? alert.type : alert.title,
                  ),
                  confirmLabel: l10n.common_delete,
                );
                if (!confirmed || !context.mounted) return;
                try {
                  final repository = await ref.read(
                    alertRepositoryProvider.future,
                  );
                  await repository.deleteAlert(alert.id);
                  if (!context.mounted) return;
                  AppToast.success(context, l10n.panelSettings_deleted);
                  ref.invalidate(_alertsProvider);
                } catch (error) {
                  if (!context.mounted) return;
                  AppToast.error(
                    context,
                    '${l10n.panelSettings_deleteFailed}: $error',
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.onToggle,
    required this.onDelete,
  });

  final AlertInfo alert;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final enabled = alert.status == 'Enable';
    return TonalCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (enabled ? scheme.primary : scheme.onSurfaceVariant)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTokens.rSm),
            ),
            child: Icon(
              TablerIcons.bell,
              size: AppTokens.iconList,
              color: enabled ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title.isEmpty ? alert.type : alert.title,
                  style: AppTextStyles.titleM,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.panelSettings_alertCardMeta(alert.type, alert.method),
                  style: AppTextStyles.bodyS.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(value: enabled, onChanged: (_) => onToggle()),
          IconButton(
            tooltip: l10n.common_delete,
            onPressed: onDelete,
            icon: Icon(
              TablerIcons.trash,
              size: AppTokens.iconList,
              color: scheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertLogTab extends ConsumerWidget {
  const _AlertLogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final logs = ref.watch(_alertLogsProvider);
    return AsyncStateView(
      value: logs,
      onRetry: () => ref.invalidate(_alertLogsProvider),
      loading: const SkeletonList(itemCount: 6),
      builder: (items) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s16,
              AppTokens.s16,
              AppTokens.s16,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.panelSettings_alertLogs,
                    style: AppTextStyles.titleS,
                  ),
                ),
                SecondaryButton(
                  label: l10n.panelSettings_clearLogs,
                  expanded: false,
                  onPressed: () async {
                    final confirmed = await showConfirmSheet(
                      context,
                      title: l10n.panelSettings_clearLogs,
                      message: l10n.panelSettings_clearLogsConfirm,
                    );
                    if (!confirmed || !context.mounted) return;
                    try {
                      final repository = await ref.read(
                        alertRepositoryProvider.future,
                      );
                      await repository.cleanAlertLogs();
                      if (!context.mounted) return;
                      AppToast.success(context, l10n.panelSettings_logsCleared);
                      ref.invalidate(_alertLogsProvider);
                    } catch (error) {
                      if (!context.mounted) return;
                      AppToast.error(
                        context,
                        '${l10n.panelSettings_clearFailed}: $error',
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    icon: TablerIcons.bell_off,
                    title: l10n.panelSettings_noLogs,
                    message: l10n.panelSettings_alertLogs,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppTokens.s16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppTokens.s8),
                    itemBuilder: (context, index) {
                      final log = items[index];
                      final success =
                          log.status == 'Success' ||
                          log.status == 'PushSuccess';
                      return TonalCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log.message, style: AppTextStyles.bodyM),
                            const SizedBox(height: AppTokens.s8),
                            Row(
                              children: [
                                StatusDot(
                                  status: success ? 'running' : 'error',
                                ),
                                const SizedBox(width: AppTokens.s8),
                                Text(
                                  log.status,
                                  style: AppTextStyles.caption.copyWith(
                                    color: success
                                        ? context.appColors.success
                                        : context.scheme.error,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  log.createdAt ?? '',
                                  style: AppTextStyles.caption.copyWith(
                                    color: context.scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AlertSettingsTab extends ConsumerWidget {
  const _AlertSettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final methods = [
      (
        icon: TablerIcons.mail,
        title: l10n.panelSettings_emailNotification,
        subtitle: l10n.panelSettings_smtpSubtitle,
      ),
      (
        icon: TablerIcons.brand_wechat,
        title: l10n.panelSettings_weCom,
        subtitle: l10n.panelSettings_webhookSubtitle,
      ),
      (
        icon: TablerIcons.brand_dingtalk,
        title: l10n.panelSettings_dingTalk,
        subtitle: l10n.panelSettings_webhookSubtitle,
      ),
      (
        icon: TablerIcons.brand_telegram,
        title: l10n.panelSettings_feishu,
        subtitle: l10n.panelSettings_webhookSubtitle,
      ),
      (
        icon: TablerIcons.bell_ringing,
        title: 'Bark',
        subtitle: l10n.panelSettings_webhookSubtitle,
      ),
    ];
    return ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        Text(
          l10n.panelSettings_webPanelRequired,
          style: AppTextStyles.bodyS.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppTokens.s16),
        SplitListGroup(
          children: [
            for (final method in methods)
              SplitListTile(
                leading: Icon(method.icon),
                title: method.title,
                subtitle: method.subtitle,
                trailing: Text(
                  l10n.panelSettings_webOnlyTag,
                  style: AppTextStyles.caption.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
