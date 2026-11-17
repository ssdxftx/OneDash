import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/sheet_title.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

const _moduleProviders = ['local', 'prebuilt'];
const _moduleBuildModes = ['dynamic', 'static'];

String _moduleName(Map<String, dynamic> module) =>
    module['name']?.toString() ?? '';

List<Map<String, dynamic>> _moduleList(Map<String, dynamic> data) {
  final raw = data['modules'];
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map(Map<String, dynamic>.from)
      .toList(growable: false);
}

Future<void> showOpenRestyModulesSheet(BuildContext context) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.92,
    builder: (_) => const _OpenRestyModulesSheet(),
  );
}

class _OpenRestyModulesSheet extends ConsumerStatefulWidget {
  const _OpenRestyModulesSheet();

  @override
  ConsumerState<_OpenRestyModulesSheet> createState() =>
      _OpenRestyModulesSheetState();
}

class _OpenRestyModulesSheetState
    extends ConsumerState<_OpenRestyModulesSheet> {
  List<Map<String, dynamic>> _modules = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final data = await repository.getOpenRestyModules();
      if (!mounted) return;
      setState(() => _modules = _moduleList(data));
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(Map<String, dynamic> module, bool enable) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _modules = [
        for (final item in _modules)
          if (identical(item, module) ||
              _moduleName(item) == _moduleName(module))
            {...item, 'enable': enable}
          else
            item,
      ];
    });
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateOpenRestyModule({
        ...module,
        'enable': enable,
        'operate': 'update',
      });
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
      unawaited(_load());
    }
  }

  Future<void> _delete(Map<String, dynamic> module) async {
    final l10n = AppLocalizations.of(context);
    final name = _moduleName(module);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.websites_openRestyModuleDelete,
      message: l10n.websites_openRestyModuleDeleteConfirm(name),
      confirmLabel: l10n.action_delete,
      requireText: name,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateOpenRestyModule({
        'name': name,
        'operate': 'delete',
      });
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _add() async {
    final saved = await pushFormPage<bool>(
      context,
      const OpenRestyModuleEditorPage(),
    );
    if (saved ?? false) unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetTitle(
          title: l10n.websites_openRestyModules,
          onClose: () => Navigator.of(context).pop(),
          actions: [
            IconButton(
              tooltip: l10n.action_refresh,
              onPressed: _load,
              icon: const Icon(TablerIcons.refresh),
            ),
            IconButton(
              tooltip: l10n.websites_openRestyModuleAdd,
              onPressed: _add,
              icon: const Icon(TablerIcons.plus),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s8),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(AppTokens.s24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_modules.isEmpty)
          EmptyState(
            icon: TablerIcons.packages,
            title: l10n.websites_openRestyModules,
            message: l10n.websites_openRestyModuleEmpty,
            compact: true,
          )
        else
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(
                context.pagePadding,
                0,
                context.pagePadding,
                AppTokens.s24 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                for (final module in _modules)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.s8),
                    child: TonalCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _moduleName(module),
                                  style: AppTextStyles.titleS,
                                ),
                                Text(
                                  [
                                        module['provider']?.toString() ?? '',
                                        module['buildMode']?.toString() ?? '',
                                        module['loadStatus']?.toString() ?? '',
                                      ]
                                      .where((item) => item.isNotEmpty)
                                      .join(' · '),
                                  style: AppTextStyles.bodyS.copyWith(
                                    color: context.scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: module['enable'] == true,
                            onChanged: (value) => _toggle(module, value),
                          ),
                          IconButton(
                            tooltip: l10n.websites_openRestyModuleDelete,
                            icon: const Icon(TablerIcons.trash),
                            onPressed: () => _delete(module),
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
}

class OpenRestyModuleEditorPage extends ConsumerStatefulWidget {
  const OpenRestyModuleEditorPage({super.key});

  @override
  ConsumerState<OpenRestyModuleEditorPage> createState() =>
      _OpenRestyModuleEditorPageState();
}

class _OpenRestyModuleEditorPageState
    extends ConsumerState<OpenRestyModuleEditorPage> {
  final _name = TextEditingController();
  final _loadOrder = TextEditingController(text: '0');
  final _packages = TextEditingController();
  final _params = TextEditingController();
  final _script = TextEditingController();
  String _provider = 'local';
  String _buildMode = 'dynamic';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _loadOrder.dispose();
    _packages.dispose();
    _params.dispose();
    _script.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty) {
      AppToast.error(context, l10n.websites_openRestyModuleName);
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateOpenRestyModule({
        'name': _name.text.trim(),
        'operate': 'create',
        'provider': _provider,
        'buildMode': _buildMode,
        'loadOrder': int.tryParse(_loadOrder.text.trim()) ?? 0,
        'packages': _packages.text.trim(),
        'params': _params.text.trim(),
        'script': _script.text,
      });
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
      Navigator.of(context).pop(true);
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
    return SimpleFormPage(
      title: l10n.websites_openRestyModuleAdd,
      saving: _saving,
      onSave: _save,
      children: [
        SectionHeader(title: l10n.websites_openRestyModules),
        TonalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _name,
                label: l10n.websites_openRestyModuleName,
              ),
              const SizedBox(height: AppTokens.s12),
              DropdownButtonFormField<String>(
                initialValue: _provider,
                decoration: InputDecoration(
                  labelText: l10n.websites_openRestyModuleProvider,
                ),
                items: [
                  for (final provider in _moduleProviders)
                    DropdownMenuItem(value: provider, child: Text(provider)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _provider = value);
                },
              ),
              const SizedBox(height: AppTokens.s12),
              DropdownButtonFormField<String>(
                initialValue: _buildMode,
                decoration: InputDecoration(
                  labelText: l10n.websites_openRestyModuleBuildMode,
                ),
                items: [
                  for (final mode in _moduleBuildModes)
                    DropdownMenuItem(value: mode, child: Text(mode)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _buildMode = value);
                },
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _loadOrder,
                label: l10n.websites_openRestyModuleLoadOrder,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _packages,
                label: l10n.websites_openRestyModulePackages,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _params,
                label: l10n.websites_openRestyModuleParams,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _script,
                label: l10n.websites_openRestyModuleScript,
                maxLines: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OpenRestyBuildPage extends ConsumerStatefulWidget {
  const OpenRestyBuildPage({super.key});

  @override
  ConsumerState<OpenRestyBuildPage> createState() => _OpenRestyBuildPageState();
}

class _OpenRestyBuildPageState extends ConsumerState<OpenRestyBuildPage> {
  final _mirror = TextEditingController();
  List<Map<String, dynamic>> _modules = const [];
  final _selected = <String>{};
  bool _force = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _mirror.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final data = await repository.getOpenRestyModules();
      if (!mounted) return;
      setState(() {
        _modules = _moduleList(data);
        _mirror.text = data['mirror']?.toString() ?? '';
        for (final module in _modules) {
          if (module['enable'] == true) _selected.add(_moduleName(module));
        }
      });
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _build() async {
    final l10n = AppLocalizations.of(context);
    if (_mirror.text.trim().isEmpty) {
      AppToast.error(context, l10n.websites_openRestyMirror);
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.buildOpenResty(
        mirror: _mirror.text.trim(),
        taskID: const Uuid().v4(),
        modules: _selected.toList(growable: false),
        force: _force,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.websites_openRestyBuildSubmitted);
      Navigator.of(context).pop(true);
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
    if (_loading) {
      return Scaffold(
        appBar: AppBarLarge(title: l10n.websites_openRestyBuild),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return SimpleFormPage(
      title: l10n.websites_openRestyBuild,
      subtitle: l10n.websites_openRestyBuildHint,
      saving: _saving,
      onSave: _build,
      children: [
        SectionHeader(title: l10n.websites_openRestyBuild),
        TonalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _mirror,
                label: l10n.websites_openRestyMirror,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: AppTokens.s12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.websites_openRestyForce),
                value: _force,
                onChanged: (value) => setState(() => _force = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.s24),
        SectionHeader(title: l10n.websites_openRestyBuildModules),
        for (final module in _modules)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_moduleName(module)),
            value: _selected.contains(_moduleName(module)),
            onChanged: (value) {
              setState(() {
                final name = _moduleName(module);
                if (value ?? false) {
                  _selected.add(name);
                } else {
                  _selected.remove(name);
                }
              });
            },
          ),
      ],
    );
  }
}

Future<void> showOpenRestyHttpsSheet(BuildContext context) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.7,
    builder: (_) => const _OpenRestyHttpsSheet(),
  );
}

class _OpenRestyHttpsSheet extends ConsumerStatefulWidget {
  const _OpenRestyHttpsSheet();

  @override
  ConsumerState<_OpenRestyHttpsSheet> createState() =>
      _OpenRestyHttpsSheetState();
}

class _OpenRestyHttpsSheetState extends ConsumerState<_OpenRestyHttpsSheet> {
  bool _loading = true;
  bool _loadFailed = false;
  bool _saving = false;
  bool _https = false;
  bool _rejectHandshake = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final data = await repository.getOpenRestyHttps();
      if (!mounted) return;
      setState(() {
        _https = data['https'] == true;
        _rejectHandshake = data['sslRejectHandshake'] == true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadFailed = true);
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateOpenRestyHttps(
        operate: _https ? 'enable' : 'disable',
        sslRejectHandshake: _rejectHandshake,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
      Navigator.of(context).pop();
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetTitle(
          title: l10n.websites_openRestyHttps,
          onClose: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: AppTokens.s8),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(AppTokens.s24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_loadFailed)
          Padding(
            padding: const EdgeInsets.all(AppTokens.s24),
            child: Column(
              children: [
                Text(l10n.websites_openRestyHttpsLoadFailed),
                const SizedBox(height: AppTokens.s12),
                SecondaryButton(label: l10n.action_retry, onPressed: _load),
              ],
            ),
          )
        else ...[
          Text(
            l10n.websites_openRestyHttpsHint,
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.websites_openRestyHttps),
            value: _https,
            onChanged: (value) => setState(() => _https = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.websites_openRestyHttpsReject),
            value: _rejectHandshake,
            onChanged: (value) => setState(() => _rejectHandshake = value),
          ),
          const SizedBox(height: AppTokens.s16),
          PrimaryButton(
            label: l10n.action_save,
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ],
    );
  }
}
