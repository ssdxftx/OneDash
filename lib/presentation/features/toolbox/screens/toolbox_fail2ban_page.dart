import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
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

class ToolboxFail2banPage extends ConsumerStatefulWidget {
  const ToolboxFail2banPage({super.key});

  @override
  ConsumerState<ToolboxFail2banPage> createState() =>
      _ToolboxFail2banPageState();
}

class _ToolboxFail2banPageState extends ConsumerState<ToolboxFail2banPage> {
  Map<String, dynamic> _base = const {};
  List<String> _banned = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      final base = await repository.getFail2banBase();
      if (!mounted) return;
      setState(() => _base = base);
      var banned = const <String>[];
      if (base['isExist'] == true && base['isActive'] == true) {
        try {
          banned = await repository.searchFail2ban('banned');
        } catch (error) {
          if (!mounted) return;
          showErrorToast(context, error);
        }
      }
      if (!mounted) return;
      setState(() => _banned = banned);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleService(bool enabled) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.operateFail2ban(enabled ? 'start' : 'stop');
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _unban(String ip) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.toolbox_unban,
      message: ip,
      confirmLabel: l10n.toolbox_unban,
      danger: false,
    );
    if (!confirmed) return;
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.operateFail2banSshd([ip], 'unban');
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  SplitListTile _confTile(String key, String label, {bool numeric = false}) {
    return SplitListTile(
      title: label,
      subtitle: '${_base[key] ?? '-'}',
      trailing: const Icon(TablerIcons.edit),
      onTap: () =>
          _editConf(key, label, '${_base[key] ?? ''}', numeric: numeric),
    );
  }

  Future<void> _editConf(
    String key,
    String label,
    String current, {
    bool numeric = false,
  }) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: current);
    final value = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            controller: controller,
            keyboardType: numeric ? TextInputType.number : TextInputType.text,
            autofocus: true,
          ),
          if (key == 'banTime' || key == 'findTime') ...[
            const SizedBox(height: AppTokens.s8),
            Text(
              l10n.toolbox_durationHint,
              style: AppTextStyles.bodyS.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppTokens.s24),
          PrimaryButton(
            label: l10n.action_save,
            onPressed: () => Navigator.of(sheetContext).pop(controller.text),
          ),
        ],
      ),
    );
    controller.dispose();
    final next = value?.trim() ?? '';
    if (next.isEmpty || next == current) return;
    if (!mounted) return;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.toolbox_fail2banChanged,
      message: '$label: $next',
      confirmLabel: l10n.action_save,
      danger: false,
    );
    if (!confirmed) return;
    await _saveConf(key, next);
  }

  Future<void> _editBanAction() async {
    final l10n = AppLocalizations.of(context);
    var action = '${_base['banAction'] ?? 'iptables-multiport'}';
    const options = [
      'iptables-allports',
      'iptables-multiport',
      'firewallcmd-ipset',
      'ufw',
    ];
    if (!options.contains(action)) action = options.first;
    final value = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.toolbox_banAction, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            DropdownButtonFormField<String>(
              initialValue: action,
              items: [
                for (final option in options)
                  DropdownMenuItem(value: option, child: Text(option)),
              ],
              onChanged: (next) {
                if (next != null) setSheetState(() => action = next);
              },
            ),
            const SizedBox(height: AppTokens.s24),
            PrimaryButton(
              label: l10n.action_save,
              onPressed: () => Navigator.of(sheetContext).pop(action),
            ),
          ],
        ),
      ),
    );
    if (value == null || value == _base['banAction']) return;
    if (!mounted) return;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.toolbox_fail2banChanged,
      message: '${l10n.toolbox_banAction}: $value',
      confirmLabel: l10n.action_save,
      danger: false,
    );
    if (!confirmed) return;
    await _saveConf('banAction', value);
  }

  Future<void> _saveConf(String key, String value) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      final apiKey = switch (key) {
        'maxRetry' => 'maxretry',
        'banTime' => 'bantime',
        'findTime' => 'findtime',
        'banAction' => 'banaction',
        'logPath' => 'logpath',
        _ => key,
      };
      await repository.updateFail2banConf(apiKey, value);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
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
    final installed = _base['isExist'] == true;
    final active = installed && _base['isActive'] == true;
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.toolbox_fail2ban,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _load,
          ),
        ],
      ),
      body: !installed
          ? EmptyState(
              icon: TablerIcons.ban,
              title: l10n.toolbox_fail2ban,
              message: l10n.toolbox_notInstalledHint,
            )
          : ListView(
              padding: const EdgeInsets.all(AppTokens.s16),
              children: [
                SplitListGroup(
                  children: [
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.s16,
                      ),
                      title: Text(l10n.toolbox_sshProtection),
                      subtitle: Text(
                        active ? l10n.toolbox_running : l10n.toolbox_stopped,
                      ),
                      value: active,
                      onChanged: _toggleService,
                    ),
                    SplitListTile(
                      title: l10n.toolbox_installed,
                      subtitle: _base['isExist'] == true
                          ? l10n.common_yes
                          : l10n.common_no,
                    ),
                    SplitListTile(
                      title: l10n.toolbox_version,
                      subtitle: '${_base['version'] ?? '-'}',
                    ),
                  ],
                ),
                if (_base['isExist'] == true) ...[
                  const SizedBox(height: AppTokens.s24),
                  SectionHeader(title: l10n.toolbox_fail2banBase),
                  SplitListGroup(
                    children: [
                      _confTile('port', l10n.toolbox_port, numeric: true),
                      _confTile(
                        'maxRetry',
                        l10n.toolbox_maxRetry,
                        numeric: true,
                      ),
                      _confTile('banTime', l10n.toolbox_banTime),
                      _confTile('findTime', l10n.toolbox_findTime),
                      SplitListTile(
                        title: l10n.toolbox_banAction,
                        subtitle: '${_base['banAction'] ?? '-'}',
                        trailing: const Icon(TablerIcons.edit),
                        onTap: _editBanAction,
                      ),
                      _confTile('logPath', l10n.toolbox_logPath),
                    ],
                  ),
                ],
                const SizedBox(height: AppTokens.s24),
                SectionHeader(title: l10n.toolbox_sshBan),
                if (_banned.isEmpty)
                  EmptyState(
                    icon: TablerIcons.shield_check,
                    title: l10n.toolbox_sshBan,
                    message: l10n.state_empty,
                    compact: true,
                  )
                else
                  SplitListGroup(
                    children: [
                      for (final ip in _banned)
                        SplitListTile(
                          leading: const Icon(TablerIcons.ban),
                          title: ip,
                          trailing: TextButton(
                            onPressed: () => _unban(ip),
                            child: Text(l10n.toolbox_unban),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
    );
  }
}
