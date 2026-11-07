import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:re_editor/re_editor.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/runtime_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/sheet_title.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../../../common/formatters/value_labels.dart';

class RuntimeDetailPage extends ConsumerStatefulWidget {
  const RuntimeDetailPage({
    super.key,
    required this.serverId,
    required this.id,
    required this.type,
    required this.name,
    this.embedded = false,
  });

  final int serverId;
  final int id;
  final String type;
  final String name;
  final bool embedded;

  @override
  ConsumerState<RuntimeDetailPage> createState() => _RuntimeDetailPageState();
}

class _RuntimeDetailPageState extends ConsumerState<RuntimeDetailPage> {
  bool get _isPhp => widget.type.startsWith('php');
  bool get _isNode => widget.type == 'node';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = _isPhp
        ? [l10n.runtime_extensions, l10n.runtime_phpIni, l10n.runtime_fpm]
        : [l10n.runtime_modules];
    final children = _isPhp
        ? [
            _PhpExtensionsTab(id: widget.id),
            _PhpIniTab(id: widget.id),
            _FpmTab(id: widget.id),
          ]
        : [_NodeModulesTab(id: widget.id)];
    final body = _isPhp || _isNode
        ? SegmentedTabsView(
            scrollable: !widget.embedded,
            labels: labels,
            children: children,
          )
        : Center(
            child: Text(
              l10n.state_empty,
              style: AppTextStyles.bodyM.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          );
    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetTitle(
            title: widget.name,
            subtitle: '${widget.type} · #${widget.id}',
            onClose: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: AppTokens.s8),
          Expanded(child: body),
        ],
      );
    }
    return Scaffold(
      appBar: AppBarLarge(
        title: widget.name,
        subtitle: '${widget.type} · #${widget.id}',
      ),
      body: body,
    );
  }
}

class _PhpExtensionsTab extends ConsumerStatefulWidget {
  const _PhpExtensionsTab({required this.id});

  final int id;

  @override
  ConsumerState<_PhpExtensionsTab> createState() => _PhpExtensionsTabState();
}

class _PhpExtensionsTabState extends ConsumerState<_PhpExtensionsTab> {
  late Future<Map<String, dynamic>> _future;
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final repository = await ref.read(runtimeRepositoryProvider.future);
    return repository.getPhpExtensions(widget.id);
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(describeError(snapshot.error!, l10n)));
        }
        final data = snapshot.data ?? const {};
        final support = (data['supportExtensions'] as List?)
            ?.whereType<Map>()
            .toList(growable: false);
        if (support == null || support.isEmpty) {
          return EmptyState(
            icon: TablerIcons.puzzle,
            title: l10n.runtime_extensionsEmptyTitle,
            message: l10n.state_empty,
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s16,
                AppTokens.s12,
                AppTokens.s8,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.runtime_extensions,
                      style: AppTextStyles.titleM,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.runtime_extensionPresets,
                    onPressed: _showPresets,
                    icon: const Icon(TablerIcons.list),
                  ),
                  IconButton(
                    tooltip: l10n.action_refresh,
                    onPressed: _refresh,
                    icon: const Icon(TablerIcons.refresh),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(context.pagePadding),
                itemCount: support.length,
                itemBuilder: (context, index) {
                  final item = support[index];
                  final name = '${item['name'] ?? ''}';
                  final installed = item['installed'] == true;
                  final busy = _busy.contains(name);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.s8),
                    child: SplitListGroup(
                      children: [
                        SplitListTile(
                          leading: const Icon(TablerIcons.puzzle),
                          title: name,
                          subtitle:
                              '${item['description'] ?? ''}\n${installed ? l10n.runtime_installed : l10n.runtime_notInstalled}',
                          trailing: busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : TextButton(
                                  onPressed: () => _operate(name, installed),
                                  child: Text(
                                    installed
                                        ? l10n.runtime_uninstall
                                        : l10n.runtime_install,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPresets() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      final result = await repository.searchPhpExtensions();
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.85,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.runtime_extensionPresets, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            if (result.isEmpty)
              EmptyState(
                compact: true,
                icon: TablerIcons.puzzle,
                title: l10n.state_empty,
              )
            else
              SplitListGroup(
                children: [
                  for (final group in result)
                    SplitListTile(
                      leading: const Icon(TablerIcons.puzzle),
                      title: group.name,
                      subtitle: group.extensions,
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

  Future<void> _operate(String name, bool installed) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: installed ? l10n.runtime_uninstall : l10n.runtime_install,
      message: name,
      confirmLabel: installed ? l10n.runtime_uninstall : l10n.runtime_install,
      danger: installed,
    );
    if (!confirmed) return;
    setState(() => _busy.add(name));
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      if (installed) {
        await repository.uninstallPhpExtension(widget.id, name);
      } else {
        await repository.installPhpExtension(
          widget.id,
          name,
          '${DateTime.now().microsecondsSinceEpoch}',
        );
      }
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      _refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _busy.remove(name));
    }
  }
}

class _PhpIniTab extends ConsumerStatefulWidget {
  const _PhpIniTab({required this.id});

  final int id;

  @override
  ConsumerState<_PhpIniTab> createState() => _PhpIniTabState();
}

class _PhpIniTabState extends ConsumerState<_PhpIniTab> {
  CodeLineEditingController? _controller;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      final content = await repository.getPhpFile(widget.id, 'php.ini');
      if (!mounted) return;
      _controller = CodeLineEditingController.fromText(content);
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = describeError(error, AppLocalizations.of(context));
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final controller = _controller;
    if (controller == null) return;
    setState(() => _saving = true);
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      await repository.updatePhpFile(widget.id, 'php.ini', controller.text);
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.success(context, l10n.runtime_saved);
      final restart = await showConfirmSheet(
        context,
        title: l10n.runtime_phpIni,
        message: l10n.runtime_restartPhpHint,
        confirmLabel: l10n.containers_restart,
        danger: false,
      );
      if (restart) {
        await repository.operateRuntime(widget.id, 'restart');
        if (!mounted) return;
        AppToast.success(context, l10n.action_done);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTokens.s16),
          child: PrimaryButton(
            label: l10n.action_save,
            loading: _saving,
            onPressed: _save,
          ),
        ),
        Expanded(
          child: CodeEditor(
            controller: _controller!,
            style: CodeEditorStyle(
              fontSize: 14,
              fontFamilyFallback: const ['monospace'],
              textColor: context.scheme.onSurface,
              cursorColor: context.scheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _FpmData {
  const _FpmData({required this.config, required this.status});

  final Map<String, dynamic> config;
  final List<Map<String, dynamic>> status;
}

class _FpmTab extends ConsumerStatefulWidget {
  const _FpmTab({required this.id});

  final int id;

  @override
  ConsumerState<_FpmTab> createState() => _FpmTabState();
}

class _FpmTabState extends ConsumerState<_FpmTab> {
  late Future<_FpmData> _future;
  final _pm = TextEditingController();
  final _maxChildren = TextEditingController();
  final _startServers = TextEditingController();
  final _minSpare = TextEditingController();
  final _maxSpare = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _pm.dispose();
    _maxChildren.dispose();
    _startServers.dispose();
    _minSpare.dispose();
    _maxSpare.dispose();
    super.dispose();
  }

  Future<_FpmData> _load() async {
    final repository = await ref.read(runtimeRepositoryProvider.future);
    final results = await Future.wait([
      repository.getFpmConfig(widget.id),
      repository.getFpmStatus(widget.id),
    ]);
    final config = results[0] as Map<String, dynamic>;
    final params = (config['params'] as Map?)?.cast<String, dynamic>() ?? {};
    if (_pm.text.isEmpty) {
      _pm.text = '${params['pm'] ?? 'dynamic'}';
      _maxChildren.text = '${params['pm.max_children'] ?? '150'}';
      _startServers.text = '${params['pm.start_servers'] ?? '10'}';
      _minSpare.text = '${params['pm.min_spare_servers'] ?? '10'}';
      _maxSpare.text = '${params['pm.max_spare_servers'] ?? '30'}';
    }
    return _FpmData(
      config: config,
      status: results[1] as List<Map<String, dynamic>>,
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      await repository.updateFpmConfig(widget.id, {
        'pm': _pm.text.trim(),
        'pm.max_children': _maxChildren.text.trim(),
        'pm.start_servers': _startServers.text.trim(),
        'pm.min_spare_servers': _minSpare.text.trim(),
        'pm.max_spare_servers': _maxSpare.text.trim(),
      });
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.success(context, l10n.runtime_saved);
      setState(() => _future = _load());
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<_FpmData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(describeError(snapshot.error!, l10n)));
        }
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();
        return ListView(
          padding: EdgeInsets.all(context.pagePadding),
          children: [
            Text(l10n.runtime_fpmConfig, style: AppTextStyles.titleM),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: _pm, label: l10n.runtime_pm),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: _maxChildren,
              label: l10n.runtime_maxChildren,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: _startServers,
              label: l10n.runtime_startServers,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: _minSpare,
              label: l10n.runtime_minSpare,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: _maxSpare,
              label: l10n.runtime_maxSpare,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTokens.s16),
            PrimaryButton(
              label: l10n.action_save,
              loading: _saving,
              onPressed: _save,
            ),
            const SizedBox(height: AppTokens.s24),
            Text(l10n.runtime_fpm, style: AppTextStyles.titleM),
            const SizedBox(height: AppTokens.s12),
            if (data.status.isEmpty)
              Text(
                l10n.state_empty,
                style: AppTextStyles.bodyM.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
              )
            else
              SplitListGroup(
                children: [
                  for (final item in data.status)
                    SplitListTile(
                      title: displayValue(
                        context,
                        (item['name'] ?? item['pool'])?.toString(),
                      ),
                      subtitle: item.entries
                          .where((entry) => entry.key != 'name')
                          .map((entry) => '${entry.key}: ${entry.value}')
                          .join(' · '),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _NodeModulesTab extends ConsumerStatefulWidget {
  const _NodeModulesTab({required this.id});

  final int id;

  @override
  ConsumerState<_NodeModulesTab> createState() => _NodeModulesTabState();
}

class _NodeModulesTabState extends ConsumerState<_NodeModulesTab> {
  late Future<List<Map<String, dynamic>>> _future;
  final Set<String> _busy = {};
  String _packageManager = 'npm';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final repository = await ref.read(runtimeRepositoryProvider.future);
    return repository.getNodeModules(widget.id);
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _operate(String operate, String module) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy.add(module));
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      await repository.operateNodeModule(
        id: widget.id,
        operate: operate,
        module: module,
        packageManager: _packageManager,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      _refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _busy.remove(module));
    }
  }

  Future<void> _showScripts() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final dir = await pushFormPage<String>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.runtime_scripts,
          saveLabel: l10n.action_continue,
          onSave: () async =>
              Navigator.of(pageContext).pop(controller.text.trim()),
          children: [
            AppTextField(
              controller: controller,
              label: l10n.runtime_codeDir,
              hint: '/opt/1panel/apps/node/project',
              autofocus: true,
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (dir == null || dir.isEmpty || !mounted) return;
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      final scripts = await repository.getNodeScripts(dir);
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.85,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.runtime_scripts, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            if (scripts.isEmpty)
              EmptyState(
                compact: true,
                icon: TablerIcons.terminal_2,
                title: l10n.state_empty,
              )
            else
              SplitListGroup(
                children: [
                  for (final script in scripts)
                    SplitListTile(
                      leading: const Icon(TablerIcons.terminal_2),
                      title: script.name,
                      subtitle: script.script,
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

  Future<void> _install() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final module = await pushFormPage<String>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.runtime_install,
          saveLabel: l10n.runtime_install,
          onSave: () async =>
              Navigator.of(pageContext).pop(controller.text.trim()),
          children: [
            AppTextField(
              controller: controller,
              label: l10n.runtime_moduleHint,
              autofocus: true,
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (module == null || module.isEmpty) return;
    await _operate('install', module);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTokens.s16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _packageManager,
                  decoration: const InputDecoration(labelText: 'Package'),
                  items: const [
                    DropdownMenuItem(value: 'npm', child: Text('npm')),
                    DropdownMenuItem(value: 'yarn', child: Text('yarn')),
                    DropdownMenuItem(value: 'pnpm', child: Text('pnpm')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _packageManager = value);
                  },
                ),
              ),
              const SizedBox(width: AppTokens.s12),
              IconButton(
                tooltip: l10n.runtime_scripts,
                onPressed: _showScripts,
                icon: const Icon(TablerIcons.file_code),
              ),
              const SizedBox(width: AppTokens.s8),
              PrimaryButton(
                label: l10n.runtime_install,
                expanded: false,
                onPressed: _install,
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(describeError(snapshot.error!, l10n)),
                );
              }
              final items = snapshot.data ?? const [];
              if (items.isEmpty) {
                return EmptyState(
                  icon: TablerIcons.package,
                  title: l10n.runtime_modulesEmptyTitle,
                  message: l10n.state_empty,
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(context.pagePadding),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final name = '${item['name'] ?? ''}';
                  final busy = _busy.contains(name);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.s8),
                    child: SplitListGroup(
                      children: [
                        SplitListTile(
                          leading: const Icon(TablerIcons.package),
                          title: name,
                          subtitle: _joinNonEmpty([
                            '${item['version'] ?? ''}',
                            '${item['description'] ?? ''}',
                          ]),
                          trailing: busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(
                                  tooltip: l10n.action_more,
                                  icon: const Icon(TablerIcons.dots_vertical),
                                  onPressed: () async {
                                    final value =
                                        await showSelectionMenu<String>(
                                          context,
                                          options: [
                                            SelectionOption(
                                              label: l10n.runtime_update,
                                              value: 'update',
                                              icon: TablerIcons.refresh,
                                            ),
                                            SelectionOption(
                                              label: l10n.runtime_uninstall,
                                              value: 'uninstall',
                                              icon: TablerIcons.trash,
                                              danger: true,
                                            ),
                                          ],
                                        );
                                    if (value == null) return;
                                    await _operate(value, name);
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

String _joinNonEmpty(List<String> values) {
  return values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(' · ');
}

/// Opens one runtime configuration tab as a sheet above the action sheet.
Future<void> showRuntimeTabSheet(
  BuildContext context, {
  required int serverId,
  required int id,
  required String type,
  required String name,
  required int tab,
}) {
  return showAppSheet<void>(
    context: context,
    builder: (_) => _RuntimeTabSheet(
      serverId: serverId,
      id: id,
      type: type,
      name: name,
      tab: tab,
    ),
  );
}

class _RuntimeTabSheet extends StatelessWidget {
  const _RuntimeTabSheet({
    required this.serverId,
    required this.id,
    required this.type,
    required this.name,
    required this.tab,
  });

  final int serverId;
  final int id;
  final String type;
  final String name;
  final int tab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (tab) {
      0 =>
        type.startsWith('php') ? l10n.runtime_extensions : l10n.runtime_modules,
      1 => l10n.runtime_phpIni,
      2 => l10n.runtime_fpm,
      _ => l10n.runtime_modules,
    };
    final child = switch (tab) {
      0 =>
        type.startsWith('php')
            ? _PhpExtensionsTab(id: id)
            : _NodeModulesTab(id: id),
      1 => _PhpIniTab(id: id),
      2 => _FpmTab(id: id),
      _ => _NodeModulesTab(id: id),
    };
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.titleM,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      label,
                      style: AppTextStyles.bodyS.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.action_close,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(TablerIcons.x),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Expanded(child: child),
        ],
      ),
    );
  }
}

Future<void> showRuntimeDetailSheet(
  BuildContext context, {
  required int serverId,
  required int id,
  required String type,
  required String name,
}) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.94,
    builder: (sheetContext) => SizedBox(
      height: MediaQuery.sizeOf(sheetContext).height * 0.80,
      child: RuntimeDetailPage(
        serverId: serverId,
        id: id,
        type: type,
        name: name,
        embedded: true,
      ),
    ),
  );
}
