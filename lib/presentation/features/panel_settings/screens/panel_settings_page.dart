import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/server_repository_impl.dart';
import '../../../../data/dto/setting/api_key_dto.dart';
import '../../../../data/repositories_impl/setting_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/split_list_group.dart';
import 'advanced_settings_pages.dart';
import 'panel_upgrade_page.dart';
import 'script_library_page.dart';
import 'command_library_page.dart';
import 'group_management_page.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../servers/providers/servers_provider.dart';
import '../../../common/states/error_toast.dart';
import '../../../common/formatters/value_labels.dart';

class _PanelSettingsData {
  const _PanelSettingsData(
    this.settings,
    this.core, {
    required this.hasSession,
  });

  final Map<String, dynamic> settings;
  final Map<String, dynamic> core;
  final bool hasSession;

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
  final settings = await repository.searchSettings();
  final core = await repository.searchCoreSettings();
  try {
    core['memo'] = await repository.getMemo();
  } catch (_) {
    // Older panels may not expose the memo endpoint.
  }
  final hasSession = await repository.hasPanelSession();
  return _PanelSettingsData(settings, core, hasSession: hasSession);
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
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SplitListGroup(
                children: [
                  SplitListTile(
                    leading: const Icon(TablerIcons.world_www),
                    title: l10n.panelSettings_openWeb,
                    subtitle: displayValue(context, serverUrl?.toString()),
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
                                key: 'SystemIP',
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
                    trailing: const Icon(TablerIcons.pencil),
                    onTap: () => _changePassword(context, ref, l10n),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.notes),
                    title: l10n.panelSettings_memo,
                    subtitle: data.value('memo').isEmpty
                        ? l10n.panelSettings_memoHint
                        : data.value('memo'),
                    trailing: const Icon(TablerIcons.pencil),
                    onTap: () async {
                      final value = await _editValue(
                        context,
                        title: l10n.panelSettings_memo,
                        initial: data.value('memo'),
                        hint: l10n.panelSettings_memoContentHint,
                        maxLines: 6,
                      );
                      if (value == null || !context.mounted) return;
                      try {
                        final repository = await ref.read(
                          settingRepositoryProvider.future,
                        );
                        await repository.saveMemo(value);
                        ref.invalidate(_panelSettingsProvider);
                        if (!context.mounted) return;
                        AppToast.success(
                          context,
                          l10n.panelSettings_settingUpdated,
                        );
                      } catch (error) {
                        if (!context.mounted) return;
                        showErrorToast(context, error);
                      }
                    },
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
                    trailing: const Icon(TablerIcons.pencil),
                    onTap: () => _changePort(context, ref, l10n, data),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.folder),
                    title: l10n.panelSettings_groupManagement,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const GroupManagementPage(),
                      ),
                    ),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.terminal_2),
                    title: l10n.panelSettings_commandLibrary,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CommandLibraryPage(),
                      ),
                    ),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.file_code),
                    title: l10n.panelSettings_scriptLibrary,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ScriptLibraryPage(),
                      ),
                    ),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.lock_square),
                    title: l10n.panelSettings_panelSsl,
                    subtitle: l10n.panelSettings_panelSslHint,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => _editPanelSsl(context, ref, l10n),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.shield_lock),
                    title: l10n.panelSettings_mfa,
                    subtitle: l10n.panelSettings_mfaHint,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => _manageMfa(context, ref, l10n),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.fingerprint),
                    title: l10n.panelSettings_passkeys,
                    subtitle: l10n.panelSettings_passkeysHint,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => _managePasskeys(context, ref, l10n, serverUrl),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.key),
                    title: l10n.panelSettings_resetExpiredPassword,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => _resetExpiredPassword(context, ref, l10n),
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
                    title: l10n.panelSettings_bindAddress,
                    subtitle: data.value(
                      'bindAddress',
                      fallback: l10n.panelSettings_notSet,
                    ),
                    trailing: const Icon(TablerIcons.pencil),
                    onTap: () => _changeBind(context, ref, l10n, data),
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
              SectionHeader(title: l10n.panelSettings_snapshots),
              SplitListGroup(
                children: [
                  SplitListTile(
                    leading: const Icon(TablerIcons.camera),
                    title: l10n.panelSettings_snapshots,
                    subtitle: l10n.panelSettings_snapshotsHint,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () =>
                        context.push('/s/$serverId/more/settings/snapshots'),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.s24),
              SectionHeader(title: l10n.panelSettings_advancedSettings),
              SplitListGroup(
                children: [
                  SplitListTile(
                    leading: const Icon(TablerIcons.robot),
                    title: l10n.panelMcp_title,
                    subtitle: l10n.panelMcp_subtitle,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => context.push('/s/$serverId/more/settings/mcp'),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.robot),
                    title: l10n.panelSettings_aiSettings,
                    subtitle: l10n.panelSettings_aiSettingsHint,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () =>
                        pushFormPage<void>(context, const AiSettingsPage()),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.terminal_2),
                    title: l10n.panelSettings_terminalAppearance,
                    subtitle: l10n.panelSettings_terminalAppearanceHint,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => pushFormPage<void>(
                      context,
                      const TerminalAppearanceSettingsPage(),
                    ),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.world),
                    title: l10n.panelSettings_proxy,
                    subtitle: l10n.panelSettings_proxyHint,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => pushFormPage<void>(
                      context,
                      const PanelProxySettingsPage(),
                    ),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.download),
                    title: l10n.panelSettings_downloadPreference,
                    subtitle: l10n.panelSettings_downloadPreferenceHint,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => pushFormPage<void>(
                      context,
                      const DownloadPreferenceSettingsPage(),
                    ),
                  ),
                  if (data.hasSession)
                    SplitListTile(
                      leading: const Icon(TablerIcons.certificate),
                      title: l10n.panelSettings_downloadSsl,
                      subtitle: l10n.panelSettings_downloadSslHint,
                      trailing: const Icon(TablerIcons.download),
                      onTap: () async {
                        try {
                          final repository = await ref.read(
                            settingRepositoryProvider.future,
                          );
                          final bytes = await repository.downloadPanelSsl();
                          if (!context.mounted) return;
                          final path = await FilePicker.saveFile(
                            fileName: '1panel.crt',
                            bytes: bytes,
                          );
                          if (path == null || !context.mounted) return;
                          AppToast.success(
                            context,
                            l10n.websites_downloaded(path),
                          );
                        } catch (error) {
                          if (!context.mounted) return;
                          showErrorToast(context, error);
                        }
                      },
                    ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.history),
                    title: l10n.panelSettings_fileHistory,
                    subtitle: l10n.panelSettings_fileHistoryHint,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => pushFormPage<void>(
                      context,
                      const FileHistorySettingsPage(),
                    ),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.terminal_2),
                    title: l10n.panelSettings_localSsh,
                    subtitle: l10n.panelSettings_localSshHint,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => pushFormPage<void>(
                      context,
                      const LocalSshSettingsPage(),
                    ),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.plug),
                    title: l10n.panelSettings_defaultSshConn,
                    subtitle: l10n.panelSettings_defaultSshConnHint,
                    trailing: const Icon(TablerIcons.pencil),
                    onTap: () async {
                      final value = await _editValue(
                        context,
                        title: l10n.panelSettings_defaultSshConn,
                        initial: '',
                        hint: l10n.panelSettings_defaultSshConnPlaceholder,
                      );
                      if (value == null || !context.mounted) return;
                      await _update(
                        context,
                        ref,
                        () => ref
                            .read(settingRepositoryProvider.future)
                            .then(
                              (repo) =>
                                  repo.setSshDefaultConn(defaultConn: value),
                            ),
                        l10n,
                      );
                    },
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.rocket),
                    title: l10n.panelSettings_panelUpgrade,
                    subtitle: l10n.panelSettings_panelUpgradeHint,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () =>
                        pushFormPage<void>(context, const PanelUpgradePage()),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.menu_2),
                    title: l10n.panelSettings_resetMenu,
                    subtitle: l10n.panelSettings_resetMenuHint,
                    trailing: const Icon(TablerIcons.refresh),
                    onTap: () async {
                      final confirmed = await showConfirmSheet(
                        context,
                        title: l10n.panelSettings_resetMenu,
                        message: l10n.panelSettings_resetMenuConfirm,
                        confirmLabel: l10n.action_confirm,
                      );
                      if (!confirmed || !context.mounted) return;
                      await _update(
                        context,
                        ref,
                        () => ref
                            .read(settingRepositoryProvider.future)
                            .then((repo) => repo.resetMenuSetting()),
                        l10n,
                      );
                    },
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.login),
                    title: l10n.panelSettings_panelLogin,
                    subtitle: data.hasSession
                        ? l10n.panelSettings_panelLoggedIn
                        : l10n.panelSettings_panelNotLoggedIn,
                    trailing: Icon(
                      data.hasSession
                          ? TablerIcons.check
                          : TablerIcons.chevron_right,
                      color: data.hasSession ? scheme.primary : null,
                    ),
                    onTap: () async {
                      final loggedIn = await _loginPanel(
                        context,
                        ref,
                        l10n,
                        entrance: data.value('securityEntrance'),
                      );
                      if (loggedIn && context.mounted) {
                        ref.invalidate(_panelSettingsProvider);
                      }
                    },
                  ),
                  if (data.hasSession)
                    SplitListTile(
                      leading: const Icon(TablerIcons.logout),
                      title: l10n.panelSettings_logout,
                      danger: true,
                      onTap: () async {
                        try {
                          final repository = await ref.read(
                            settingRepositoryProvider.future,
                          );
                          await repository.logoutPanel();
                          ref.invalidate(_panelSettingsProvider);
                          if (!context.mounted) return;
                          AppToast.success(context, l10n.action_done);
                        } catch (error) {
                          if (!context.mounted) return;
                          showErrorToast(context, error);
                        }
                      },
                    ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.api_app),
                    title: l10n.panelSettings_apiKeyRow,
                    subtitle: data.enabled('apiInterfaceStatus')
                        ? l10n.panelSettings_enabled
                        : l10n.panelSettings_disabled,
                    trailing: const Icon(TablerIcons.pencil),
                    onTap: () => _generateApiKey(context, ref, l10n),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.key),
                    title: l10n.panelSettings_apiKeyManagement,
                    subtitle: l10n.panelSettings_apiKeyManagementHint,
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => _manageApiKeys(context, ref, l10n),
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.s16,
                    ),
                    secondary: const Icon(TablerIcons.api),
                    title: Text(
                      l10n.panelSettings_apiInterface,
                      style: AppTextStyles.bodyL.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      l10n.panelSettings_apiInterfaceToggleHint,
                      style: AppTextStyles.bodyS.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    value: data.enabled('apiInterfaceStatus'),
                    onChanged: (value) async {
                      if (!await _ensurePanelSession(context, ref, l10n)) {
                        return;
                      }
                      if (!context.mounted) return;
                      try {
                        final repository = await ref.read(
                          settingRepositoryProvider.future,
                        );
                        final settings = await repository.searchCoreSettings();
                        final apiKey =
                            (settings['apiKey'] ?? data.value('apiKey'))
                                .toString();
                        if (apiKey.isEmpty) {
                          if (!context.mounted) return;
                          AppToast.error(
                            context,
                            l10n.panelSettings_apiConfigUnavailable,
                          );
                          return;
                        }
                        await repository.updateApiConfig({
                          'apiInterfaceStatus': value ? 'Enable' : 'Disable',
                          'apiKey': apiKey,
                        });
                        ref.invalidate(_panelSettingsProvider);
                        if (!context.mounted) return;
                        AppToast.success(
                          context,
                          l10n.panelSettings_settingUpdated,
                        );
                      } catch (error) {
                        if (!context.mounted) return;
                        showErrorToast(context, error);
                      }
                    },
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.key),
                    title: l10n.panelSettings_credentials,
                    subtitle: data.value('apiKey').isEmpty
                        ? l10n.panelSettings_localApiKey
                        : '••••••••',
                    trailing: const Icon(TablerIcons.refresh),
                    onTap: () => _generateApiKey(context, ref, l10n),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _syncLocalServer(
    WidgetRef ref, {
    int? port,
    bool? isHttps,
    String? host,
  }) async {
    final repository = ref.read(serverRepositoryProvider);
    final server = await repository.find(serverId);
    if (server == null) return;
    var changed = false;
    if (port != null && server.port != port) {
      server.port = port;
      changed = true;
    }
    if (isHttps != null && server.isHttps != isHttps) {
      server.isHttps = isHttps;
      changed = true;
    }
    if (host != null &&
        host.isNotEmpty &&
        host != '0.0.0.0' &&
        host != '::' &&
        server.host != host) {
      server.host = host;
      changed = true;
    }
    if (!changed) return;
    server.updatedAt = DateTime.now();
    await repository.update(server);
    ref.invalidate(dioClientProvider(serverId));
    ref.invalidate(serversProvider);
    ref.invalidate(serverByIdProvider(serverId));
  }

  String _loginLanguage(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return code == 'zh' ? 'zh' : 'en';
  }

  bool _isCaptchaError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('captcha') || text.contains('验证码');
  }

  Future<String?> _promptMfa(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final code = TextEditingController();
    final value = await pushFormPage<String>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.panelSettings_mfa,
          saveLabel: l10n.panelSettings_login,
          onSave: () async {
            final text = code.text.trim();
            if (text.isEmpty) return;
            Navigator.of(pageContext).pop(text);
          },
          children: [
            AppTextField(
              controller: code,
              label: l10n.panelSettings_mfaCode,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
    code.dispose();
    return value;
  }

  Future<({String code, String captchaId})?> _promptCaptcha(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, dynamic> captcha,
  ) async {
    final code = TextEditingController();
    final raw = captcha['imagePath']?.toString() ?? '';
    Uint8List? imageBytes;
    if (raw.startsWith('data:')) {
      final comma = raw.indexOf(',');
      if (comma > 0) {
        try {
          imageBytes = base64Decode(raw.substring(comma + 1));
        } catch (_) {
          imageBytes = null;
        }
      }
    }
    final value = await pushFormPage<String>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.panelSettings_captcha,
          saveLabel: l10n.panelSettings_login,
          onSave: () async {
            final text = code.text.trim();
            if (text.isEmpty) return;
            Navigator.of(pageContext).pop(text);
          },
          children: [
            if (imageBytes != null)
              Center(child: Image.memory(imageBytes, height: 56)),
            const SizedBox(height: AppTokens.s16),
            AppTextField(
              controller: code,
              label: l10n.panelSettings_captcha,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
    code.dispose();
    final captchaId = captcha['captchaID']?.toString() ?? '';
    if (value == null) return null;
    return (code: value, captchaId: captchaId);
  }

  Future<bool> _completeLogin(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n, {
    required String name,
    required String password,
    String captcha = '',
    String captchaId = '',
    String entrance = '',
  }) async {
    final language = _loginLanguage(context);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      var result = await repository.loginPanel(
        name: name,
        password: password,
        language: language,
        captcha: captcha,
        captchaId: captchaId,
        entrance: entrance,
      );
      if (result.needsMfa) {
        if (!context.mounted) return false;
        final code = await _promptMfa(context, l10n);
        if (code == null) return false;
        result = await repository.loginPanelMfa(
          sessionId: result.mfaSession,
          code: code,
        );
      }
      if (result.session == null) {
        if (!context.mounted) return false;
        AppToast.error(context, l10n.panelSettings_loginRequired);
        return false;
      }
      if (!context.mounted) return false;
      AppToast.success(context, l10n.action_done);
      return true;
    } catch (error) {
      if (!context.mounted) return false;
      if (!_isCaptchaError(error)) {
        showErrorToast(context, error);
        return false;
      }
      final repository = await ref.read(settingRepositoryProvider.future);
      final captcha = await repository.loadLoginCaptcha();
      if (!context.mounted) return false;
      final input = await _promptCaptcha(context, l10n, captcha);
      if (input == null) return false;
      try {
        var result = await repository.loginPanel(
          name: name,
          password: password,
          language: language,
          captcha: input.code,
          captchaId: input.captchaId,
          entrance: entrance,
        );
        if (result.needsMfa) {
          if (!context.mounted) return false;
          final code = await _promptMfa(context, l10n);
          if (code == null) return false;
          result = await repository.loginPanelMfa(
            sessionId: result.mfaSession,
            code: code,
          );
        }
        if (result.session == null) {
          if (!context.mounted) return false;
          AppToast.error(context, l10n.panelSettings_loginRequired);
          return false;
        }
        if (!context.mounted) return false;
        AppToast.success(context, l10n.action_done);
        return true;
      } catch (retryError) {
        if (!context.mounted) return false;
        showErrorToast(context, retryError);
        return false;
      }
    }
  }

  Future<bool> _loginPanel(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n, {
    String entrance = '',
  }) async {
    final name = TextEditingController();
    final password = TextEditingController();
    final saved = await pushFormPage<List<String>>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.panelSettings_panelLogin,
          saveLabel: l10n.panelSettings_login,
          onSave: () async {
            final nameValue = name.text.trim();
            final passwordValue = password.text;
            if (nameValue.isEmpty || passwordValue.isEmpty) return;
            Navigator.of(pageContext).pop([nameValue, passwordValue]);
          },
          children: [
            AppTextField(controller: name, label: l10n.panelSettings_username),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: password,
              label: l10n.panelSettings_password,
              obscure: true,
            ),
          ],
        ),
      ),
    );
    final nameValue = name.text.trim();
    final passwordValue = password.text;
    name.dispose();
    password.dispose();
    if (saved == null || !context.mounted) return false;
    return _completeLogin(
      context,
      ref,
      l10n,
      name: nameValue,
      password: passwordValue,
      entrance: entrance,
    );
  }

  Future<bool> _ensurePanelSession(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final repository = await ref.read(settingRepositoryProvider.future);
    if (await repository.hasPanelSession()) return true;
    if (!context.mounted) return false;
    AppToast.warning(context, l10n.panelSettings_loginRequired);
    final loggedIn = await _loginPanel(
      context,
      ref,
      l10n,
      entrance: data.value('securityEntrance'),
    );
    if (loggedIn) ref.invalidate(_panelSettingsProvider);
    return loggedIn;
  }

  Future<void> _editPanelSsl(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final cert = TextEditingController();
    final key = TextEditingController();
    final domain = TextEditingController();
    final sslId = TextEditingController();
    String ssl = 'Enable';
    String sslType = 'import-paste';
    final saved = await pushFormPage<bool>(
      context,
      StatefulBuilder(
        builder: (pageContext, setState) => SimpleFormPage(
          title: l10n.panelSettings_panelSsl,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            Text(
              l10n.panelSettings_panelSslWarning,
              style: AppTextStyles.bodyS.copyWith(
                color: pageContext.appColors.warning,
              ),
            ),
            const SizedBox(height: AppTokens.s16),
            DropdownButtonFormField<String>(
              initialValue: ssl,
              decoration: InputDecoration(
                labelText: l10n.panelSettings_panelSslMode,
              ),
              items: [
                DropdownMenuItem(
                  value: 'Enable',
                  child: Text(l10n.panelSettings_sslModeEnable),
                ),
                DropdownMenuItem(
                  value: 'Disable',
                  child: Text(l10n.panelSettings_sslModeDisable),
                ),
                DropdownMenuItem(
                  value: 'Mux',
                  child: Text(l10n.panelSettings_sslModeMux),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => ssl = value);
              },
            ),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: sslType,
              decoration: InputDecoration(
                labelText: l10n.panelSettings_panelSslType,
              ),
              items: [
                DropdownMenuItem(
                  value: 'import-paste',
                  child: Text(l10n.panelSettings_sslPaste),
                ),
                DropdownMenuItem(
                  value: 'select',
                  child: Text(l10n.panelSettings_sslSelectExisting),
                ),
                DropdownMenuItem(
                  value: 'self',
                  child: Text(l10n.panelSettings_sslSelfSigned),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => sslType = value);
              },
            ),
            if (sslType == 'import-paste') ...[
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: cert,
                label: l10n.websites_certificatePem,
                maxLines: 6,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: key,
                label: l10n.websites_privateKeyPem,
                maxLines: 6,
              ),
            ],
            if (sslType == 'select') ...[
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: sslId,
                label: l10n.websites_sslId,
                keyboardType: TextInputType.number,
              ),
            ],
            if (sslType == 'self') ...[
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: domain,
                label: l10n.websites_domain,
                hint: 'panel.example.com',
              ),
            ],
          ],
        ),
      ),
    );
    final certValue = cert.text.trim();
    final keyValue = key.text.trim();
    final domainValue = domain.text.trim();
    final sslIdValue = int.tryParse(sslId.text.trim()) ?? 0;
    cert.dispose();
    key.dispose();
    domain.dispose();
    sslId.dispose();
    if (saved != true || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.updateSSL({
        'ssl': ssl,
        'sslType': sslType,
        if (sslType == 'import-paste') 'cert': certValue,
        if (sslType == 'import-paste') 'key': keyValue,
        if (sslType == 'select') 'sslID': sslIdValue,
        if (sslType == 'self') 'domain': domainValue,
      });
      await _syncLocalServer(
        ref,
        isHttps: ssl == 'Enable' || ssl == 'Mux',
        host: sslType == 'self' ? domainValue : null,
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.panelSettings_settingUpdated);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _manageApiKeys(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    if (!await _ensurePanelSession(context, ref, l10n)) return;
    if (!context.mounted) return;
    final repository = await ref.read(settingRepositoryProvider.future);
    List<ApiKeyItemDto> items;
    try {
      final page = await repository.searchApiKeys(pageSize: 100);
      items = page.items
          .where((item) => item.kind.toLowerCase() != 'legacy')
          .toList(growable: true);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
      return;
    }
    if (!context.mounted) return;

    await showAppSheet<void>(
      context: context,
      maxHeightFactor: 0.92,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Future<void> reload() async {
            try {
              final page = await repository.searchApiKeys(pageSize: 100);
              if (!sheetContext.mounted) return;
              setSheetState(() {
                items = page.items
                    .where((item) => item.kind.toLowerCase() != 'legacy')
                    .toList(growable: true);
              });
            } catch (error) {
              if (sheetContext.mounted) showErrorToast(sheetContext, error);
            }
          }

          Future<void> create() async {
            final created = await _createApiKey(sheetContext, ref, l10n);
            if (created && sheetContext.mounted) await reload();
          }

          return SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * 0.78,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.panelSettings_apiKeyManagement,
                        style: AppTextStyles.titleL,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.action_close,
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(TablerIcons.x),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s8),
                PrimaryButton(
                  label: l10n.panelSettings_apiKeyCreate,
                  icon: TablerIcons.plus,
                  onPressed: create,
                ),
                const SizedBox(height: AppTokens.s12),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            l10n.panelSettings_apiKeyEmpty,
                            style: AppTextStyles.bodyM.copyWith(
                              color: sheetContext.scheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppTokens.s8),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _ApiKeyTile(
                              item: item,
                              onTap: () async {
                                await _showApiKeyActions(
                                  sheetContext,
                                  ref,
                                  l10n,
                                  repository,
                                  item,
                                );
                                await reload();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _createApiKey(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final name = TextEditingController();
    final description = TextEditingController();
    final ipWhiteList = TextEditingController();
    final trustedProxies = TextEditingController();
    final validity = TextEditingController(text: '120');
    final saved = await pushFormPage<List<String>>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.panelSettings_apiKeyCreate,
          saveLabel: l10n.action_create,
          onSave: () async {
            if (name.text.trim().isEmpty) return;
            Navigator.of(pageContext).pop([
              name.text.trim(),
              description.text.trim(),
              ipWhiteList.text.trim(),
              trustedProxies.text.trim(),
              validity.text.trim(),
            ]);
          },
          children: [
            AppTextField(
              controller: name,
              label: l10n.panelSettings_apiKeyName,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: description,
              label: l10n.panelSettings_apiKeyDescription,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: ipWhiteList,
              label: l10n.panelSettings_apiKeyIpWhiteList,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: trustedProxies,
              label: l10n.panelSettings_apiKeyTrustedProxies,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: validity,
              label: l10n.panelSettings_apiKeyValidity,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
    final values = saved;
    name.dispose();
    description.dispose();
    ipWhiteList.dispose();
    trustedProxies.dispose();
    validity.dispose();
    if (values == null || !context.mounted) return false;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final created = await repository.createApiKey(
        requestId: const Uuid().v4(),
        name: values[0],
        description: values[1],
        ipWhiteList: values[2],
        apiTrustedProxies: values[3],
        apiKeyValidityTime: int.tryParse(values[4]) ?? 120,
      );
      if (!context.mounted) return false;
      if (created.apiKey.isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: created.apiKey));
      }
      if (!context.mounted) return false;
      AppToast.success(context, l10n.panelSettings_apiKeyCreated);
      return true;
    } catch (error) {
      if (!context.mounted) return false;
      showErrorToast(context, error);
      return false;
    }
  }

  Future<void> _editApiKey(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    dynamic repository,
    ApiKeyItemDto item,
  ) async {
    final name = TextEditingController(text: item.name);
    final description = TextEditingController(text: item.description);
    final ipWhiteList = TextEditingController(text: item.ipWhiteList);
    final trustedProxies = TextEditingController(text: item.apiTrustedProxies);
    final validity = TextEditingController(
      text: '${item.apiKeyValidityTime == 0 ? 120 : item.apiKeyValidityTime}',
    );
    final saved = await pushFormPage<List<String>>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.action_edit,
          saveLabel: l10n.action_save,
          onSave: () async {
            if (name.text.trim().isEmpty) return;
            Navigator.of(pageContext).pop([
              name.text.trim(),
              description.text.trim(),
              ipWhiteList.text.trim(),
              trustedProxies.text.trim(),
              validity.text.trim(),
            ]);
          },
          children: [
            AppTextField(
              controller: name,
              label: l10n.panelSettings_apiKeyName,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: description,
              label: l10n.panelSettings_apiKeyDescription,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: ipWhiteList,
              label: l10n.panelSettings_apiKeyIpWhiteList,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: trustedProxies,
              label: l10n.panelSettings_apiKeyTrustedProxies,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: validity,
              label: l10n.panelSettings_apiKeyValidity,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
    final values = saved;
    name.dispose();
    description.dispose();
    ipWhiteList.dispose();
    trustedProxies.dispose();
    validity.dispose();
    if (values == null || !context.mounted) return;
    try {
      await repository.updateApiKey(
        id: item.id,
        revision: item.revision,
        name: values[0],
        description: values[1],
        ipWhiteList: values[2],
        apiTrustedProxies: values[3],
        apiKeyValidityTime: int.tryParse(values[4]) ?? 120,
        expiresAt: item.expiresAt,
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showApiKeyActions(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    dynamic repository,
    ApiKeyItemDto item,
  ) async {
    final isEnabled = item.status.toLowerCase() == 'enable';
    final revoked = item.status.toLowerCase() == 'revoked';
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: AppTextStyles.titleL),
          if (item.keyHint.isNotEmpty) ...[
            const SizedBox(height: AppTokens.s4),
            Text(
              item.keyHint,
              style: AppTextStyles.bodyS.copyWith(
                color: sheetContext.scheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
          ],
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.edit),
                title: l10n.action_edit,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _editApiKey(context, ref, l10n, repository, item);
                },
              ),
              if (!revoked)
                SplitListTile(
                  leading: const Icon(TablerIcons.eye),
                  title: l10n.panelSettings_apiKeyReveal,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    try {
                      final key = await repository.revealApiKey(
                        id: item.id,
                        revision: item.revision,
                      );
                      await Clipboard.setData(ClipboardData(text: key));
                      if (!context.mounted) return;
                      AppToast.success(
                        context,
                        l10n.panelSettings_apiKeyCreated,
                      );
                    } catch (error) {
                      if (!context.mounted) return;
                      showErrorToast(context, error);
                    }
                  },
                ),
              if (!revoked)
                SplitListTile(
                  leading: Icon(
                    isEnabled ? TablerIcons.ban : TablerIcons.check,
                  ),
                  title: isEnabled
                      ? l10n.panelSettings_apiKeyDisable
                      : l10n.panelSettings_apiKeyEnable,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    try {
                      await repository.setApiKeyStatus(
                        id: item.id,
                        revision: item.revision,
                        status: isEnabled ? 'Disable' : 'Enable',
                      );
                      if (!context.mounted) return;
                      AppToast.success(context, l10n.action_done);
                    } catch (error) {
                      if (!context.mounted) return;
                      showErrorToast(context, error);
                    }
                  },
                ),
              if (!revoked)
                SplitListTile(
                  leading: const Icon(TablerIcons.shield_x),
                  title: l10n.panelSettings_apiKeyRevoke,
                  danger: true,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final confirmed = await showConfirmSheet(
                      context,
                      title: l10n.panelSettings_apiKeyRevoke,
                      message: l10n.panelSettings_apiKeyRevokeConfirm,
                      confirmLabel: l10n.panelSettings_apiKeyRevoke,
                      danger: true,
                    );
                    if (!confirmed) return;
                    try {
                      await repository.revokeApiKey(
                        id: item.id,
                        revision: item.revision,
                      );
                      if (!context.mounted) return;
                      AppToast.success(context, l10n.action_done);
                    } catch (error) {
                      if (!context.mounted) return;
                      showErrorToast(context, error);
                    }
                  },
                ),
              SplitListTile(
                leading: const Icon(TablerIcons.trash),
                title: l10n.panelSettings_apiKeyDelete,
                danger: true,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final confirmed = await showConfirmSheet(
                    context,
                    title: l10n.panelSettings_apiKeyDelete,
                    message: l10n.panelSettings_apiKeyDeleteConfirm,
                    confirmLabel: l10n.panelSettings_apiKeyDelete,
                    danger: true,
                  );
                  if (!confirmed) return;
                  try {
                    await repository.deleteApiKey(
                      id: item.id,
                      revision: item.revision,
                    );
                    if (!context.mounted) return;
                    AppToast.success(context, l10n.action_done);
                  } catch (error) {
                    if (!context.mounted) return;
                    showErrorToast(context, error);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
        ],
      ),
    );
  }

  Future<void> _manageMfa(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final action = await showSelectionMenu<String>(
      context,
      title: l10n.panelSettings_mfa,
      options: [
        SelectionOption(
          label: l10n.panelSettings_bindMfa,
          value: 'bind',
          icon: TablerIcons.shield_check,
        ),
        SelectionOption(
          label: l10n.panelSettings_closeMfa,
          value: 'close',
          icon: TablerIcons.shield_off,
        ),
      ],
    );
    if (action == null || !context.mounted) return;
    if (action == 'bind') {
      await _bindMfa(context, ref, l10n);
      return;
    }
    if (!await _ensurePanelSession(context, ref, l10n)) return;
    if (!context.mounted) return;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.panelSettings_closeMfa,
      message: l10n.action_confirm,
      confirmLabel: l10n.action_confirm,
      danger: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.closeMFA();
      if (!context.mounted) return;
      AppToast.success(context, l10n.panelSettings_mfaClosed);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _resetExpiredPassword(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    if (!await _ensurePanelSession(context, ref, l10n)) return;
    if (!context.mounted) return;
    final oldPassword = TextEditingController();
    final newPassword = TextEditingController();
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.panelSettings_resetExpiredPassword,
          saveLabel: l10n.action_save,
          onSave: () async {
            final oldValue = oldPassword.text;
            final newValue = newPassword.text;
            if (oldValue.isEmpty || newValue.isEmpty) return;
            Navigator.of(pageContext).pop(true);
          },
          children: [
            AppTextField(
              controller: oldPassword,
              label: l10n.panelSettings_oldPassword,
              obscure: true,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: newPassword,
              label: l10n.panelSettings_newPassword,
              obscure: true,
            ),
          ],
        ),
      ),
    );
    final oldValue = oldPassword.text;
    final newValue = newPassword.text;
    oldPassword.dispose();
    newPassword.dispose();
    if (saved != true || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.resetExpiredPassword(
        oldPassword: oldValue,
        newPassword: newValue,
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.panelSettings_passwordReset);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _bindMfa(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    if (!await _ensurePanelSession(context, ref, l10n)) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final data = await repository.loadMFA(title: 'OneDash', interval: 30);
      final secret = '${data['secret'] ?? ''}';
      if (!context.mounted) return;
      final controller = TextEditingController();
      final saved = await pushFormPage<bool>(
        context,
        Builder(
          builder: (pageContext) => SimpleFormPage(
            title: l10n.panelSettings_mfa,
            saveLabel: l10n.panelSettings_bindMfa,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              SelectableText(
                secret.isEmpty ? l10n.state_empty : secret,
                style: AppTextStyles.bodyM.copyWith(fontFamily: 'monospace'),
              ),
              const SizedBox(height: AppTokens.s16),
              AppTextField(
                controller: controller,
                label: l10n.panelSettings_mfaCode,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      );
      final code = controller.text.trim();
      controller.dispose();
      if (saved != true || code.isEmpty || !context.mounted) return;
      await repository.bindMFA(secret: secret, code: code, interval: 30);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _managePasskeys(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Uri? serverUrl,
  ) async {
    if (!await _ensurePanelSession(context, ref, l10n)) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final items = await repository.listPasskeys();
      if (!context.mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.panelSettings_passkeys,
                    style: AppTextStyles.titleL,
                  ),
                ),
                if (serverUrl != null)
                  TextButton.icon(
                    onPressed: () => launchUrl(
                      serverUrl,
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(TablerIcons.external_link),
                    label: Text(l10n.panelSettings_registerPasskey),
                  ),
              ],
            ),
            const SizedBox(height: AppTokens.s8),
            Text(
              l10n.panelSettings_registerPasskeyHint,
              style: AppTextStyles.bodyS.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.s16),
            if (items.isEmpty)
              Text(l10n.panelSettings_noPasskeys)
            else
              SplitListGroup(
                children: [
                  for (final item in items)
                    SplitListTile(
                      leading: const Icon(TablerIcons.fingerprint),
                      title:
                          '${item['name'] ?? item['credentialName'] ?? item['id'] ?? ''}',
                      trailing: IconButton(
                        tooltip: l10n.action_delete,
                        icon: const Icon(TablerIcons.trash),
                        onPressed: () async {
                          final id = item['id'];
                          if (id == null) return;
                          await repository.deletePasskey('$id');
                          if (!sheetContext.mounted) return;
                          Navigator.of(sheetContext).pop();
                          AppToast.success(context, l10n.action_done);
                        },
                      ),
                    ),
                ],
              ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _changePassword(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    if (!await _ensurePanelSession(context, ref, l10n)) return;
    if (!context.mounted) return;
    final oldPassword = TextEditingController();
    final newPassword = TextEditingController();
    final confirm = TextEditingController();
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.panelSettings_panelLoginPassword,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(
              controller: oldPassword,
              label: l10n.panelSettings_oldPassword,
              obscure: true,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: newPassword,
              label: l10n.panelSettings_newPassword,
              obscure: true,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: confirm,
              label: l10n.panelSettings_confirmPassword,
              obscure: true,
            ),
          ],
        ),
      ),
    );
    final oldValue = oldPassword.text;
    final newValue = newPassword.text;
    final confirmValue = confirm.text;
    oldPassword.dispose();
    newPassword.dispose();
    confirm.dispose();
    if (saved != true || !context.mounted) return;
    if (newValue.isEmpty || newValue != confirmValue) {
      AppToast.warning(context, l10n.panelSettings_passwordMismatch);
      return;
    }
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.updatePassword(
        oldPassword: oldValue,
        newPassword: newValue,
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.panelSettings_settingUpdated);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _changePort(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    _PanelSettingsData data,
  ) async {
    final controller = TextEditingController(text: data.value('serverPort'));
    final value = await pushFormPage<int>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.panelSettings_panelPort,
          onSave: () async {
            final port = int.tryParse(controller.text.trim());
            if (port == null) return;
            Navigator.of(pageContext).pop(port);
          },
          children: [
            Text(
              l10n.panelSettings_portChangeWarning,
              style: AppTextStyles.bodyS.copyWith(
                color: pageContext.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.s16),
            AppTextField(
              controller: controller,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (value == null || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.updatePort(value);
      await _syncLocalServer(ref, port: value);
      if (!context.mounted) return;
      AppToast.success(context, l10n.panelSettings_portChanged(value));
      ref.invalidate(_panelSettingsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _changeBind(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    _PanelSettingsData data,
  ) async {
    final controller = TextEditingController(text: data.value('bindAddress'));
    List<String> interfaces = const [];
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      interfaces = await repository.loadInterfaceAddr();
    } catch (_) {
      interfaces = const [];
    }
    if (!context.mounted) return;
    final value = await pushFormPage<String>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.panelSettings_bindAddress,
          onSave: () async =>
              Navigator.of(pageContext).pop(controller.text.trim()),
          children: [
            if (interfaces.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.panelSettings_bindAddress,
                ),
                items: [
                  for (final address in interfaces)
                    DropdownMenuItem(value: address, child: Text(address)),
                ],
                onChanged: (address) {
                  if (address != null) controller.text = address;
                },
              ),
              const SizedBox(height: AppTokens.s12),
            ],
            AppTextField(controller: controller, hint: 'panel.example.com'),
          ],
        ),
      ),
    );
    controller.dispose();
    if (value == null || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.updateBindInfo(
        ipv6: data.value('ipv6'),
        bindAddress: value,
      );
      await _syncLocalServer(ref, host: value);
      if (!context.mounted) return;
      AppToast.success(context, l10n.panelSettings_settingUpdated);
      ref.invalidate(_panelSettingsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _generateApiKey(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    if (!await _ensurePanelSession(context, ref, l10n)) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final key = await repository.generateApiKey();
      if (!context.mounted) return;
      await Clipboard.setData(ClipboardData(text: key));
      if (!context.mounted) return;
      AppToast.success(context, l10n.panelSettings_apiKeyCopied);
      ref.invalidate(_panelSettingsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  String _languageLabel(AppLocalizations l10n, String code) {
    return switch (code) {
      'zh' => l10n.panelSettings_languageZh,
      'zh-Hant' => l10n.panelSettings_languageZhHant,
      'ja' => l10n.panelSettings_languageJa,
      'ms' => l10n.panelSettings_languageMs,
      'pt-BR' => l10n.panelSettings_languagePtBr,
      _ => l10n.panelSettings_languageEn,
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
        (value: 'en', label: l10n.panelSettings_languageEn),
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
  int maxLines = 1,
}) {
  return pushFormPage<String>(
    context,
    _ValueEditorSheet(
      title: title,
      initial: initial,
      hint: hint,
      description: description,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
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
    this.maxLines = 1,
  });

  final String title;
  final String initial;
  final String? hint;
  final String? description;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

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
    final scheme = context.scheme;
    return SimpleFormPage(
      title: widget.title,
      onSave: () async {
        final value = _controller.text.trim();
        if (!context.mounted) return;
        Navigator.of(context).pop(value.isEmpty ? null : value);
      },
      children: [
        if (widget.description != null) ...[
          Text(
            widget.description!,
            style: AppTextStyles.bodyS.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppTokens.s16),
        ],
        TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.maxLines,
          decoration: InputDecoration(hintText: widget.hint),
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

class _ApiKeyTile extends StatelessWidget {
  const _ApiKeyTile({required this.item, required this.onTap});

  final ApiKeyItemDto item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TonalCard(
      onTap: onTap,
      child: Row(
        children: [
          const Icon(TablerIcons.key),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.isEmpty ? item.id : item.name,
                  style: AppTextStyles.titleS,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  [
                    if (item.keyHint.isNotEmpty) item.keyHint,
                    item.status,
                    if (item.expiresAt != null)
                      '${l10n.panelSettings_apiKeyExpires}: '
                          '${item.expiresAt!.toLocal().toString().split(' ').first}',
                  ].join(' · '),
                  style: AppTextStyles.caption.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(TablerIcons.chevron_right),
        ],
      ),
    );
  }
}
