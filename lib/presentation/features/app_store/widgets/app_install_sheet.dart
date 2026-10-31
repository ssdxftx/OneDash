import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/app/app_detail_dto.dart';
import '../../../../data/dto/app/app_install_config_dto.dart';
import '../../../../data/dto/app/app_install_req.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/states/error_toast.dart';

class AppInstallSheet extends ConsumerStatefulWidget {
  const AppInstallSheet({super.key, required this.app});

  final AppDetailDto app;

  @override
  ConsumerState<AppInstallSheet> createState() => _AppInstallSheetState();
}

class _AppInstallSheetState extends ConsumerState<AppInstallSheet> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _booleans = {};
  final Map<String, String> _selects = {};

  String? _version;
  AppInstallConfigDto? _config;
  String? _error;
  bool _loading = true;
  bool _installing = false;

  @override
  void initState() {
    super.initState();
    _version = widget.app.versions.isEmpty ? null : widget.app.versions.first;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final config = await repository.getAppInstallConfig(
        widget.app.id,
        _version ?? '',
      );
      if (!mounted) return;
      _disposeControllers();
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
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = describeError(error, AppLocalizations.of(context));
        _loading = false;
      });
    }
  }

  bool _isBool(AppInstallFieldDto field) {
    final type = field.type.toLowerCase();
    return type == 'boolean' || type == 'bool' || type == 'switch';
  }

  void _disposeControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _booleans.clear();
    _selects.clear();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
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

  Future<void> _install() async {
    final config = _config;
    if (config == null) return;
    final missing = _missingRequired(config);
    if (missing != null) {
      AppToast.error(
        context,
        AppLocalizations.of(context).apps_requiredMissing(missing),
      );
      return;
    }
    setState(() => _installing = true);
    try {
      final params = <String, dynamic>{};
      for (final field in config.params.formFields) {
        if (_isBool(field)) {
          params[field.envKey] = _booleans[field.envKey] ?? false;
        } else if (field.type == 'select') {
          params[field.envKey] = _selects[field.envKey] ?? '';
        } else {
          params[field.envKey] = _controllers[field.envKey]?.text.trim() ?? '';
        }
      }
      final appName = (params['PANEL_APP_NAME'] ?? '').toString().trim();
      final name = appName.isNotEmpty
          ? appName
          : '${widget.app.key.isEmpty ? widget.app.name : widget.app.key}-${const Uuid().v4().substring(0, 4)}';
      final repository = await ref.read(appRepositoryProvider.future);
      await repository.installApp(
        AppInstallReq(
          appDetailId: config.id,
          params: params,
          name: name,
          version: config.version,
          taskID: const Uuid().v4(),
          appID: widget.app.key,
        ),
      );
      if (!mounted) return;
      AppToast.success(context, AppLocalizations.of(context).action_done);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _installing = false);
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.app.name, style: AppTextStyles.titleL),
                  Text(
                    widget.app.key,
                    style: AppTextStyles.bodyS.copyWith(
                      color: scheme.onSurfaceVariant,
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
        const SizedBox(height: AppTokens.s16),
        if (widget.app.versions.length > 1) ...[
          SectionHeader(title: l10n.apps_version),
          DropdownButtonFormField<String>(
            initialValue: _version,
            items: [
              for (final version in widget.app.versions)
                DropdownMenuItem(value: version, child: Text(version)),
            ],
            onChanged: _loading
                ? null
                : (value) {
                    if (value == null || value == _version) return;
                    setState(() => _version = value);
                    _load();
                  },
          ),
          const SizedBox(height: AppTokens.s16),
        ],
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTokens.s32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTokens.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_error!, style: AppTextStyles.bodyS),
                const SizedBox(height: AppTokens.s12),
                SecondaryButton(label: l10n.action_retry, onPressed: _load),
              ],
            ),
          )
        else if (_config != null) ...[
          SectionHeader(title: l10n.apps_installParams),
          for (final field in _config!.params.formFields)
            if (field.edit) ...[
              _buildField(field),
              const SizedBox(height: AppTokens.s12),
            ],
          const SizedBox(height: AppTokens.s16),
          PrimaryButton(
            label: l10n.apps_install,
            icon: TablerIcons.download,
            loading: _installing,
            onPressed: _installing ? null : _install,
          ),
          const SizedBox(height: AppTokens.s8),
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
    final isPassword = type == 'password';
    final isNumber = type == 'number';
    final isTextarea = type == 'textarea';
    return AppTextField(
      controller: _controllers[field.envKey],
      label: '${field.label}${field.required ? ' *' : ''}',
      obscure: isPassword,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: isTextarea ? 4 : 1,
      helper: field.rule,
    );
  }
}
