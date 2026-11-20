import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/setting_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

String _enabledValue(bool value) => value ? 'Enable' : 'Disable';

bool _isEnabled(Object? value) {
  final text = value?.toString().toLowerCase() ?? '';
  return text == 'enable' || text == 'enabled' || text == 'true';
}

class AiSettingsPage extends ConsumerStatefulWidget {
  const AiSettingsPage({super.key});

  @override
  ConsumerState<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends ConsumerState<AiSettingsPage> {
  bool _loading = true;
  bool _loadFailed = false;
  bool _saving = false;
  bool _terminalEnabled = false;
  bool _fileEnabled = false;
  String _prefix = '@ai';
  final _terminalAccount = TextEditingController();
  final _terminalRiskCommands = TextEditingController();
  final _fileAccount = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _terminalAccount.dispose();
    _terminalRiskCommands.dispose();
    _fileAccount.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loadFailed = false);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final results = await Future.wait([
        repository.getTerminalAiSetting(),
        repository.getFileAiSetting(),
      ]);
      if (!mounted) return;
      final terminal = results[0];
      final file = results[1];
      setState(() {
        _terminalEnabled = _isEnabled(terminal['aiStatus']);
        final prefix = terminal['aiPrefix']?.toString() ?? '';
        _prefix = const {'@ai', '#ai', '/ai'}.contains(prefix) ? prefix : '@ai';
        _terminalAccount.text = terminal['aiAccountId']?.toString() ?? '';
        _terminalRiskCommands.text =
            terminal['aiRiskCommands']?.toString() ?? '';
        _fileEnabled = _isEnabled(file['aiStatus']);
        _fileAccount.text = file['aiAccountId']?.toString() ?? '';
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
    setState(() => _saving = true);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.updateTerminalAiSetting(
        aiStatus: _enabledValue(_terminalEnabled),
        aiPrefix: _prefix,
        aiAccountId: _terminalAccount.text.trim(),
        aiRiskCommands: _terminalRiskCommands.text,
      );
      await repository.updateFileAiSetting(
        aiStatus: _enabledValue(_fileEnabled),
        aiAccountId: _fileAccount.text.trim(),
      );
      if (!mounted) return;
      AppToast.success(
        context,
        AppLocalizations.of(context).panelSettings_settingUpdated,
      );
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
        appBar: AppBarLarge(title: l10n.panelSettings_aiSettings),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadFailed) {
      return Scaffold(
        appBar: AppBarLarge(title: l10n.panelSettings_aiSettings),
        body: EmptyState(
          icon: TablerIcons.alert_triangle,
          title: l10n.panelSettings_loadFailed,
          actionLabel: l10n.action_retry,
          onAction: _load,
        ),
      );
    }
    return SimpleFormPage(
      title: l10n.panelSettings_aiSettings,
      saving: _saving,
      onSave: _save,
      children: [
        SectionHeader(title: l10n.panelSettings_terminalAi),
        TonalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.panelSettings_aiEnabled),
                value: _terminalEnabled,
                onChanged: (value) => setState(() => _terminalEnabled = value),
              ),
              DropdownButtonFormField<String>(
                initialValue: _prefix,
                decoration: InputDecoration(
                  labelText: l10n.panelSettings_aiPrefix,
                ),
                items: const [
                  DropdownMenuItem(value: '@ai', child: Text('@ai')),
                  DropdownMenuItem(value: '#ai', child: Text('#ai')),
                  DropdownMenuItem(value: '/ai', child: Text('/ai')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _prefix = value);
                },
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _terminalAccount,
                label: l10n.panelSettings_aiAccount,
                hint: l10n.panelSettings_aiAccountHint,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _terminalRiskCommands,
                label: l10n.panelSettings_aiRiskCommands,
                hint: l10n.panelSettings_aiRiskCommandsHint,
                maxLines: 5,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.s24),
        SectionHeader(title: l10n.panelSettings_fileAi),
        TonalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.panelSettings_aiEnabled),
                value: _fileEnabled,
                onChanged: (value) => setState(() => _fileEnabled = value),
              ),
              AppTextField(
                controller: _fileAccount,
                label: l10n.panelSettings_aiAccount,
                hint: l10n.panelSettings_aiAccountHint,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PanelProxySettingsPage extends ConsumerStatefulWidget {
  const PanelProxySettingsPage({super.key});

  @override
  ConsumerState<PanelProxySettingsPage> createState() =>
      _PanelProxySettingsPageState();
}

class _PanelProxySettingsPageState
    extends ConsumerState<PanelProxySettingsPage> {
  bool _loading = true;
  bool _loadFailed = false;
  bool _saving = false;
  String _type = 'http';
  bool _docker = false;
  bool _restartDocker = false;
  final _url = TextEditingController();
  final _port = TextEditingController();
  final _user = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _url.dispose();
    _port.dispose();
    _user.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loadFailed = false);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final data = await repository.searchCoreSettings();
      if (!mounted) return;
      final type = '${data['proxyType'] ?? ''}';
      setState(() {
        _type = const {'http', 'https', 'socks5', 'close'}.contains(type)
            ? type
            : 'http';
        _url.text = '${data['proxyUrl'] ?? ''}'.replaceFirst(
          RegExp(r'^(https?|socks5)://'),
          '',
        );
        _port.text = '${data['proxyPort'] ?? ''}';
        _user.text = '${data['proxyUser'] ?? ''}';
        _docker = _isEnabled(data['proxyDocker']);
        _restartDocker = _isEnabled(data['withDockerRestart']);
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
    final url = _url.text.trim();
    final port = _port.text.trim();
    if (_type != 'close' && (url.isEmpty || port.isEmpty)) {
      AppToast.warning(context, l10n.panelSettings_proxyRequired);
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.updatePanelProxy(
        proxyUrl: _type == 'close' ? '' : url,
        proxyType: _type,
        proxyPort: _type == 'close' ? '' : port,
        proxyUser: _user.text.trim(),
        proxyPasswd: _password.text,
        proxyDocker: _docker,
        withDockerRestart: _restartDocker,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.panelSettings_settingUpdated);
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
        appBar: AppBarLarge(title: l10n.panelSettings_proxy),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadFailed) {
      return Scaffold(
        appBar: AppBarLarge(title: l10n.panelSettings_proxy),
        body: EmptyState(
          icon: TablerIcons.alert_triangle,
          title: l10n.panelSettings_loadFailed,
          actionLabel: l10n.action_retry,
          onAction: _load,
        ),
      );
    }
    final enabled = _type != 'close';
    return SimpleFormPage(
      title: l10n.panelSettings_proxy,
      saving: _saving,
      onSave: _save,
      children: [
        SectionHeader(title: l10n.panelSettings_proxy),
        TonalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: l10n.panelSettings_proxyType,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'http',
                    child: Text(l10n.panelSettings_proxyHttp),
                  ),
                  DropdownMenuItem(
                    value: 'https',
                    child: Text(l10n.panelSettings_proxyHttps),
                  ),
                  DropdownMenuItem(
                    value: 'socks5',
                    child: Text(l10n.panelSettings_proxySocks5),
                  ),
                  DropdownMenuItem(
                    value: 'close',
                    child: Text(l10n.panelSettings_proxyClose),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
              ),
              if (enabled) ...[
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: _url,
                  label: l10n.panelSettings_proxyUrl,
                  hint: l10n.panelSettings_proxyUrlHint,
                ),
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: _port,
                  label: l10n.panelSettings_proxyPort,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: _user,
                  label: l10n.panelSettings_proxyUser,
                ),
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: _password,
                  label: l10n.panelSettings_proxyPassword,
                  hint: l10n.panelSettings_proxyPasswordHint,
                  obscure: true,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.panelSettings_proxyDocker),
                  value: _docker,
                  onChanged: (value) => setState(() => _docker = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.panelSettings_proxyRestartDocker),
                  value: _restartDocker,
                  onChanged: (value) => setState(() => _restartDocker = value),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class DownloadPreferenceSettingsPage extends ConsumerStatefulWidget {
  const DownloadPreferenceSettingsPage({super.key});

  @override
  ConsumerState<DownloadPreferenceSettingsPage> createState() =>
      _DownloadPreferenceSettingsPageState();
}

class _DownloadPreferenceSettingsPageState
    extends ConsumerState<DownloadPreferenceSettingsPage> {
  bool _loading = true;
  bool _loadFailed = false;
  bool _saving = false;
  bool _useServerFilename = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loadFailed = false);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final value = await repository.getFileDownloadPreference();
      if (!mounted) return;
      setState(() => _useServerFilename = value);
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
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.updateFileDownloadPreference(
        useServerFilename: _useServerFilename,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.panelSettings_settingUpdated);
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
        appBar: AppBarLarge(title: l10n.panelSettings_downloadPreference),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadFailed) {
      return Scaffold(
        appBar: AppBarLarge(title: l10n.panelSettings_downloadPreference),
        body: EmptyState(
          icon: TablerIcons.alert_triangle,
          title: l10n.panelSettings_loadFailed,
          actionLabel: l10n.action_retry,
          onAction: _load,
        ),
      );
    }
    return SimpleFormPage(
      title: l10n.panelSettings_downloadPreference,
      saving: _saving,
      onSave: _save,
      children: [
        SectionHeader(title: l10n.panelSettings_downloadPreference),
        TonalCard(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.panelSettings_useServerFilename),
            subtitle: Text(l10n.panelSettings_useServerFilenameHint),
            value: _useServerFilename,
            onChanged: (value) => setState(() => _useServerFilename = value),
          ),
        ),
      ],
    );
  }
}

class TerminalAppearanceSettingsPage extends ConsumerStatefulWidget {
  const TerminalAppearanceSettingsPage({super.key});

  @override
  ConsumerState<TerminalAppearanceSettingsPage> createState() =>
      _TerminalAppearanceSettingsPageState();
}

class _TerminalAppearanceSettingsPageState
    extends ConsumerState<TerminalAppearanceSettingsPage> {
  bool _loading = true;
  bool _loadFailed = false;
  bool _saving = false;
  bool _showTerminalButton = true;
  bool _cursorBlink = true;
  String _cursorStyle = 'block';
  final _lineHeight = TextEditingController();
  final _letterSpacing = TextEditingController();
  final _fontSize = TextEditingController();
  final _fontFamily = TextEditingController();
  final _backgroundColor = TextEditingController();
  final _foregroundColor = TextEditingController();
  final _scrollback = TextEditingController();
  final _scrollSensitivity = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _lineHeight.dispose();
    _letterSpacing.dispose();
    _fontSize.dispose();
    _fontFamily.dispose();
    _backgroundColor.dispose();
    _foregroundColor.dispose();
    _scrollback.dispose();
    _scrollSensitivity.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loadFailed = false);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final data = await repository.getTerminalAppearanceSettings();
      if (!mounted) return;
      setState(() {
        _showTerminalButton = _isEnabled(
          data['showTerminalButton'] ?? 'Enable',
        );
        _cursorBlink = _isEnabled(data['cursorBlink'] ?? 'Enable');
        final style = data['cursorStyle']?.toString() ?? '';
        _cursorStyle = const {'block', 'underline', 'bar'}.contains(style)
            ? style
            : 'block';
        _lineHeight.text = data['lineHeight']?.toString() ?? '';
        _letterSpacing.text = data['letterSpacing']?.toString() ?? '';
        _fontSize.text = data['fontSize']?.toString() ?? '';
        _fontFamily.text = data['fontFamily']?.toString() ?? '';
        _backgroundColor.text = data['backgroundColor']?.toString() ?? '';
        _foregroundColor.text = data['foregroundColor']?.toString() ?? '';
        _scrollback.text = data['scrollback']?.toString() ?? '';
        _scrollSensitivity.text = data['scrollSensitivity']?.toString() ?? '';
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
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.updateTerminalAppearanceSettings({
        'showTerminalButton': _enabledValue(_showTerminalButton),
        'lineHeight': _lineHeight.text.trim(),
        'letterSpacing': _letterSpacing.text.trim(),
        'fontSize': _fontSize.text.trim(),
        'fontFamily': _fontFamily.text.trim(),
        'backgroundColor': _backgroundColor.text.trim(),
        'foregroundColor': _foregroundColor.text.trim(),
        'cursorBlink': _enabledValue(_cursorBlink),
        'cursorStyle': _cursorStyle,
        'scrollback': _scrollback.text.trim(),
        'scrollSensitivity': _scrollSensitivity.text.trim(),
      });
      if (!mounted) return;
      AppToast.success(context, l10n.panelSettings_settingUpdated);
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
        appBar: AppBarLarge(title: l10n.panelSettings_terminalAppearance),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadFailed) {
      return Scaffold(
        appBar: AppBarLarge(title: l10n.panelSettings_terminalAppearance),
        body: EmptyState(
          icon: TablerIcons.alert_triangle,
          title: l10n.panelSettings_loadFailed,
          actionLabel: l10n.action_retry,
          onAction: _load,
        ),
      );
    }
    return SimpleFormPage(
      title: l10n.panelSettings_terminalAppearance,
      saving: _saving,
      onSave: _save,
      children: [
        SectionHeader(title: l10n.panelSettings_terminalBehavior),
        TonalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.panelSettings_showTerminalButton),
                subtitle: Text(l10n.panelSettings_showTerminalButtonHint),
                value: _showTerminalButton,
                onChanged: (value) =>
                    setState(() => _showTerminalButton = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.panelSettings_cursorBlink),
                value: _cursorBlink,
                onChanged: (value) => setState(() => _cursorBlink = value),
              ),
              DropdownButtonFormField<String>(
                initialValue: _cursorStyle,
                decoration: InputDecoration(
                  labelText: l10n.panelSettings_cursorStyle,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'block',
                    child: Text(l10n.panelSettings_cursorBlock),
                  ),
                  DropdownMenuItem(
                    value: 'underline',
                    child: Text(l10n.panelSettings_cursorUnderline),
                  ),
                  DropdownMenuItem(
                    value: 'bar',
                    child: Text(l10n.panelSettings_cursorBar),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _cursorStyle = value);
                },
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _scrollback,
                label: l10n.panelSettings_scrollback,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _scrollSensitivity,
                label: l10n.panelSettings_scrollSensitivity,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.s24),
        SectionHeader(title: l10n.panelSettings_terminalTypography),
        TonalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _fontFamily,
                label: l10n.panelSettings_fontFamily,
                hint: l10n.panelSettings_fontFamilyHint,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _fontSize,
                label: l10n.panelSettings_fontSize,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _lineHeight,
                label: l10n.panelSettings_lineHeight,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _letterSpacing,
                label: l10n.panelSettings_letterSpacing,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.s24),
        SectionHeader(title: l10n.panelSettings_terminalColors),
        TonalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _backgroundColor,
                label: l10n.panelSettings_backgroundColor,
                hint: l10n.panelSettings_colorHint,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _foregroundColor,
                label: l10n.panelSettings_foregroundColor,
                hint: l10n.panelSettings_colorHint,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FileHistorySettingsPage extends ConsumerStatefulWidget {
  const FileHistorySettingsPage({super.key});

  @override
  ConsumerState<FileHistorySettingsPage> createState() =>
      _FileHistorySettingsPageState();
}

class _FileHistorySettingsPageState
    extends ConsumerState<FileHistorySettingsPage> {
  bool _loading = true;
  bool _loadFailed = false;
  bool _saving = false;
  bool _enabled = false;
  final _maxPerPath = TextEditingController();
  final _quota = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _maxPerPath.dispose();
    _quota.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loadFailed = false);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final data = await repository.getFileHistorySetting();
      if (!mounted) return;
      setState(() {
        _enabled = _isEnabled(data['enable']);
        _maxPerPath.text = '${data['maxPerPath'] ?? 0}';
        _quota.text = '${data['diskQuotaMB'] ?? 0}';
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
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.updateFileHistorySetting(
        enable: _enabledValue(_enabled),
        maxPerPath: int.tryParse(_maxPerPath.text.trim()) ?? 0,
        diskQuotaMB: int.tryParse(_quota.text.trim()) ?? 0,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.panelSettings_settingUpdated);
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
        appBar: AppBarLarge(title: l10n.panelSettings_fileHistory),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadFailed) {
      return Scaffold(
        appBar: AppBarLarge(title: l10n.panelSettings_fileHistory),
        body: EmptyState(
          icon: TablerIcons.alert_triangle,
          title: l10n.panelSettings_loadFailed,
          actionLabel: l10n.action_retry,
          onAction: _load,
        ),
      );
    }
    return SimpleFormPage(
      title: l10n.panelSettings_fileHistory,
      saving: _saving,
      onSave: _save,
      children: [
        SectionHeader(title: l10n.panelSettings_fileHistory),
        TonalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.panelSettings_fileHistoryEnable),
                subtitle: Text(
                  l10n.panelSettings_fileHistoryHint,
                  style: AppTextStyles.bodyS.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
                value: _enabled,
                onChanged: (value) => setState(() => _enabled = value),
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _maxPerPath,
                label: l10n.panelSettings_fileHistoryMaxPerPath,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _quota,
                label: l10n.panelSettings_fileHistoryQuota,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LocalSshSettingsPage extends ConsumerStatefulWidget {
  const LocalSshSettingsPage({super.key});

  @override
  ConsumerState<LocalSshSettingsPage> createState() =>
      _LocalSshSettingsPageState();
}

class _LocalSshSettingsPageState extends ConsumerState<LocalSshSettingsPage> {
  bool _loading = true;
  bool _loadFailed = false;
  bool _saving = false;
  bool _checking = false;
  String _authMode = 'password';
  final _addr = TextEditingController();
  final _port = TextEditingController(text: '22');
  final _user = TextEditingController(text: 'root');
  final _password = TextEditingController();
  final _privateKey = TextEditingController();
  final _passPhrase = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _addr.dispose();
    _port.dispose();
    _user.dispose();
    _password.dispose();
    _privateKey.dispose();
    _passPhrase.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loadFailed = false);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final data = await repository.getLocalSshConn();
      if (!mounted) return;
      setState(() {
        _addr.text = data['addr']?.toString() ?? '';
        _port.text = '${data['port'] ?? 22}';
        _user.text = data['user']?.toString() ?? 'root';
        _authMode = data['authMode']?.toString() == 'key' ? 'key' : 'password';
        _password.text = _decodeSecret(data['password']?.toString() ?? '');
        _privateKey.text = _decodeSecret(data['privateKey']?.toString() ?? '');
        _passPhrase.text = _decodeSecret(data['passPhrase']?.toString() ?? '');
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadFailed = true);
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _decodeSecret(String value) {
    if (value.isEmpty) return value;
    try {
      return utf8.decode(base64.decode(value));
    } catch (_) {
      return value;
    }
  }

  String _encodeSecret(String value) =>
      value.isEmpty ? value : base64.encode(utf8.encode(value));

  Map<String, dynamic> _payload() {
    return {
      'addr': _addr.text.trim(),
      'port': int.tryParse(_port.text.trim()) ?? 22,
      'user': _user.text.trim(),
      'authMode': _authMode,
      'password': _encodeSecret(_password.text),
      'privateKey': _encodeSecret(_privateKey.text),
      'passPhrase': _passPhrase.text,
    };
  }

  Future<void> _check() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _checking = true);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final reachable = await repository.checkLocalSshConn(_payload());
      if (!mounted) return;
      if (reachable) {
        AppToast.success(context, l10n.panelSettings_sshCheckOk);
      } else {
        AppToast.error(context, l10n.panelSettings_sshCheckFailed);
      }
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_addr.text.trim().isEmpty ||
        _user.text.trim().isEmpty ||
        (_authMode == 'password' && _password.text.isEmpty) ||
        (_authMode == 'key' && _privateKey.text.isEmpty)) {
      AppToast.error(context, l10n.panelSettings_sshRequired);
      return;
    }
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.saveLocalSshConn(_payload());
      if (!mounted) return;
      AppToast.success(context, l10n.panelSettings_settingUpdated);
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
        appBar: AppBarLarge(title: l10n.panelSettings_localSsh),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadFailed) {
      return Scaffold(
        appBar: AppBarLarge(title: l10n.panelSettings_localSsh),
        body: EmptyState(
          icon: TablerIcons.alert_triangle,
          title: l10n.panelSettings_loadFailed,
          actionLabel: l10n.action_retry,
          onAction: _load,
        ),
      );
    }
    return SimpleFormPage(
      title: l10n.panelSettings_localSsh,
      saving: _saving,
      onSave: _save,
      children: [
        SectionHeader(title: l10n.panelSettings_localSsh),
        TonalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _addr,
                label: l10n.panelSettings_sshAddress,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _port,
                label: l10n.panelSettings_sshPort,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: _user,
                label: l10n.panelSettings_sshUser,
              ),
              const SizedBox(height: AppTokens.s12),
              DropdownButtonFormField<String>(
                initialValue: _authMode,
                decoration: InputDecoration(
                  labelText: l10n.panelSettings_sshAuthMode,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'password',
                    child: Text(l10n.panelSettings_sshAuthPassword),
                  ),
                  DropdownMenuItem(
                    value: 'key',
                    child: Text(l10n.panelSettings_sshAuthKey),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _authMode = value);
                },
              ),
              const SizedBox(height: AppTokens.s12),
              if (_authMode == 'password')
                AppTextField(
                  controller: _password,
                  label: l10n.panelSettings_sshPassword,
                  obscure: true,
                )
              else ...[
                AppTextField(
                  controller: _privateKey,
                  label: l10n.panelSettings_sshPrivateKey,
                  maxLines: 6,
                ),
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: _passPhrase,
                  label: l10n.panelSettings_sshPassPhrase,
                  obscure: true,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppTokens.s16),
        SecondaryButton(
          label: l10n.panelSettings_testConnection,
          icon: TablerIcons.plug_connected,
          loading: _checking,
          onPressed: _checking || _saving ? null : _check,
        ),
      ],
    );
  }
}
