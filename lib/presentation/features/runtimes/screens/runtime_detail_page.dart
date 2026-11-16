import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:re_editor/re_editor.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/api/runtime_api.dart';
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
import '../../../common/components/tonal_card.dart';
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
        ? [
            l10n.runtime_extensions,
            l10n.runtime_phpIni,
            l10n.runtime_fpm,
            l10n.runtime_phpConfig,
            l10n.runtime_container,
            l10n.runtime_supervisor,
          ]
        : [l10n.runtime_modules];
    final children = _isPhp
        ? [
            _PhpExtensionsTab(id: widget.id),
            _PhpIniTab(id: widget.id),
            _FpmTab(id: widget.id),
            _PhpConfigTab(id: widget.id),
            _PhpContainerTab(id: widget.id),
            _PhpSupervisorTab(id: widget.id),
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
        actions: [
          AppIconButton(
            icon: TablerIcons.note,
            tooltip: l10n.runtime_remark,
            onPressed: _editRemark,
          ),
        ],
      ),
      body: body,
    );
  }

  Future<void> _editRemark() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.runtime_remark,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(controller: controller, label: l10n.runtime_remark),
          ],
        ),
      ),
    );
    final value = controller.text.trim();
    controller.dispose();
    if (saved != true || !mounted) return;
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      await repository.updateRuntimeRemark(widget.id, value);
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
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
    await showAppSheet<void>(
      context: context,
      maxHeightFactor: 0.9,
      builder: (_) => _PhpPresetSheet(runtimeId: widget.id),
    );
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
      final content = await repository.getPhpFile(widget.id, 'php');
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
      await repository.updatePhpFile(widget.id, 'php', controller.text);
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

class _PhpConfigTab extends ConsumerStatefulWidget {
  const _PhpConfigTab({required this.id});

  final int id;

  @override
  ConsumerState<_PhpConfigTab> createState() => _PhpConfigTabState();
}

class _PhpConfigTabState extends ConsumerState<_PhpConfigTab> {
  final _params = TextEditingController();
  final _disabled = TextEditingController();
  final _upload = TextEditingController();
  final _execution = TextEditingController();
  bool _loading = true;
  bool _failed = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _params.dispose();
    _disabled.dispose();
    _upload.dispose();
    _execution.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      final data = await repository.getPhpConfig(widget.id);
      if (!mounted) return;
      final params = data['params'];
      _params.text = params is Map
          ? const JsonEncoder.withIndent('  ').convert(params)
          : '{}';
      final disabled = (data['disableFunctions'] as List?) ?? const [];
      _disabled.text = disabled.join(',');
      _upload.text = '${data['uploadMaxSize'] ?? ''}';
      _execution.text = '${data['maxExecutionTime'] ?? ''}';
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
      showErrorToast(context, error);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    Map<String, String> params;
    try {
      final decoded = _params.text.trim().isEmpty
          ? <String, String>{}
          : jsonDecode(_params.text);
      if (decoded is! Map) throw const FormatException();
      params = decoded.map((key, value) => MapEntry('$key', '$value'));
    } catch (_) {
      AppToast.error(context, l10n.runtime_jsonHint);
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      if (params.isNotEmpty) {
        await repository.updatePhpConfig(
          id: widget.id,
          scope: 'params',
          params: params,
        );
      }
      await repository.updatePhpConfig(
        id: widget.id,
        scope: 'disable_functions',
        disableFunctions: _disabled.text
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false),
      );
      if (_upload.text.trim().isNotEmpty) {
        await repository.updatePhpConfig(
          id: widget.id,
          scope: 'upload_max_filesize',
          uploadMaxSize: _upload.text.trim(),
        );
      }
      if (_execution.text.trim().isNotEmpty) {
        await repository.updatePhpConfig(
          id: widget.id,
          scope: 'max_execution_time',
          maxExecutionTime: _execution.text.trim(),
        );
      }
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_failed) {
      return EmptyState(
        icon: TablerIcons.alert_triangle,
        title: l10n.common_notAvailable,
        actionLabel: l10n.action_retry,
        onAction: _load,
      );
    }
    return ListView(
      padding: EdgeInsets.all(context.pagePadding),
      children: [
        AppTextField(
          controller: _params,
          label: l10n.runtime_phpParams,
          maxLines: 10,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _disabled,
          label: l10n.runtime_disableFunctions,
          hint: 'exec,passthru',
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _upload,
          label: l10n.runtime_uploadMaxSize,
          hint: '50M',
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _execution,
          label: l10n.runtime_maxExecutionTime,
          hint: '300',
        ),
        const SizedBox(height: AppTokens.s16),
        PrimaryButton(
          label: l10n.action_save,
          loading: _saving,
          onPressed: _save,
        ),
      ],
    );
  }
}

class _PhpContainerTab extends ConsumerStatefulWidget {
  const _PhpContainerTab({required this.id});

  final int id;

  @override
  ConsumerState<_PhpContainerTab> createState() => _PhpContainerTabState();
}

class _PhpContainerTabState extends ConsumerState<_PhpContainerTab> {
  final _name = TextEditingController();
  final _ports = TextEditingController();
  final _environments = TextEditingController();
  final _volumes = TextEditingController();
  final _hosts = TextEditingController();
  bool _loading = true;
  bool _failed = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _ports.dispose();
    _environments.dispose();
    _volumes.dispose();
    _hosts.dispose();
    super.dispose();
  }

  String _json(Object? value, [List<Object> fallback = const []]) =>
      const JsonEncoder.withIndent('  ').convert(value ?? fallback);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      final data = await repository.getPhpContainer(widget.id);
      if (!mounted) return;
      _name.text = '${data['containerName'] ?? ''}';
      _ports.text = _json(data['exposedPorts']);
      _environments.text = _json(data['environments']);
      _volumes.text = _json(data['volumes']);
      _hosts.text = _json(data['extraHosts']);
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
      showErrorToast(context, error);
    }
  }

  List<dynamic> _parse(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return const [];
    final decoded = jsonDecode(text);
    if (decoded is! List) throw const FormatException();
    return decoded;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    try {
      final body = <String, dynamic>{
        'id': widget.id,
        'containerName': _name.text.trim(),
        'exposedPorts': _parse(_ports),
        'environments': _parse(_environments),
        'volumes': _parse(_volumes),
        'extraHosts': _parse(_hosts),
      };
      setState(() => _saving = true);
      final repository = await ref.read(runtimeRepositoryProvider.future);
      await repository.updatePhpContainer(body);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      if (error is FormatException) {
        AppToast.error(context, l10n.runtime_jsonHint);
      } else {
        showErrorToast(context, error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_failed) {
      return EmptyState(
        icon: TablerIcons.alert_triangle,
        title: l10n.common_notAvailable,
        actionLabel: l10n.action_retry,
        onAction: _load,
      );
    }
    return ListView(
      padding: EdgeInsets.all(context.pagePadding),
      children: [
        AppTextField(controller: _name, label: l10n.runtime_containerName),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _ports,
          label: l10n.runtime_exposedPorts,
          maxLines: 8,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _environments,
          label: l10n.runtime_environments,
          maxLines: 8,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _volumes,
          label: l10n.runtime_volumes,
          maxLines: 8,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _hosts,
          label: l10n.runtime_extraHosts,
          maxLines: 6,
        ),
        const SizedBox(height: AppTokens.s16),
        PrimaryButton(
          label: l10n.action_save,
          loading: _saving,
          onPressed: _save,
        ),
      ],
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
                  decoration: InputDecoration(
                    labelText: l10n.runtimes_packageManager,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'npm', child: Text('npm')),
                    DropdownMenuItem(value: 'yarn', child: Text('yarn')),
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

class _PhpSupervisorTab extends ConsumerStatefulWidget {
  const _PhpSupervisorTab({required this.id});

  final int id;

  @override
  ConsumerState<_PhpSupervisorTab> createState() => _PhpSupervisorTabState();
}

class _PhpSupervisorTabState extends ConsumerState<_PhpSupervisorTab> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final repository = await ref.read(runtimeRepositoryProvider.future);
    return repository.getSupervisorProcesses(widget.id);
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(describeError(snapshot.error!, l10n)));
        }
        final items = snapshot.data ?? const <Map<String, dynamic>>[];
        if (items.isEmpty) {
          return EmptyState(
            icon: TablerIcons.shield,
            title: l10n.supervisor_emptyTitle,
            message: l10n.supervisor_emptySubtitle,
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
                      l10n.runtime_supervisor,
                      style: AppTextStyles.titleM,
                    ),
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
              child: ListView.separated(
                padding: EdgeInsets.all(context.pagePadding),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppTokens.s8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final name = '${item['name'] ?? ''}';
                  final status = _statusText(item['status']);
                  return TonalCard(
                    onTap: () => _actions(name),
                    child: Row(
                      children: [
                        const Icon(TablerIcons.shield),
                        const SizedBox(width: AppTokens.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppTextStyles.titleS),
                              Text(
                                [
                                  if ('${item['command'] ?? ''}'.isNotEmpty)
                                    '${item['command']}',
                                  if (status.isNotEmpty) status,
                                ].join(' · '),
                                style: AppTextStyles.caption.copyWith(
                                  color: context.scheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(TablerIcons.chevron_right),
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

  String _statusText(dynamic status) {
    if (status is! List) return '';
    return status
        .whereType<Map>()
        .map((item) => '${item['status'] ?? ''}')
        .where((item) => item.isNotEmpty)
        .join(',');
  }

  Future<void> _actions(String name) async {
    final l10n = AppLocalizations.of(context);
    final action = await showSelectionMenu<String>(
      context,
      title: name,
      options: [
        SelectionOption(
          value: 'start',
          label: l10n.containers_start,
          icon: TablerIcons.player_play,
        ),
        SelectionOption(
          value: 'stop',
          label: l10n.containers_stop,
          icon: TablerIcons.player_stop,
        ),
        SelectionOption(
          value: 'restart',
          label: l10n.containers_restart,
          icon: TablerIcons.refresh,
        ),
        SelectionOption(
          value: 'config',
          label: l10n.supervisor_editConfig,
          icon: TablerIcons.file_settings,
        ),
        SelectionOption(
          value: 'out.log',
          label: l10n.supervisor_viewOutLog,
          icon: TablerIcons.file_text,
        ),
        SelectionOption(
          value: 'err.log',
          label: l10n.supervisor_viewErrLog,
          icon: TablerIcons.file_alert,
        ),
        SelectionOption(
          value: 'delete',
          label: l10n.common_delete,
          icon: TablerIcons.trash,
          danger: true,
        ),
      ],
    );
    if (!mounted || action == null) return;
    if (action == 'config') {
      await _editFile(name, 'config');
    } else if (action.endsWith('.log')) {
      await _showFile(name, action);
    } else {
      await _operate(name, action);
    }
  }

  Future<void> _operate(String name, String operate) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: operate == 'delete' ? l10n.common_delete : l10n.action_done,
      message: l10n.supervisor_processOperateConfirm(name, operate),
      confirmLabel: operate == 'delete' ? l10n.common_delete : l10n.action_done,
      danger: operate == 'delete',
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      await repository.operateSupervisorProcess(widget.id, {
        'name': name,
        'operate': operate,
      });
      if (!mounted) return;
      AppToast.success(context, l10n.supervisor_operationSuccess);
      _refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showFile(String name, String file) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      final content = await repository.supervisorProcessFile(
        id: widget.id,
        name: name,
        operate: 'get',
        file: file,
      );
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.85,
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              file == 'out.log'
                  ? l10n.supervisor_viewOutLog
                  : l10n.supervisor_viewErrLog,
              style: AppTextStyles.titleL,
            ),
            const SizedBox(height: AppTokens.s12),
            Flexible(
              child: SingleChildScrollView(
                child: SelectableText(
                  content.isEmpty ? l10n.state_empty : content,
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

  Future<void> _editFile(String name, String file) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      final content = await repository.supervisorProcessFile(
        id: widget.id,
        name: name,
        operate: 'get',
        file: file,
      );
      if (!mounted) return;
      final controller = TextEditingController(text: content);
      final saved = await pushFormPage<bool>(
        context,
        Builder(
          builder: (pageContext) => SimpleFormPage(
            title: l10n.supervisor_editConfig,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [AppTextField(controller: controller, maxLines: 16)],
          ),
        ),
      );
      final value = controller.text;
      controller.dispose();
      if (saved != true || !mounted) return;
      await repository.supervisorProcessFile(
        id: widget.id,
        name: name,
        operate: 'update',
        file: file,
        content: value,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
      _refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _PhpPresetSheet extends ConsumerStatefulWidget {
  const _PhpPresetSheet({required this.runtimeId});

  final int runtimeId;

  @override
  ConsumerState<_PhpPresetSheet> createState() => _PhpPresetSheetState();
}

class _PhpPresetSheetState extends ConsumerState<_PhpPresetSheet> {
  late Future<List<PhpExtensionGroupDto>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<PhpExtensionGroupDto>> _load() async {
    final repository = await ref.read(runtimeRepositoryProvider.future);
    return repository.searchPhpExtensions();
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.runtime_extensionPresets,
                style: AppTextStyles.titleL,
              ),
            ),
            IconButton(
              tooltip: l10n.runtime_presetImport,
              icon: const Icon(TablerIcons.cloud_download),
              onPressed: _import,
            ),
            IconButton(
              tooltip: l10n.action_add,
              icon: const Icon(TablerIcons.plus),
              onPressed: _edit,
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s12),
        Flexible(
          child: FutureBuilder<List<PhpExtensionGroupDto>>(
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
              final items = snapshot.data ?? const <PhpExtensionGroupDto>[];
              if (items.isEmpty) {
                return EmptyState(
                  compact: true,
                  icon: TablerIcons.puzzle,
                  title: l10n.state_empty,
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppTokens.s8),
                itemBuilder: (context, index) {
                  final group = items[index];
                  return TonalCard(
                    onTap: () => _actions(group),
                    child: Row(
                      children: [
                        const Icon(TablerIcons.puzzle),
                        const SizedBox(width: AppTokens.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(group.name, style: AppTextStyles.titleS),
                              Text(
                                group.extensions,
                                style: AppTextStyles.caption.copyWith(
                                  color: context.scheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(TablerIcons.chevron_right),
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

  Future<void> _actions(PhpExtensionGroupDto group) async {
    final l10n = AppLocalizations.of(context);
    final action = await showSelectionMenu<String>(
      context,
      title: group.name,
      subtitle: group.extensions,
      options: [
        SelectionOption(
          value: 'edit',
          label: l10n.action_edit,
          icon: TablerIcons.edit,
        ),
        SelectionOption(
          value: 'push',
          label: l10n.runtime_presetPush,
          icon: TablerIcons.send,
        ),
        SelectionOption(
          value: 'delete',
          label: l10n.action_delete,
          icon: TablerIcons.trash,
          danger: true,
        ),
      ],
    );
    if (!mounted || action == null) return;
    if (action == 'edit') {
      await _edit(group: group);
    } else if (action == 'delete') {
      await _delete(group);
    } else if (action == 'push') {
      await _push(group);
    }
  }

  Future<void> _edit({PhpExtensionGroupDto? group}) async {
    final l10n = AppLocalizations.of(context);
    var current = group;
    if (current != null) {
      try {
        final repository = await ref.read(runtimeRepositoryProvider.future);
        final detail = await repository.getPhpExtensionPreset(current.id);
        current = PhpExtensionGroupDto(
          id: current.id,
          name: '${detail['name'] ?? current.name}',
          extensions: '${detail['extensions'] ?? current.extensions}',
        );
      } catch (_) {
        // Keep the list row data when the detail endpoint is unavailable.
      }
    }
    if (!mounted) return;
    final name = TextEditingController(text: current?.name ?? '');
    final extensions = TextEditingController(text: current?.extensions ?? '');
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: current == null ? l10n.runtime_presetNew : l10n.action_edit,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(
              controller: name,
              label: l10n.runtime_presetName,
              enabled: current == null,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: extensions,
              label: l10n.runtime_presetExtensions,
              helper: l10n.runtime_presetExtensionsHint,
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
    final nameValue = name.text.trim();
    final extensionsValue = extensions.text.trim();
    name.dispose();
    extensions.dispose();
    if (saved != true || !mounted) return;
    if (nameValue.isEmpty || extensionsValue.isEmpty) return;
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      if (current == null) {
        await repository.createPhpExtensionPreset(
          name: nameValue,
          extensions: extensionsValue,
        );
      } else {
        await repository.updatePhpExtensionPreset(
          id: current.id,
          extensions: extensionsValue,
        );
      }
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
      _refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController();
    final extensions = TextEditingController();
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.runtime_presetImport,
          saveLabel: l10n.action_import,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(controller: name, label: l10n.runtime_presetName),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: extensions,
              label: l10n.runtime_presetExtensions,
              helper: l10n.runtime_presetExtensionsHint,
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
    final nameValue = name.text.trim();
    final extensionsValue = extensions.text.trim();
    name.dispose();
    extensions.dispose();
    if (saved != true || !mounted || nameValue.isEmpty) return;
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      final status = await repository.importPhpExtensionPreset(
        name: nameValue,
        extensions: extensionsValue,
      );
      if (!mounted) return;
      AppToast.success(
        context,
        status == 'skipped'
            ? l10n.runtime_presetSkipped
            : l10n.runtime_presetImported,
      );
      _refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(PhpExtensionGroupDto group) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: l10n.runtime_presetDeleteConfirm(group.name),
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      await repository.deletePhpExtensionPreset(group.id);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      _refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _push(PhpExtensionGroupDto group) async {
    final l10n = AppLocalizations.of(context);
    final source = TextEditingController(text: 'local');
    final targets = TextEditingController();
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.runtime_presetPush,
          saveLabel: l10n.runtime_presetPush,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(
              controller: source,
              label: l10n.runtime_presetSourceNode,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: targets,
              label: l10n.runtime_presetTargetNodes,
              helper: l10n.runtime_presetNodesHint,
            ),
          ],
        ),
      ),
    );
    final sourceValue = source.text.trim();
    final targetValues = targets.text
        .split(RegExp(r'[,，\s]+'))
        .where((item) => item.trim().isNotEmpty)
        .toList(growable: false);
    source.dispose();
    targets.dispose();
    if (saved != true || !mounted || targetValues.isEmpty) return;
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      await repository.pushPhpExtensionPreset(
        id: group.id,
        sourceNode: sourceValue,
        targetNodes: targetValues,
        taskID: const Uuid().v4(),
      );
      if (!mounted) return;
      AppToast.success(context, l10n.runtime_presetPushed);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }
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
