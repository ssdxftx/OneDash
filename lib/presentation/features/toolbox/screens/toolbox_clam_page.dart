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
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

class ToolboxClamPage extends ConsumerStatefulWidget {
  const ToolboxClamPage({super.key});

  @override
  ConsumerState<ToolboxClamPage> createState() => _ToolboxClamPageState();
}

class _ToolboxClamPageState extends ConsumerState<ToolboxClamPage> {
  Map<String, dynamic> _base = const {};
  List<Map<String, dynamic>> _tasks = const [];
  bool _loading = true;
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

  Future<void> _load() async {
    setState(() => _loading = true);
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
      });
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
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

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController(text: 'scan-${DateTime.now().minute}');
    final path = TextEditingController(text: '/tmp');
    final infectedDir = TextEditingController();
    var strategy = 'none';
    final confirmed = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.toolbox_clam, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
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
            const SizedBox(height: AppTokens.s24),
            PrimaryButton(
              label: l10n.action_create,
              onPressed: () {
                if ((strategy == 'move' || strategy == 'copy') &&
                    infectedDir.text.trim().isEmpty) {
                  AppToast.warning(context, l10n.toolbox_infectedDirRequired);
                  return;
                }
                Navigator.of(sheetContext).pop(true);
              },
            ),
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
      await repository.createClam(
        name: taskName,
        path: scanPath,
        infectedStrategy: strategy,
        infectedDir: targetDir,
      );
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
      unawaited(_load());
    });
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
            tooltip: l10n.toolbox_scanRecords,
            onPressed: _base['isExist'] == true ? _create : null,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.pagePadding),
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
                subtitle: '${_base['version'] ?? '-'}',
              ),
              SplitListTile(
                title: l10n.toolbox_virusDatabase,
                subtitle: '${_base['freshVersion'] ?? '-'}',
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
                    title: '${task['name'] ?? ''}',
                    subtitle: '${task['path'] ?? ''} · ${task['status'] ?? ''}',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => _showRecords(task),
                          child: Text(l10n.toolbox_clamRecords),
                        ),
                        IconButton(
                          tooltip: l10n.toolbox_startScan,
                          onPressed: () => _start(task),
                          icon: const Icon(TablerIcons.player_play),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
