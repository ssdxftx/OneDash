import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/log/login_log_dto.dart';
import '../../../../data/dto/log/operation_log_dto.dart';
import '../../../../data/dto/log/ssh_log_dto.dart';
import '../../../../data/dto/log/task_log_dto.dart';
import '../../../../data/repositories_impl/log_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/error_toast.dart';
import '../../../common/states/empty_state.dart';

class _LogEntry {
  const _LogEntry({
    required this.time,
    required this.status,
    required this.title,
    required this.detail,
  });

  final String time;
  final String status;
  final String title;
  final String detail;
}

final _logsProvider = FutureProvider.autoDispose.family<List<_LogEntry>, int>((
  ref,
  index,
) async {
  final repository = await ref.watch(logRepositoryProvider.future);
  switch (index) {
    case 0:
      final page = await repository.searchOperationLogs(
        page: 1,
        pageSize: 50,
        source: '',
        status: '',
        node: '',
        operation: '',
      );
      return page.items
          .map(
            (OperationLogDto e) => _LogEntry(
              time: _format(e.createdAt),
              status: e.status,
              title: '${e.method} ${e.path}',
              detail: e.message.isEmpty ? e.source : e.message,
            ),
          )
          .toList();
    case 1:
      final page = await repository.searchLoginLogs(
        page: 1,
        pageSize: 50,
        ip: '',
        status: '',
      );
      return page.items
          .map(
            (LoginLogDto e) => _LogEntry(
              time: _format(e.createdAt),
              status: e.status,
              title: e.ip,
              detail: e.message.isEmpty ? e.agent : e.message,
            ),
          )
          .toList();
    case 2:
      final page = await repository.searchSshLogs(
        page: 1,
        pageSize: 50,
        info: '',
        status: '',
      );
      return page.items
          .map(
            (SshLogDto e) => _LogEntry(
              time: e.dateStr.isEmpty ? _format(e.date) : e.dateStr,
              status: e.status,
              title: '${e.user}@${e.address}',
              detail: e.message,
            ),
          )
          .toList();
    default:
      final page = await repository.searchTaskLogs(
        page: 1,
        pageSize: 50,
        status: '',
        type: '',
        taskID: '',
      );
      return page.items
          .map(
            (TaskLogDto e) => _LogEntry(
              time: _format(e.createdAt),
              status: e.status,
              title: e.name,
              detail: e.errorMsg.isEmpty ? e.operate : e.errorMsg,
            ),
          )
          .toList();
  }
}, name: 'logsProvider');

String _format(DateTime time) {
  final local = time.toLocal();
  return '${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} '
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

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
            icon: TablerIcons.eraser,
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
          _LogTab(index: 0),
          _LogTab(index: 1),
          _LogTab(index: 2),
          _LogTab(index: 3),
        ],
      ),
    );
  }
}

extension on LogHubPage {
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
      ref.invalidate(_logsProvider(0));
      ref.invalidate(_logsProvider(1));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _LogTab extends ConsumerWidget {
  const _LogTab({required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final logs = ref.watch(_logsProvider(index));
    return AsyncStateView(
      value: logs,
      onRetry: () => ref.invalidate(_logsProvider(index)),
      loading: const SkeletonList(itemCount: 8, itemHeight: 56),
      isEmpty: (items) => items.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.file_text,
        title: l10n.state_empty,
        message: l10n.logs_title,
      ),
      builder: (items) => ListView.builder(
        padding: const EdgeInsets.all(AppTokens.s16),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.s8),
            child: SplitListGroup(
              children: [
                SplitListTile(
                  leading: StatusDot(status: item.status.toLowerCase()),
                  title: item.title,
                  subtitle: '${item.time}  ${item.detail}',
                  onTap: () => showAppSheet<void>(
                    context: context,
                    builder: (sheetContext) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: AppTextStyles.titleL),
                        const SizedBox(height: AppTokens.s4),
                        Text(
                          '${item.time} · ${item.status}',
                          style: AppTextStyles.bodyS.copyWith(
                            color: sheetContext.scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppTokens.s16),
                        SelectableText(
                          item.detail,
                          style: AppTextStyles.bodyM.copyWith(
                            fontFamily: 'monospace',
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppTokens.s16),
                        SecondaryButton(
                          label: AppLocalizations.of(sheetContext).action_close,
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
