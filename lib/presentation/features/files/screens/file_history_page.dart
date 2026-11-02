import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/common/page_result.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

class FileHistoryPage extends ConsumerStatefulWidget {
  const FileHistoryPage({
    super.key,
    required this.serverId,
    required this.path,
  });

  final int serverId;
  final String path;

  @override
  ConsumerState<FileHistoryPage> createState() => _FileHistoryPageState();
}

class _FileHistoryPageState extends ConsumerState<FileHistoryPage> {
  late Future<PageResult<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<PageResult<Map<String, dynamic>>> _load() async {
    final repository = await ref.read(fileRepositoryProvider.future);
    return repository.searchHistory(path: widget.path);
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.files_history,
        subtitle: widget.path,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<PageResult<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                describeError(snapshot.error!, l10n),
                textAlign: TextAlign.center,
              ),
            );
          }
          final items = snapshot.data?.items ?? const [];
          if (items.isEmpty) {
            return EmptyState(
              icon: TablerIcons.history,
              title: l10n.files_historyEmptyTitle,
              message: l10n.files_historyEmpty,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppTokens.s16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final id = (item['id'] as num?)?.toInt() ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.s8),
                child: SplitListGroup(
                  children: [
                    SplitListTile(
                      leading: const Icon(TablerIcons.history),
                      title:
                          '${item['fileName'] ?? item['path'] ?? widget.path}',
                      subtitle:
                          '${item['operation'] ?? ''} · '
                          '${formatLocalDateTime('${item['createdAt'] ?? ''}', locale: AppLocalizations.of(context).localeName)}',
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(TablerIcons.dots_vertical),
                        onSelected: (value) {
                          if (value == 'view') _view(id);
                          if (value == 'restore') _restore(id);
                          if (value == 'delete') _delete(id);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: Text(l10n.files_history),
                          ),
                          PopupMenuItem(
                            value: 'restore',
                            child: Text(l10n.files_historyRestore),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(l10n.files_historyDelete),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _view(int id) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final data = await repository.getHistoryContent(id);
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.files_history, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            Flexible(
              child: SingleChildScrollView(
                child: SelectableText(
                  '${data['content'] ?? ''}',
                  style: AppTextStyles.bodyS.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _restore(int id) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.files_historyRestore,
      message: l10n.files_historyRestoreConfirm,
      confirmLabel: l10n.files_historyRestore,
    );
    if (!confirmed) return;
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      await repository.restoreHistory(id);
      if (!mounted) return;
      AppToast.success(context, l10n.files_historyRestored);
      _refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(int id) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.files_historyDelete,
      message: l10n.files_historyDelete,
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed) return;
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      await repository.deleteHistory([id]);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      _refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }
}
