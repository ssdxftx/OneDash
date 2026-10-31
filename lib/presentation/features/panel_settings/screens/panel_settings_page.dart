import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/setting_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/async_state_view.dart';
import '../../servers/providers/servers_provider.dart';
import '../../../common/states/error_toast.dart';

class _PanelSettingsData {
  const _PanelSettingsData(this.settings, this.core);

  final Map<String, dynamic> settings;
  final Map<String, dynamic> core;

  Object? _lookup(Map<String, dynamic> source, String key) {
    for (final entry in source.entries) {
      if (entry.key.toLowerCase() == key.toLowerCase()) return entry.value;
    }
    return null;
  }

  Object? raw(String key) => _lookup(core, key) ?? _lookup(settings, key);

  String value(String key, {String fallback = ''}) {
    final result = raw(key);
    if (result == null) return fallback;
    final text = result.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  bool enabled(String key) {
    final text = value(key).toLowerCase();
    return text == 'enable' || text == 'enabled' || text == 'true';
  }

  String get theme {
    final current = value('theme', fallback: 'auto').toLowerCase();
    return current == 'light' || current == 'dark' ? current : 'auto';
  }

  String get language {
    final current = value('language', fallback: 'en');
    return current.isEmpty ? 'en' : current;
  }

  int get sessionTimeout => int.tryParse(value('sessionTimeout')) ?? 0;
}

final _panelSettingsProvider = FutureProvider.autoDispose<_PanelSettingsData>((
  ref,
) async {
  final repository = await ref.watch(settingRepositoryProvider.future);
  final results = await Future.wait([
    repository.searchSettings(),
    repository.searchCoreSettings(),
  ]);
  return _PanelSettingsData(results[0], results[1]);
}, name: 'panelSettingsProvider');

class PanelSettingsPage extends ConsumerWidget {
  const PanelSettingsPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(_panelSettingsProvider);
    final server = ref.watch(serverByIdProvider(serverId)).valueOrNull;
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.panel_settings_title,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_panelSettingsProvider),
          ),
        ],
      ),
      body: AsyncStateView(
        value: settings,
        onRetry: () => ref.invalidate(_panelSettingsProvider),
        loading: const SkeletonList(itemCount: 10),
        builder: (data) => _PanelSettingsBody(
          serverId: serverId,
          data: data,
          serverUrl: server?.baseUrl,
        ),
      ),
    );
  }
}

class _PanelSettingsBody extends ConsumerWidget {
  const _PanelSettingsBody({
    required this.serverId,
    required this.data,
    required this.serverUrl,
  });

  final int serverId;
  final _PanelSettingsData data;
  final Uri? serverUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final themeLabel = switch (data.theme) {
      'light' => l10n.panelSettings_themeLight,
      'dark' => l10n.panelSettings_themeDark,
      _ => l10n.common_systemDefault,
    };
    final languageLabel = _languageLabel(l10n, data.language);
    final sessionTimeout = data.sessionTimeout <= 0
        ? l10n.panelSettings_neverTimeout
        : l10n.panelSettings_secondsValue(data.sessionTimeout.toString());

    return ListView(
      padding: const EdgeInsets.only(bottom: AppTokens.s32),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SplitListGroup(
                children: [
                  SplitListTile(
                    leading: const Icon(TablerIcons.world_www),
                    title: l10n.panelSettings_openWeb,
                    subtitle: serverUrl?.toString() ?? '-',
                    trailing: const Icon(TablerIcons.external_link),
                    onTap: serverUrl == null
                        ? null
                        : () => launchUrl(
                            serverUrl!,
                            mode: LaunchMode.externalApplication,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.s24),
              SectionHeader(title: l10n.panelSettings_basicInfo),
              SplitListGroup(
                children: [
                  SplitListTile(
                    leading: const Icon(TablerIcons.world),
                    title: l10n.panelSettings_defaultAccessAddress,
                    subtitle: data.value(
                      'systemIP',
                      fallback: l10n.panelSettings_notSet,
                    ),
                    trailing: const Icon(TablerIcons.pencil),
                    onTap: () async {
                      final value = await _editValue(
                        context,
                        title: l10n.panelSettings_defaultAccessAddress,
                        initial: data.value('systemIP'),
                        hint:
                            l10n.panelSettings_defaultAccessAddressPlaceholder,
                        keyboardType: TextInputType.url,
                      );
                      if (value == null || !context.mounted) return;
                      await _update(
                        context,
                        ref,
                        () => ref
                            .read(settingRepositoryProvider.future)
                            .then(
                              (repo) => repo.updateSetting(
                                key: 'systemIP',
                                value: value,
                              ),
                            ),
                        l10n,
                      );
                    },
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.user),
                    title: l10n.panelSettings_panelUsername,
                    subtitle: data.value(
                      'userName',
                      fallback: l10n.panelSettings_notSet,
                    ),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.lock),
                    title: l10n.panelSettings_panelLoginPassword,
                    subtitle: l10n.panelSettings_changePanelLoginPassword,
                    trailing: Text(
                      l10n.panelSettings_webOnlyTag,
                      style: AppTextStyles.caption.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.s24),
              SectionHeader(title: l10n.panelSettings_displaySettingsWebOnly),
              SplitListGroup(
                children: [
                  SplitListTile(
                    leading: const Icon(TablerIcons.sun),
                    title: l10n.panelSettings_theme,
                    subtitle: themeLabel,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => _pickTheme(context, ref, l10n),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.language),
                    title: l10n.panelSettings_language,
                    subtitle: languageLabel,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => _pickLanguage(context, ref, l10n),
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.s16,
                    ),
                    secondary: const Icon(TablerIcons.layout_2),
                    title: Text(
                      l10n.panelSettings_tabNavigation,
                      style: AppTextStyles.bodyL.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      l10n.panelSettings_tabNavigationSubtitle,
                      style: AppTextStyles.bodyS.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    value: data.enabled('menuTabs'),
                    onChanged: (value) => _updateCore(
                      context,
                      ref,
                      l10n,
                      'MenuTabs',
                      value ? 'Enable' : 'Disable',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.s24),
              SectionHeader(title: l10n.panelSettings_securitySettings),
              SplitListGroup(
                children: [
                  SplitListTile(
                    leading: const Icon(TablerIcons.clock),
                    title: l10n.panelSettings_sessionTimeout,
                    subtitle: sessionTimeout,
                    trailing: const Icon(TablerIcons.pencil),
                    onTap: () async {
                      final value = await _editValue(
                        context,
                        title: l10n.panelSettings_sessionTimeout,
                        initial: data.sessionTimeout <= 0
                            ? ''
                            : data.sessionTimeout.toString(),
                        hint: l10n.panelSettings_sessionTimeoutPlaceholder,
                        description:
                            l10n.panelSettings_sessionTimeoutDescription,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      );
                      if (value == null || !context.mounted) return;
                      await _updateCore(
                        context,
                        ref,
                        l10n,
                        'SessionTimeout',
                        value,
                      );
                    },
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.plug),
                    title: l10n.panelSettings_panelPort,
                    subtitle: data.value(
                      'serverPort',
                      fallback: l10n.panelSettings_notSet,
                    ),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.door),
                    title: l10n.panelSettings_securityEntrance,
                    subtitle: data.value(
                      'securityEntrance',
                      fallback: l10n.panelSettings_notSet,
                    ),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.world),
                    title: l10n.panelSettings_bindDomain,
                    subtitle: data.value(
                      'bindDomain',
                      fallback: l10n.panelSettings_notSet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.s8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.s8,
                  vertical: AppTokens.s8,
                ),
                child: Text(
                  l10n.panelSettings_webPanelRequired,
                  style: AppTextStyles.bodyS.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.s16),
              SectionHeader(title: l10n.panelSettings_advancedSettings),
              SplitListGroup(
                children: [
                  SplitListTile(
                    leading: const Icon(TablerIcons.api_app),
                    title: l10n.panelSettings_apiInterface,
                    subtitle: data.enabled('apiInterfaceStatus')
                        ? l10n.panelSettings_enabled
                        : l10n.panelSettings_disabled,
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.key),
                    title: l10n.panelSettings_credentials,
                    subtitle: data.value('apiKey').isEmpty
                        ? l10n.panelSettings_localApiKey
                        : '••••••••',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _languageLabel(AppLocalizations l10n, String code) {
    return switch (code) {
      'zh' => l10n.panelSettings_languageZh,
      'zh-Hant' => l10n.panelSettings_languageZhHant,
      'ja' => l10n.panelSettings_languageJa,
      'ms' => l10n.panelSettings_languageMs,
      'pt-BR' => l10n.panelSettings_languagePtBr,
      _ => 'English',
    };
  }

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final value = await _pickOption<String>(
      context,
      title: l10n.panelSettings_theme,
      options: [
        (value: 'light', label: l10n.panelSettings_themeLight),
        (value: 'dark', label: l10n.panelSettings_themeDark),
        (value: 'auto', label: l10n.common_systemDefault),
      ],
    );
    if (value != null && context.mounted) {
      await _updateCore(context, ref, l10n, 'Theme', value);
    }
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final value = await _pickOption<String>(
      context,
      title: l10n.panelSettings_language,
      options: [
        (value: 'zh', label: l10n.panelSettings_languageZh),
        (value: 'en', label: 'English'),
        (value: 'ja', label: l10n.panelSettings_languageJa),
        (value: 'ms', label: l10n.panelSettings_languageMs),
        (value: 'pt-BR', label: l10n.panelSettings_languagePtBr),
        (value: 'zh-Hant', label: l10n.panelSettings_languageZhHant),
      ],
    );
    if (value != null && context.mounted) {
      await _updateCore(context, ref, l10n, 'Language', value);
    }
  }

  Future<void> _updateCore(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String key,
    String value,
  ) async {
    await _update(
      context,
      ref,
      () => ref
          .read(settingRepositoryProvider.future)
          .then((repo) => repo.updateCoreSetting(key: key, value: value)),
      l10n,
    );
  }

  Future<void> _update(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
    AppLocalizations l10n,
  ) async {
    try {
      await action();
      if (!context.mounted) return;
      AppToast.success(context, l10n.panelSettings_settingUpdated);
      ref.invalidate(_panelSettingsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error, prefix: l10n.panelSettings_updateFailed);
    }
  }
}

Future<String?> _editValue(
  BuildContext context, {
  required String title,
  required String initial,
  String? hint,
  String? description,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
}) {
  return showAppSheet<String>(
    context: context,
    builder: (context) => _ValueEditorSheet(
      title: title,
      initial: initial,
      hint: hint,
      description: description,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    ),
  );
}

class _ValueEditorSheet extends StatefulWidget {
  const _ValueEditorSheet({
    required this.title,
    required this.initial,
    this.hint,
    this.description,
    this.keyboardType,
    this.inputFormatters,
  });

  final String title;
  final String initial;
  final String? hint;
  final String? description;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<_ValueEditorSheet> createState() => _ValueEditorSheetState();
}

class _ValueEditorSheetState extends State<_ValueEditorSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.title, style: AppTextStyles.titleL),
        if (widget.description != null) ...[
          const SizedBox(height: AppTokens.s8),
          Text(
            widget.description!,
            style: AppTextStyles.bodyS.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: AppTokens.s16),
        TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(hintText: widget.hint),
        ),
        const SizedBox(height: AppTokens.s24),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: l10n.action_cancel,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: PrimaryButton(
                label: l10n.action_save,
                onPressed: () {
                  final value = _controller.text.trim();
                  Navigator.of(context).pop(value.isEmpty ? null : value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<T?> _pickOption<T>(
  BuildContext context, {
  required String title,
  required List<({T value, String label})> options,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppSheet<T>(
    context: context,
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s16),
        SplitListGroup(
          children: [
            for (final option in options)
              SplitListTile(
                title: option.label,
                onTap: () => Navigator.of(context).pop(option.value),
              ),
          ],
        ),
        const SizedBox(height: AppTokens.s16),
        SecondaryButton(
          label: l10n.action_cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
