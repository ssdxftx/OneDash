import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';
import '../../../../data/repositories_impl/log_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/task_log_sheet.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../models/login_log_item.dart';
import '../models/operation_log_item.dart';
import '../models/ssh_log_item.dart';
import '../providers/log_providers.dart';
import '../widgets/log_row_parts.dart';
import '../widgets/login_log_row.dart';
import '../widgets/operation_log_row.dart';
import '../widgets/ssh_log_row.dart';
import '../widgets/task_log_row.dart';
import 'log_preview_page.dart';

class LogHubPage extends ConsumerWidget {
  const LogHubPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.logs_title,
        actions: [
          AppIconButton(
            icon: TablerIcons.file_text,
            tooltip: l10n.logs_system,
            onPressed: () => _openSystemLogs(context, ref),
          ),
          AppIconButton(
            icon: TablerIcons.trash,
            tooltip: l10n.logs_clean,
            onPressed: () => _openActions(context, ref),
          ),
        ],
      ),
      body: SegmentedTabsView(
        labels: [
          l10n.logs_operation,
          l10n.logs_login,
          l10n.logs_ssh,
          l10n.logs_task,
        ],
        children: const [
          _OperationLogTab(),
          _LoginLogTab(),
          _SshLogTab(),
          _TaskLogTab(),
        ],
      ),
    );
  }
}

extension on LogHubPage {
  Future<void> _openSystemLogs(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final logRepository = await ref.read(logRepositoryProvider.future);
      final files = await logRepository.getSystemLogFiles();
      if (!context.mounted) return;
      if (files.isEmpty) {
        AppToast.warning(context, l10n.log_empty);
        return;
      }
      final selected = await showSelectionMenu<String>(
        context,
        title: l10n.logs_system,
        options: [
          for (final file in files)
            SelectionOption(
              label: file,
              value: file,
              icon: TablerIcons.file_text,
            ),
        ],
      );
      if (selected == null || !context.mounted) return;
      final fileRepository = await ref.read(fileRepositoryProvider.future);
      if (!context.mounted) return;
      await Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => LogPreviewPage(
            title: selected,
            subtitle: l10n.logs_system,
            sources: [
              LogSourceOption(
                label: selected,
                load: () async {
                  final log = await fileRepository.readRuntimeLog(
                    id: 0,
                    type: 'system',
                    name: selected,
                    pageSize: 1000,
                    latest: true,
                  );
                  return log.lines;
                },
              ),
            ],
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _openActions(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.logs_clean, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.list),
                title: l10n.logs_cleanOperation,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _clean(context, ref, 'operation');
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.login),
                title: l10n.logs_cleanLogin,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _clean(context, ref, 'login');
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.download),
                title: l10n.logs_exportSsh,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  try {
                    final repository = await ref.read(
                      logRepositoryProvider.future,
                    );
                    final path = await repository.exportSshLogs();
                    if (!context.mounted) return;
                    AppToast.success(context, l10n.logs_exported(path));
                  } catch (error) {
                    if (!context.mounted) return;
                    showErrorToast(context, error);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _clean(BuildContext context, WidgetRef ref, String type) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.logs_clean,
      message: l10n.logs_cleanConfirm,
      confirmLabel: l10n.action_clear,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(logRepositoryProvider.future);
      await repository.cleanLogs(type);
      ref.invalidate(operationLogsProvider);
      ref.invalidate(loginLogsProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

Widget _logSkeleton() => const SkeletonList(
  itemCount: 8,
  itemHeight: 104,
  padding: EdgeInsets.all(AppTokens.s16),
);

Widget _emptyState(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return EmptyState(
    icon: TablerIcons.file_text,
    title: l10n.log_empty,
    message: l10n.log_emptyMessage,
  );
}

class _OperationLogTab extends ConsumerWidget {
  const _OperationLogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final logs = ref.watch(operationLogsProvider);
    return AsyncStateView(
      value: logs,
      onRetry: () => ref.invalidate(operationLogsProvider),
      loading: _logSkeleton(),
      isEmpty: (items) => items.isEmpty,
      empty: _emptyState(context),
      builder: (items) => ListView.builder(
        padding: EdgeInsets.all(context.pagePadding),
        itemCount: items.length,
        itemBuilder: (context, i) => OperationLogRow(
          item: items[i],
          onTap: () => _showOperationDetail(context, items[i], l10n),
        ),
      ),
    );
  }

  void _showOperationDetail(
    BuildContext context,
    OperationLogItem item,
    AppLocalizations l10n,
  ) {
    final tone = item.isSuccess
        ? context.appColors.success
        : context.appColors.danger;
    showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LogDetailHeader(
            title: item.title,
            statusLabel: item.isSuccess
                ? l10n.common_success
                : l10n.common_failed,
            tone: tone,
            time: formatLogTime(item.createdAt),
          ),
          LogDetailField(label: l10n.logs_method, value: item.method),
          LogDetailField(label: l10n.logs_path, value: item.path),
          LogDetailField(label: l10n.logs_source, value: item.source),
          LogDetailField(label: l10n.logs_status, value: item.status),
          if (item.message.trim().isNotEmpty)
            LogDetailField(label: l10n.logs_request, value: item.message),
          const SizedBox(height: AppTokens.s16),
          SecondaryButton(
            label: AppLocalizations.of(sheetContext).action_close,
            onPressed: () => Navigator.of(sheetContext).pop(),
          ),
        ],
      ),
    );
  }
}

class _LoginLogTab extends ConsumerWidget {
  const _LoginLogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final logs = ref.watch(loginLogsProvider);
    return AsyncStateView(
      value: logs,
      onRetry: () => ref.invalidate(loginLogsProvider),
      loading: _logSkeleton(),
      isEmpty: (items) => items.isEmpty,
      empty: _emptyState(context),
      builder: (items) => ListView.builder(
        padding: EdgeInsets.all(context.pagePadding),
        itemCount: items.length,
        itemBuilder: (context, i) => LoginLogRow(
          item: items[i],
          onTap: () => _showLoginDetail(context, items[i], l10n),
        ),
      ),
    );
  }

  void _showLoginDetail(
    BuildContext context,
    LoginLogItem item,
    AppLocalizations l10n,
  ) {
    final tone = item.isSuccess
        ? context.appColors.success
        : context.appColors.danger;
    showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LogDetailHeader(
            title: item.ip,
            statusLabel: item.isSuccess
                ? l10n.common_success
                : l10n.common_failed,
            tone: tone,
            time: formatLogTime(item.createdAt),
            icon: TablerIcons.login,
          ),
          LogDetailField(label: l10n.logs_ip, value: item.ip),
          if (item.hasLocation)
            LogDetailField(label: l10n.logs_address, value: item.address),
          if (item.hasDevice)
            LogDetailField(label: l10n.logs_device, value: item.deviceLabel),
          if (item.message.trim().isNotEmpty)
            LogDetailField(label: l10n.logs_request, value: item.message),
          const SizedBox(height: AppTokens.s16),
          SecondaryButton(
            label: AppLocalizations.of(sheetContext).action_close,
            onPressed: () => Navigator.of(sheetContext).pop(),
          ),
        ],
      ),
    );
  }
}

class _SshLogTab extends ConsumerWidget {
  const _SshLogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final logs = ref.watch(sshLogsProvider);
    return AsyncStateView(
      value: logs,
      onRetry: () => ref.invalidate(sshLogsProvider),
      loading: _logSkeleton(),
      isEmpty: (items) => items.isEmpty,
      empty: _emptyState(context),
      builder: (items) => ListView.builder(
        padding: EdgeInsets.all(context.pagePadding),
        itemCount: items.length,
        itemBuilder: (context, i) => SshLogRow(
          item: items[i],
          onTap: () => _showSshDetail(context, items[i], l10n),
        ),
      ),
    );
  }

  void _showSshDetail(
    BuildContext context,
    SshLogItem item,
    AppLocalizations l10n,
  ) {
    final tone = item.isSuccess
        ? context.appColors.success
        : context.appColors.danger;
    showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LogDetailHeader(
            title: item.title,
            statusLabel: item.isSuccess
                ? l10n.common_success
                : l10n.common_failed,
            tone: tone,
            time: formatLogTime(item.date),
            icon: TablerIcons.terminal_2,
          ),
          LogDetailField(label: l10n.logs_ip, value: item.address),
          if (item.hasArea)
            LogDetailField(label: l10n.logs_address, value: item.area),
          if (item.authMode.isNotEmpty)
            LogDetailField(label: l10n.logs_method, value: item.authMode),
          if (item.message.trim().isNotEmpty)
            LogDetailField(label: l10n.logs_request, value: item.message),
          const SizedBox(height: AppTokens.s16),
          SecondaryButton(
            label: AppLocalizations.of(sheetContext).action_close,
            onPressed: () => Navigator.of(sheetContext).pop(),
          ),
        ],
      ),
    );
  }
}

class _TaskLogTab extends ConsumerWidget {
  const _TaskLogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(taskLogsProvider);
    return AsyncStateView(
      value: logs,
      onRetry: () => ref.invalidate(taskLogsProvider),
      loading: _logSkeleton(),
      isEmpty: (items) => items.isEmpty,
      empty: _emptyState(context),
      builder: (items) => ListView.builder(
        padding: EdgeInsets.all(context.pagePadding),
        itemCount: items.length,
        itemBuilder: (context, i) => TaskLogRow(
          item: items[i],
          onTap: () => showTaskLogSheet(
            context,
            title: items[i].name,
            taskID: items[i].id,
            reader: (taskID) async {
              final repository = await ref.read(logRepositoryProvider.future);
              return repository.readTaskLog(taskID);
            },
            onFinished: () => ref.invalidate(taskLogsProvider),
          ),
        ),
      ),
    );
  }
}
