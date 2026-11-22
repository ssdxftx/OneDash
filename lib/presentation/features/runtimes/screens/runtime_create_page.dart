import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/app/app_catalog_dto.dart';
import '../../../../data/dto/app/app_catalog_search_req.dart';
import '../../../../data/dto/app/app_install_config_dto.dart';
import '../../../../data/dto/runtime/runtime_dto.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../../data/repositories_impl/runtime_repository_impl.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/states/error_toast.dart';

const _runtimeTypes = <String>['node', 'php', 'java', 'go', 'python', 'dotnet'];

class RuntimeCreatePage extends ConsumerStatefulWidget {
  const RuntimeCreatePage({super.key});

  @override
  ConsumerState<RuntimeCreatePage> createState() => _RuntimeCreatePageState();
}

class _RuntimeCreatePageState extends ConsumerState<RuntimeCreatePage> {
  final _name = TextEditingController();
  final _codeDir = TextEditingController(text: '/');
  final _port = TextEditingController(text: '8080');
  final _source = TextEditingController(text: 'https://registry.npmjs.org/');
  final _remark = TextEditingController();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _booleans = {};
  final Map<String, String> _selects = {};

  String _type = 'node';
  List<AppCatalogDto> _apps = const [];
  AppCatalogDto? _app;
  List<String> _versions = const [];
  String? _version;
  AppInstallConfigDto? _config;
  int _appDetailID = 0;
  bool _installDependencies = true;
  bool _loadingApps = true;
  bool _loadingConfig = false;
  bool _saving = false;
  String? _appsError;
  String? _configError;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  @override
  void dispose() {
    _name.dispose();
    _codeDir.dispose();
    _port.dispose();
    _source.dispose();
    _remark.dispose();
    _disposeFields();
    super.dispose();
  }

  bool _isBool(AppInstallFieldDto field) {
    final type = field.type.toLowerCase();
    return type == 'boolean' || type == 'bool' || type == 'switch';
  }

  void _disposeFields() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _booleans.clear();
    _selects.clear();
  }

  Future<void> _loadApps() async {
    setState(() {
      _loadingApps = true;
      _appsError = null;
      _apps = const [];
      _app = null;
      _versions = const [];
      _version = null;
      _config = null;
      _appDetailID = 0;
      _disposeFields();
    });
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final result = await repository.searchApps(
        AppCatalogSearchReq(
          page: 1,
          pageSize: 100,
          type: _type,
          resource: 'all',
        ),
      );
      if (!mounted) return;
      setState(() {
        _apps = result.items;
        _loadingApps = false;
      });
      if (result.items.isNotEmpty) {
        await _selectApp(result.items.first);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _appsError = describeError(error, AppLocalizations.of(context));
        _loadingApps = false;
      });
    }
  }

  Future<void> _selectApp(AppCatalogDto app) async {
    setState(() {
      _app = app;
      _versions = app.versions;
      _version = app.versions.isEmpty ? null : app.versions.first;
      _config = null;
      _configError = null;
      _appDetailID = 0;
      _disposeFields();
    });
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final detail = await repository.getAppDetail(app.key);
      if (!mounted || _app?.key != app.key) return;
      final versions = detail.versions.isEmpty ? app.versions : detail.versions;
      setState(() {
        _versions = versions;
        _version = versions.isEmpty ? null : versions.first;
      });
      if (_version != null) {
        await _loadVersion(_version!);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _configError = describeError(error, AppLocalizations.of(context));
      });
      final version = _version;
      if (version != null) await _loadVersion(version);
    }
  }

  Future<void> _loadVersion(String version) async {
    final app = _app;
    if (app == null || version.isEmpty) return;
    setState(() {
      _version = version;
      _loadingConfig = true;
      _configError = null;
      _config = null;
      _appDetailID = 0;
      _disposeFields();
    });
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final config = await repository.getAppRuntimeConfig(app.id, version);
      var detailID = config.id;
      if (_type == 'node') {
        try {
          final node = await repository.getNodeAppDetail(
            appKey: app.key,
            version: version,
          );
          if (node.id > 0) detailID = node.id;
        } catch (_) {
          // Fall back to the generic runtime config id below.
        }
      }
      if (!mounted || _app?.key != app.key || _version != version) return;
      for (final field in config.params.formFields) {
        final value = field.defaultValue;
        if (_isBool(field)) {
          _booleans[field.envKey] =
              value == true || '$value'.toLowerCase() == 'true';
        } else if (field.type == 'select' &&
            field.values != null &&
            field.values!.isNotEmpty) {
          final raw = value?.toString();
          _selects[field.envKey] =
              field.values!.any((item) => item.value == raw)
              ? raw!
              : field.values!.first.value;
        } else {
          _controllers[field.envKey] = TextEditingController(
            text: value?.toString() ?? '',
          );
        }
      }
      setState(() {
        _config = config;
        _appDetailID = detailID;
        _loadingConfig = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _configError = describeError(error, AppLocalizations.of(context));
        _loadingConfig = false;
      });
    }
  }

  String? _missingRequired(AppInstallConfigDto config) {
    for (final field in config.params.formFields) {
      if (!field.required) continue;
      if (_isBool(field)) continue;
      if (field.type == 'select') {
        if ((_selects[field.envKey] ?? '').isEmpty) return field.label;
      } else if ((_controllers[field.envKey]?.text ?? '').trim().isEmpty) {
        return field.label;
      }
    }
    return null;
  }

  dynamic _fieldValue(AppInstallFieldDto field) {
    if (_isBool(field)) return _booleans[field.envKey] ?? false;
    if (field.type == 'select') return _selects[field.envKey] ?? '';
    final value = _controllers[field.envKey]?.text.trim() ?? '';
    if (field.type.toLowerCase() == 'number') {
      return num.tryParse(value) ?? value;
    }
    return value;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final app = _app;
    final version = _version;
    final config = _config;
    final name = _name.text.trim();
    if (name.isEmpty) {
      AppToast.warning(context, l10n.runtime_name);
      return;
    }
    if (app == null || version == null) {
      AppToast.warning(context, l10n.apps_requiredMissing(l10n.runtime_app));
      return;
    }
    if (config == null || _appDetailID <= 0) {
      AppToast.warning(context, l10n.runtime_appDetailId);
      return;
    }
    final missing = _missingRequired(config);
    if (missing != null) {
      AppToast.error(context, l10n.apps_requiredMissing(missing));
      return;
    }
    final port = int.tryParse(_port.text.trim()) ?? 0;
    if (port <= 0 || port > 65535) {
      AppToast.warning(context, l10n.runtime_portInvalid);
      return;
    }
    if (_codeDir.text.trim().isEmpty) {
      AppToast.warning(context, l10n.runtime_codeDir);
      return;
    }
    if ((_type == 'node' || _type == 'php') && _source.text.trim().isEmpty) {
      AppToast.warning(context, l10n.apps_requiredMissing(l10n.runtime_source));
      return;
    }
    final params = <String, dynamic>{
      for (final field in config.params.formFields)
        field.envKey: _fieldValue(field),
    };
    if ('${params['CONTAINER_NAME'] ?? ''}'.trim().isEmpty) {
      params['CONTAINER_NAME'] = name;
    }
    if (_type != 'php') {
      params.putIfAbsent('HOST_IP', () => '0.0.0.0');
    }
    if (_type == 'node') {
      params.putIfAbsent('PACKAGE_MANAGER', () => 'npm');
      params.putIfAbsent('CUSTOM_SCRIPT', () => '0');
    }
    setState(() => _saving = true);
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      await repository.createRuntime(
        RuntimeCreateReq(
          taskID: const Uuid().v4(),
          name: name,
          appDetailID: _appDetailID,
          image: config.image ?? '',
          params: params,
          type: _type,
          resource: 'appstore',
          appID: app.id,
          version: version,
          source: _type == 'node' || _type == 'php'
              ? _source.text.trim()
              : null,
          codeDir: _codeDir.text.trim(),
          port: port,
          install: _type == 'node' ? _installDependencies : null,
          remark: _remark.text.trim(),
        ),
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = _config;
    return SimpleFormPage(
      title: l10n.runtime_create,
      saveLabel: l10n.action_create,
      saving: _saving,
      onSave: _save,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _type,
          decoration: InputDecoration(labelText: l10n.runtime_typeLabel),
          items: [
            for (final type in _runtimeTypes)
              DropdownMenuItem(value: type, child: Text(type)),
          ],
          onChanged: _saving
              ? null
              : (value) {
                  if (value == null || value == _type) return;
                  _type = value;
                  _port.text = value == 'node' ? '4004' : '8080';
                  _source.text = value == 'node'
                      ? 'https://registry.npmjs.org/'
                      : value == 'php'
                      ? 'https://deb.debian.org'
                      : '';
                  _loadApps();
                },
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: _name, label: l10n.runtime_name),
        const SizedBox(height: AppTokens.s12),
        if (_loadingApps)
          const LinearProgressIndicator()
        else if (_appsError != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _appsError!,
                style: AppTextStyles.bodyS.copyWith(
                  color: context.scheme.error,
                ),
              ),
              const SizedBox(height: AppTokens.s8),
              TextButton(onPressed: _loadApps, child: Text(l10n.action_retry)),
            ],
          )
        else if (_apps.isEmpty)
          Text(
            l10n.runtimes_emptyTitle,
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          )
        else ...[
          DropdownButtonFormField<String>(
            initialValue: _app?.key,
            decoration: InputDecoration(labelText: l10n.runtime_app),
            items: [
              for (final app in _apps)
                DropdownMenuItem(
                  value: app.key,
                  child: Text(app.name.isEmpty ? app.key : app.name),
                ),
            ],
            onChanged: _saving
                ? null
                : (value) {
                    if (value == null) return;
                    final app = _apps
                        .where((item) => item.key == value)
                        .firstOrNull;
                    if (app != null) _selectApp(app);
                  },
          ),
          const SizedBox(height: AppTokens.s12),
          DropdownButtonFormField<String>(
            initialValue: _version,
            decoration: InputDecoration(labelText: l10n.apps_version),
            items: [
              for (final version in _versions)
                DropdownMenuItem(value: version, child: Text(version)),
            ],
            onChanged: _saving || _loadingConfig
                ? null
                : (value) {
                    if (value != null) _loadVersion(value);
                  },
          ),
        ],
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _codeDir,
          label: l10n.runtime_codeDir,
          hint: '/opt/app',
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _port,
          label: l10n.runtime_port,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppTokens.s12),
        if (_type == 'node' || _type == 'php') ...[
          AppTextField(controller: _source, label: l10n.runtime_source),
          const SizedBox(height: AppTokens.s12),
        ],
        if (_type == 'node')
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.runtime_installDependencies),
            value: _installDependencies,
            onChanged: _saving
                ? null
                : (value) => setState(() => _installDependencies = value),
          ),
        AppTextField(controller: _remark, label: l10n.runtime_remark),
        if (_loadingConfig)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTokens.s24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_configError != null)
          Padding(
            padding: const EdgeInsets.only(top: AppTokens.s12),
            child: Text(
              _configError!,
              style: AppTextStyles.bodyS.copyWith(color: context.scheme.error),
            ),
          )
        else if (config != null &&
            config.params.formFields
                .where((field) => field.edit)
                .isNotEmpty) ...[
          const SizedBox(height: AppTokens.s16),
          SectionHeader(title: l10n.apps_installParams),
          for (final field in config.params.formFields)
            if (field.edit) ...[
              _buildField(field),
              const SizedBox(height: AppTokens.s12),
            ],
        ],
      ],
    );
  }

  Widget _buildField(AppInstallFieldDto field) {
    if (_isBool(field)) {
      return SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(field.label, style: AppTextStyles.bodyM),
        subtitle: field.required
            ? Text(
                AppLocalizations.of(context).apps_required,
                style: AppTextStyles.caption,
              )
            : null,
        value: _booleans[field.envKey] ?? false,
        onChanged: (value) => setState(() => _booleans[field.envKey] = value),
      );
    }
    if (field.type == 'select' && field.values != null) {
      return DropdownButtonFormField<String>(
        initialValue: _selects[field.envKey],
        decoration: InputDecoration(labelText: field.label),
        items: [
          for (final value in field.values!)
            DropdownMenuItem(value: value.value, child: Text(value.label)),
        ],
        onChanged: (value) =>
            setState(() => _selects[field.envKey] = value ?? ''),
      );
    }
    final type = field.type.toLowerCase();
    return AppTextField(
      controller: _controllers[field.envKey],
      label: '${field.label}${field.required ? ' *' : ''}',
      obscure: type == 'password',
      keyboardType: type == 'number'
          ? TextInputType.number
          : TextInputType.text,
      maxLines: type == 'textarea' ? 4 : 1,
      helper: field.rule,
    );
  }
}
