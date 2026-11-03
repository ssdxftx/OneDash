import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/alert/alert_dto.dart';
import '../../../../data/repositories_impl/alert_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/formatters/enum_labels.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

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
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.alerts_create,
            onPressed: () => context.push('/s/$serverId/more/alerts/form'),
          ),
        ],
      ),
      body: SegmentedTabsView(
        labels: [
          l10n.panelSettings_alertList,
          l10n.panelSettings_alertLogs,
          l10n.panelSettings_notificationMethods,
        ],
        children: [
          _AlertListTab(serverId: serverId),
          const _AlertLogTab(),
          const _AlertSettingsTab(),
        ],
      ),
    );
  }
}

class _AlertListTab extends ConsumerWidget {
  const _AlertListTab({required this.serverId});

  final int serverId;

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
            actionLabel: l10n.alerts_create,
            onAction: () => context.push('/s/$serverId/more/alerts/form'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppTokens.pagePadding),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
          itemBuilder: (context, index) {
            final alert = items[index];
            return _AlertCard(
              alert: alert,
              onTap: () async {
                await context.push(
                  '/s/$serverId/more/alerts/form?id=${alert.id}',
                );
                ref.invalidate(_alertsProvider);
              },
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
                  showErrorToast(
                    context,
                    error,
                    prefix: l10n.panelSettings_operationFailed,
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
                  showErrorToast(
                    context,
                    error,
                    prefix: l10n.panelSettings_deleteFailed,
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
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final AlertInfo alert;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  Widget _metaText(String text, ColorScheme scheme, {int maxLines = 1}) {
    return Text(
      text,
      style: AppTextStyles.bodyS.copyWith(color: scheme.onSurfaceVariant),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _metaRow(String label, String value, ColorScheme scheme) {
    final style = AppTextStyles.bodyS.copyWith(color: scheme.onSurfaceVariant);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: style, maxLines: 1),
        Expanded(
          child: Text(
            value,
            style: style,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final enabled = alert.status == 'Enable';
    return TonalCard(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 320 ||
              (MediaQuery.textScalerOf(context).scale(1) >= 1.3 &&
                  constraints.maxWidth < 430);
          final meta = compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _metaRow(
                      l10n.alerts_metaTypeLabel,
                      alertTypeLabel(alert.type, l10n),
                      scheme,
                    ),
                    _metaRow(
                      l10n.alerts_metaMethodLabel,
                      alertMethodLabel(alert.method, l10n),
                      scheme,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Flexible(
                      child: _metaText(
                        l10n.alerts_metaType(alertTypeLabel(alert.type, l10n)),
                        scheme,
                      ),
                    ),
                    Text(
                      ' · ',
                      style: AppTextStyles.bodyS.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Flexible(
                      child: _metaText(
                        l10n.alerts_metaMethod(
                          alertMethodLabel(alert.method, l10n),
                        ),
                        scheme,
                      ),
                    ),
                  ],
                );
          final menu = PopupMenuButton<String>(
            tooltip: l10n.action_more,
            icon: Icon(
              TablerIcons.dots,
              size: AppTokens.iconList,
              color: scheme.onSurfaceVariant,
            ),
            onSelected: (value) {
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'delete', child: Text(l10n.common_delete)),
            ],
          );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.title.isEmpty ? alert.type : alert.title,
                            style: AppTextStyles.titleM,
                            maxLines: compact ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!compact) menu,
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(child: meta),
                        if (compact) menu,
                        Switch(
                          value: enabled,
                          onChanged: (_) => onToggle(),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
                  onPressed: items.isEmpty
                      ? null
                      : () async {
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
                            AppToast.success(
                              context,
                              l10n.panelSettings_logsCleared,
                            );
                            ref.invalidate(_alertLogsProvider);
                          } catch (error) {
                            if (!context.mounted) return;
                            showErrorToast(
                              context,
                              error,
                              prefix: l10n.panelSettings_clearFailed,
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
                    padding: const EdgeInsets.all(AppTokens.pagePadding),
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
                            Text(
                              log.message,
                              style: AppTextStyles.bodyM,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (log.method.isNotEmpty) ...[
                              const SizedBox(height: AppTokens.s4),
                              Text(
                                alertMethodLabel(log.method, l10n),
                                style: AppTextStyles.caption.copyWith(
                                  color: context.scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppTokens.s8),
                            Row(
                              children: [
                                StatusDot(
                                  status: success ? 'running' : 'error',
                                ),
                                const SizedBox(width: AppTokens.s8),
                                Text(
                                  alertLogStatusLabel(log.status, l10n),
                                  style: AppTextStyles.caption.copyWith(
                                    color: success
                                        ? context.appColors.success
                                        : context.scheme.error,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  formatListTime(
                                    DateTime.tryParse(log.createdAt ?? ''),
                                    l10n,
                                    fallback: log.createdAt ?? '',
                                  ),
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

final _alertConfigsProvider = FutureProvider.autoDispose<List<AlertConfigInfo>>(
  (ref) async {
    final repository = await ref.watch(alertRepositoryProvider.future);
    return repository.getAlertConfigs();
  },
  name: 'alertConfigsSettingsProvider',
);

class _AlertSettingsTab extends ConsumerWidget {
  const _AlertSettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final configs = ref.watch(_alertConfigsProvider);
    return ListView(
      padding: const EdgeInsets.all(AppTokens.pagePadding),
      children: [
        Text(
          l10n.panelSettings_webPanelRequired,
          style: AppTextStyles.bodyS.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppTokens.s16),
        PrimaryButton(
          label: l10n.alerts_addNotification,
          icon: TablerIcons.plus,
          onPressed: () => _edit(context, ref),
        ),
        const SizedBox(height: AppTokens.s16),
        AsyncStateView(
          value: configs,
          onRetry: () => ref.invalidate(_alertConfigsProvider),
          loading: const SkeletonList(itemCount: 4),
          isEmpty: (items) => items.isEmpty,
          empty: EmptyState(
            icon: TablerIcons.bell_off,
            title: l10n.panelSettings_notificationMethodsEmptyTitle,
            message: l10n.alerts_noConfigs,
          ),
          builder: (items) => Column(
            children: [
              for (final config in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.s12),
                  child: TonalCard(
                    onTap: () => _edit(context, ref, config),
                    child: Row(
                      children: [
                        StatusDot(
                          status: config.status == 'Enable'
                              ? 'running'
                              : 'stopped',
                        ),
                        const SizedBox(width: AppTokens.s8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                config.title.isEmpty
                                    ? config.type
                                    : config.title,
                                style: AppTextStyles.titleS,
                              ),
                              Text(
                                config.type,
                                style: AppTextStyles.caption.copyWith(
                                  color: context.scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.alerts_testNotification,
                          icon: const Icon(TablerIcons.send),
                          onPressed: () => _test(context, ref, config),
                        ),
                        IconButton(
                          tooltip: l10n.action_delete,
                          icon: Icon(
                            TablerIcons.trash,
                            color: context.appColors.danger,
                          ),
                          onPressed: () => _delete(context, ref, config),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    AlertConfigInfo? current,
  ]) async {
    final l10n = AppLocalizations.of(context);
    final repository = await ref.read(alertRepositoryProvider.future);
    var config = current;
    if (config == null) {
      try {
        config = await repository.getAlertConfig();
      } catch (_) {
        config = null;
      }
    }
    if (!context.mounted) return;
    final title = TextEditingController(text: config?.title ?? '');
    final type = TextEditingController(
      text: config?.type.isNotEmpty == true ? config!.type : 'email',
    );
    final content = TextEditingController(text: config?.config ?? '');
    var status = config?.status == 'Enable' || config == null;
    final saved = await showAppSheet<bool>(
      context: context,
      maxHeightFactor: 0.92,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              current == null
                  ? l10n.alerts_addNotification
                  : l10n.alerts_editNotification,
              style: AppTextStyles.titleL,
            ),
            const SizedBox(height: AppTokens.s16),
            AppTextField(controller: title, label: l10n.alerts_title),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: type, label: l10n.alerts_type),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: content,
              label: l10n.alerts_configContent,
              maxLines: 10,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.websites_enabled),
              value: status,
              onChanged: (value) => setState(() => status = value),
            ),
            const SizedBox(height: AppTokens.s16),
            PrimaryButton(
              label: l10n.action_save,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    );
    final titleValue = title.text.trim();
    final typeValue = type.text.trim();
    final contentValue = content.text.trim();
    title.dispose();
    type.dispose();
    content.dispose();
    if (saved != true || !context.mounted || typeValue.isEmpty) return;
    try {
      await repository.updateAlertConfig(
        AlertConfigUpdateReq(
          id: current?.id ?? 0,
          type: typeValue,
          title: titleValue,
          config: contentValue,
          status: status ? 'Enable' : 'Disable',
        ),
      );
      ref.invalidate(_alertConfigsProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _test(
    BuildContext context,
    WidgetRef ref,
    AlertConfigInfo config,
  ) async {
    final l10n = AppLocalizations.of(context);
    Map<String, dynamic> raw = const {};
    try {
      final decoded = jsonDecode(config.config);
      if (decoded is Map<String, dynamic>) raw = decoded;
    } catch (_) {
      if (!context.mounted) return;
      AppToast.warning(context, l10n.alerts_configInvalid);
      return;
    }
    try {
      final repository = await ref.read(alertRepositoryProvider.future);
      final ok = await repository.testAlertConfig(
        AlertConfigTestReq(
          host: '${raw['host'] ?? ''}',
          port: int.tryParse('${raw['port'] ?? 0}') ?? 0,
          sender: '${raw['sender'] ?? ''}',
          userName: '${raw['userName'] ?? raw['username'] ?? ''}',
          password: '${raw['password'] ?? ''}',
          displayName: '${raw['displayName'] ?? ''}',
          encryption: '${raw['encryption'] ?? ''}',
          recipient: '${raw['recipient'] ?? ''}',
        ),
      );
      if (!context.mounted) return;
      if (ok) {
        AppToast.success(context, l10n.alerts_testSent);
      } else {
        AppToast.warning(context, l10n.alerts_testFailed);
      }
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AlertConfigInfo config,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: config.title.isEmpty ? config.type : config.title,
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(alertRepositoryProvider.future);
      await repository.deleteAlertConfig(config.id);
      ref.invalidate(_alertConfigsProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}
