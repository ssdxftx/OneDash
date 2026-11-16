import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/log/system_log_dto.dart';
import '../../../../data/repositories_impl/log_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

class SystemLogPage extends ConsumerStatefulWidget {
  const SystemLogPage({super.key});

  @override
  ConsumerState<SystemLogPage> createState() => _SystemLogPageState();
}

class _SystemLogPageState extends ConsumerState<SystemLogPage> {
  final _keyword = TextEditingController();
  final _items = <SystemLogItemDto>[];
  List<String> _services = const [];
  SystemLogStatusDto? _status;
  String _service = '';
  String _priority = '';
  String _cursor = '';
  bool _hasMore = false;
  bool _loading = true;
  bool _loadingMore = false;
  bool _failed = false;
  int _requestId = 0;

  static const _priorities = [
    'emerg',
    'alert',
    'crit',
    'err',
    'warning',
    'notice',
    'info',
    'debug',
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _keyword.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    try {
      final repository = await ref.read(logRepositoryProvider.future);
      final results = await Future.wait([
        repository.getSystemLogServices(),
        repository.getSystemLogStatus(),
      ]);
      if (!mounted) return;
      setState(() {
        _services = results[0] as List<String>;
        _status = results[1] as SystemLogStatusDto;
      });
      await _reload();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reload() async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _failed = false;
      _cursor = '';
      _hasMore = false;
    });
    try {
      final repository = await ref.read(logRepositoryProvider.future);
      final page = await repository.readSystemLog(
        keyword: _keyword.text.trim(),
        service: _service,
        priority: _priority,
        pageSize: 50,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _items
          ..clear()
          ..addAll(page.items);
        _cursor = page.nextCursor;
        _hasMore = page.hasMore && page.nextCursor.isNotEmpty;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() => _failed = true);
      showErrorToast(context, error);
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _cursor.isEmpty) return;
    final requestId = _requestId;
    setState(() => _loadingMore = true);
    try {
      final repository = await ref.read(logRepositoryProvider.future);
      final page = await repository.readSystemLog(
        keyword: _keyword.text.trim(),
        service: _service,
        priority: _priority,
        cursor: _cursor,
        pageSize: 50,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _items.addAll(page.items);
        _cursor = page.nextCursor;
        _hasMore = page.hasMore && page.nextCursor.isNotEmpty;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      showErrorToast(context, error);
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() => _loadingMore = false);
      }
    }
  }

  Future<void> _pickService() async {
    final l10n = AppLocalizations.of(context);
    final selected = await showSelectionMenu<String>(
      context,
      title: l10n.logs_service,
      options: [
        SelectionOption(
          label: l10n.logs_serviceAll,
          value: '',
          icon: TablerIcons.list,
        ),
        for (final service in _services)
          SelectionOption(
            label: service,
            value: service,
            icon: TablerIcons.settings,
          ),
      ],
    );
    if (selected == null || !mounted) return;
    setState(() => _service = selected);
    await _reload();
  }

  Future<void> _pickPriority() async {
    final l10n = AppLocalizations.of(context);
    final selected = await showSelectionMenu<String>(
      context,
      title: l10n.logs_priority,
      options: [
        SelectionOption(
          label: l10n.logs_priorityAll,
          value: '',
          icon: TablerIcons.list,
        ),
        for (final priority in _priorities)
          SelectionOption(
            label: priority,
            value: priority,
            icon: TablerIcons.alert_circle,
          ),
      ],
    );
    if (selected == null || !mounted) return;
    setState(() => _priority = selected);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = _status;
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.logs_systemServices,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _reload,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            context.pagePadding,
            0,
            context.pagePadding,
            AppTokens.s32,
          ),
          children: [
            if (status != null && status.message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.s8),
                child: Text(
                  status.message,
                  style: AppTextStyles.bodyS.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ),
            AppTextField(
              controller: _keyword,
              label: l10n.logs_keyword,
              hint: l10n.logs_searchHint,
              textInputAction: TextInputAction.search,
              enabled: status?.keywordFilterSupported != false,
              onSubmitted: (_) => _reload(),
            ),
            const SizedBox(height: AppTokens.s8),
            SplitListGroup(
              children: [
                SplitListTile(
                  leading: const Icon(TablerIcons.settings),
                  title: l10n.logs_service,
                  subtitle: _service.isEmpty ? l10n.logs_serviceAll : _service,
                  trailing: const Icon(TablerIcons.chevron_right),
                  onTap: _pickService,
                ),
                SplitListTile(
                  leading: const Icon(TablerIcons.alert_circle),
                  title: l10n.logs_priority,
                  subtitle: _priority.isEmpty
                      ? l10n.logs_priorityAll
                      : _priority,
                  trailing: const Icon(TablerIcons.chevron_right),
                  onTap: _pickPriority,
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(AppTokens.s32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_items.isEmpty)
              EmptyState(
                icon: _failed
                    ? TablerIcons.alert_triangle
                    : TablerIcons.file_text,
                title: _failed
                    ? l10n.logs_loadFailed
                    : l10n.logs_systemServices,
                message: _failed ? null : l10n.logs_noSystemLog,
                actionLabel: _failed ? l10n.action_retry : null,
                onAction: _failed ? _reload : null,
              )
            else ...[
              for (final item in _items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.s8),
                  child: TonalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.service.isEmpty
                                    ? l10n.logs_system
                                    : item.service,
                                style: AppTextStyles.titleS,
                              ),
                            ),
                            if (item.priority.isNotEmpty)
                              Text(
                                item.priority,
                                style: AppTextStyles.caption.copyWith(
                                  color: context.scheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppTokens.s4),
                        SelectableText(
                          item.message.isEmpty ? item.raw : item.message,
                          style: AppTextStyles.bodyS,
                        ),
                        if (item.time.isNotEmpty) ...[
                          const SizedBox(height: AppTokens.s4),
                          Text(
                            item.time,
                            style: AppTextStyles.caption.copyWith(
                              color: context.scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              if (_hasMore)
                TextButton(
                  onPressed: _loadingMore ? null : _loadMore,
                  child: _loadingMore
                      ? const SizedBox(
                          width: AppTokens.s16,
                          height: AppTokens.s16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.logs_loadMore),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
