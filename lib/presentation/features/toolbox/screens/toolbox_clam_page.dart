import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/repositories_impl/toolbox_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/sheet_title.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../../../common/formatters/value_labels.dart';

class ToolboxClamPage extends ConsumerStatefulWidget {
  const ToolboxClamPage({super.key});

  @override
  ConsumerState<ToolboxClamPage> createState() => _ToolboxClamPageState();
}

class _ToolboxClamPageState extends ConsumerState<ToolboxClamPage> {
  Map<String, dynamic> _base = const {};
  List<Map<String, dynamic>> _tasks = const [];
  bool _loading = true;
  bool _failed = false;
  bool _refreshing = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (_refreshing) return;
    _refreshing = true;
    if (!silent) {
      setState(() {
        _loading = true;
        _failed = false;
      });
    }
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      final base = await repository.getClamBase();
      var tasks = const <Map<String, dynamic>>[];
      if (base['isExist'] == true) {
        tasks = await repository.searchClam();
      }
      if (!mounted) return;
      setState(() {
        _base = base;
        _tasks = tasks;
        _failed = false;
      });
    } catch (error) {
      if (!mounted) return;
      if (!silent) setState(() => _failed = true);
      showErrorToast(context, error);
    } finally {
      _refreshing = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(bool enabled) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.operateClam(enabled ? 'start' : 'stop');
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editRule([Map<String, dynamic>? task]) async {
    final l10n = AppLocalizations.of(context);
    final editing = task != null;
    final name = TextEditingController(
      text: '${task?['name'] ?? 'scan-${DateTime.now().minute}'}',
    );
    final path = TextEditingController(text: '${task?['path'] ?? '/tmp'}');
    final infectedDir = TextEditingController(
      text: '${task?['infectedDir'] ?? ''}',
    );
    var strategy = '${task?['infectedStrategy'] ?? 'none'}';
    if (!const {'none', 'remove', 'move', 'copy'}.contains(strategy)) {
      strategy = 'none';
    }
    final confirmed = await pushFormPage<bool>(
      context,
      StatefulBuilder(
        builder: (pageContext, setSheetState) => SimpleFormPage(
          title: editing ? l10n.action_edit : l10n.toolbox_clam,
          saveLabel: editing ? l10n.action_save : l10n.action_create,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(
              controller: name,
              label: l10n.toolbox_scanName,
              autofocus: true,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: path, label: l10n.toolbox_scanPath),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: strategy,
              decoration: InputDecoration(
                labelText: l10n.toolbox_infectedStrategy,
              ),
              items: [
                DropdownMenuItem(
                  value: 'none',
                  child: Text(l10n.toolbox_infectedNone),
                ),
                DropdownMenuItem(
                  value: 'remove',
                  child: Text(l10n.toolbox_infectedRemove),
                ),
                DropdownMenuItem(
                  value: 'move',
                  child: Text(l10n.toolbox_infectedMove),
                ),
                DropdownMenuItem(
                  value: 'copy',
                  child: Text(l10n.toolbox_infectedCopy),
                ),
              ],
              onChanged: (value) {
                if (value != null) setSheetState(() => strategy = value);
              },
            ),
            if (strategy == 'move' || strategy == 'copy') ...[
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: infectedDir,
                label: l10n.toolbox_infectedDir,
              ),
            ],
          ],
        ),
      ),
    );

    final taskName = name.text.trim();
    final scanPath = path.text.trim();
    final targetDir = infectedDir.text.trim();
    name.dispose();
    path.dispose();
    infectedDir.dispose();
    if (confirmed != true || taskName.isEmpty || scanPath.isEmpty) return;
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      if (editing) {
        await repository.updateClam({
          'id': (task['id'] as num?)?.toInt() ?? 0,
          'name': taskName,
          'path': scanPath,
          'infectedStrategy': strategy,
          'infectedDir': targetDir,
          'spec': '${task['spec'] ?? ''}',
          'specObj': task['specObj'],
          'hasSpec': task['hasSpec'],
          'timeout': (task['timeout'] as num?)?.toInt() ?? 3600,
          'description': '${task['description'] ?? ''}',
          'alertCount': (task['alertCount'] as num?)?.toInt() ?? 0,
          'alertMethod': '${task['alertMethod'] ?? ''}',
          'alertTitle': '${task['alertTitle'] ?? ''}',
        });
      } else {
        await repository.createClam(
          name: taskName,
          path: scanPath,
          infectedStrategy: strategy,
          infectedDir: targetDir,
        );
      }
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _start(Map<String, dynamic> task) async {
    final l10n = AppLocalizations.of(context);
    final id = (task['id'] as num?)?.toInt() ?? 0;
    if (id == 0) return;
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.handleClam(id);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
      _startPolling();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    var ticks = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      ticks++;
      if (!mounted || ticks > 24) {
        timer.cancel();
        return;
      }
      unawaited(_load(silent: true));
    });
  }

  Future<void> _updateDatabase() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.operateClam('fresh-start');
      if (!mounted) return;
      AppToast.success(context, l10n.toolbox_updateVirusDatabase);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _taskActions(Map<String, dynamic> task) async {
    final l10n = AppLocalizations.of(context);
    final action = await showSelectionMenu<String>(
      context,
      title: displayValue(context, task['name']?.toString()),
      options: [
        SelectionOption(
          label: l10n.toolbox_startScan,
          value: 'start',
          icon: TablerIcons.player_play,
        ),
        SelectionOption(
          label: l10n.action_edit,
          value: 'edit',
          icon: TablerIcons.pencil,
        ),
        SelectionOption(
          label: '${task['status'] ?? ''}'.toLowerCase() == 'enable'
              ? l10n.toolbox_disableScan
              : l10n.toolbox_enableScan,
          value: 'status',
          icon: TablerIcons.power,
        ),
        SelectionOption(
          label: l10n.toolbox_clamConfigFile,
          value: 'config',
          icon: TablerIcons.file_code,
        ),
        SelectionOption(
          label: l10n.toolbox_clamRecords,
          value: 'records',
          icon: TablerIcons.list,
        ),
        SelectionOption(
          label: l10n.action_delete,
          value: 'delete',
          icon: TablerIcons.trash,
          danger: true,
        ),
      ],
    );
    if (action == null || !mounted) return;
    switch (action) {
      case 'start':
        await _start(task);
      case 'edit':
        await _editRule(task);
      case 'status':
        await _toggleStatus(task);
      case 'config':
        await _showConfig(task);
      case 'records':
        await _showRecords(task);
      case 'delete':
        await _deleteTask(task);
    }
  }

  Future<void> _deleteTask(Map<String, dynamic> task) async {
    final l10n = AppLocalizations.of(context);
    final id = (task['id'] as num?)?.toInt() ?? 0;
    if (id == 0) return;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: displayValue(context, task['name']?.toString()),
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.deleteClam(ids: [id]);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _toggleStatus(Map<String, dynamic> task) async {
    final l10n = AppLocalizations.of(context);
    final id = (task['id'] as num?)?.toInt() ?? 0;
    final current = '${task['status'] ?? ''}'.toLowerCase();
    final next = current == 'enable' ? 'Disable' : 'Enable';
    if (id == 0) return;
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.updateClamStatus(id, next);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showConfig(Map<String, dynamic> task) async {
    final l10n = AppLocalizations.of(context);
    final name = '${task['name'] ?? ''}';
    if (name.isEmpty) return;
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      final content = await repository.loadClamFile(name);
      if (!mounted) return;
      final edit = await showAppSheet<bool>(
        context: context,
        maxHeightFactor: 0.9,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetTitle(
              title: l10n.toolbox_clamConfigFile,
              onClose: () => Navigator.of(sheetContext).pop(false),
              actions: [
                IconButton(
                  tooltip: l10n.action_edit,
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  icon: const Icon(TablerIcons.pencil),
                ),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                child: SelectableText(
                  content,
                  style: AppTextStyles.bodyS.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
      );
      if (edit != true || !mounted) return;
      final controller = TextEditingController(text: content);
      final confirmed = await pushFormPage<bool>(
        context,
        SimpleFormPage(
          title: l10n.toolbox_clamConfigFile,
          onSave: () async =>
              Navigator.of(context, rootNavigator: true).pop(true),
          children: [
            AppTextField(
              controller: controller,
              label: l10n.toolbox_clamConfigFile,
              maxLines: 20,
            ),
          ],
        ),
      );
      final newContent = controller.text;
      controller.dispose();
      if (confirmed != true) return;
      await repository.updateClamFile(name: name, file: newContent);
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showRecords(Map<String, dynamic> task) async {
    final l10n = AppLocalizations.of(context);
    final id = (task['id'] as num?)?.toInt() ?? 0;
    if (id == 0) return;
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      final records = await repository.searchClamRecords(clamId: id);
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.toolbox_clamRecords, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            if (records.isEmpty)
              EmptyState(
                compact: true,
                icon: TablerIcons.shield_off,
                title: l10n.toolbox_clamNoRecords,
              )
            else
              SplitListGroup(
                children: [
                  for (final record in records)
                    SplitListTile(
                      title: formatListTime(
                        DateTime.tryParse(
                          '${record['scanDate'] ?? record['startTime'] ?? ''}',
                        ),
                        l10n,
                        fallback:
                            '${record['scanDate'] ?? record['startTime'] ?? ''}',
                      ),
                      subtitle:
                          '${record['status'] ?? ''} · ${record['infectedFiles'] ?? '0'}',
                      trailing: record['id'] == null
                          ? null
                          : IconButton(
                              tooltip: l10n.action_clear,
                              icon: const Icon(TablerIcons.eraser),
                              onPressed: () async {
                                await repository.cleanClamRecords(
                                  (record['id'] as num).toInt(),
                                );
                                if (!sheetContext.mounted) return;
                                AppToast.success(
                                  sheetContext,
                                  l10n.action_done,
                                );
                                Navigator.of(sheetContext).pop();
                              },
                            ),
                    ),
                ],
              ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = _base['isActive'] == true;
    final scanning = _tasks.any((task) {
      final status = '${task['status'] ?? ''}'.toLowerCase();
      return status == 'running' || status == 'scanning' || status == 'pending';
    });
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.toolbox_clam,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _load,
          ),
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.toolbox_clamAdd,
            onPressed: _base['isExist'] == true ? _editRule : null,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _failed
          ? EmptyState(
              icon: TablerIcons.alert_triangle,
              title: l10n.toolbox_loadFailed,
              actionLabel: l10n.action_retry,
              onAction: _load,
            )
          : ListView(
              padding: EdgeInsets.all(context.pagePadding),
              children: [
                SplitListGroup(
                  children: [
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.s16,
                      ),
                      title: const Text('ClamAV'),
                      subtitle: Text(
                        active ? l10n.toolbox_running : l10n.toolbox_stopped,
                      ),
                      value: active,
                      onChanged: _base['isExist'] == true ? _toggle : null,
                    ),
                    SplitListTile(
                      title: l10n.toolbox_version,
                      subtitle: displayValue(
                        context,
                        _base['version']?.toString(),
                      ),
                    ),
                    SplitListTile(
                      title: l10n.toolbox_virusDatabase,
                      subtitle: displayValue(
                        context,
                        _base['freshVersion']?.toString(),
                      ),
                    ),
                    SplitListTile(
                      leading: const Icon(TablerIcons.refresh),
                      title: l10n.toolbox_updateVirusDatabase,
                      subtitle: l10n.toolbox_updateVirusDatabaseHint,
                      trailing: const Icon(TablerIcons.chevron_right),
                      onTap: _base['freshIsExist'] == true
                          ? _updateDatabase
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s24),
                SectionHeader(title: l10n.toolbox_scanRecords),
                if (scanning)
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppTokens.s12),
                    child: LinearProgressIndicator(),
                  ),
                if (_tasks.isEmpty)
                  EmptyState(
                    icon: TablerIcons.virus,
                    title: l10n.toolbox_clamScanEmptyTitle,
                    message: l10n.toolbox_noScans,
                    compact: true,
                  )
                else
                  SplitListGroup(
                    children: [
                      for (final task in _tasks)
                        SplitListTile(
                          leading: const Icon(TablerIcons.scan),
                          title: displayValue(
                            context,
                            task['name']?.toString(),
                          ),
                          subtitle: [
                            displayValue(context, task['path']?.toString()),
                            if ((task['status']?.toString() ?? '').isNotEmpty)
                              task['status'].toString(),
                          ].join(' · '),
                          trailing: IconButton(
                            tooltip: l10n.action_more,
                            icon: const Icon(TablerIcons.dots),
                            onPressed: () => _taskActions(task),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
    );
  }
}
