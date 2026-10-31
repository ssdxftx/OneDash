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
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/states/async_state_view.dart';
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
      appBar: AppBarLarge(title: l10n.logs_title),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
