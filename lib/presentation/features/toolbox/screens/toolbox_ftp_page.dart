import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/toolbox_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../../../common/formatters/value_labels.dart';

class ToolboxFtpPage extends ConsumerStatefulWidget {
  const ToolboxFtpPage({super.key});

  @override
  ConsumerState<ToolboxFtpPage> createState() => _ToolboxFtpPageState();
}

class _ToolboxFtpPageState extends ConsumerState<ToolboxFtpPage> {
  Map<String, dynamic> _base = const {};
  List<Map<String, dynamic>> _accounts = const [];
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      final base = await repository.getFtpBase();
      final accounts = await repository.searchFtp();
      if (!mounted) return;
      setState(() {
        _base = base;
        _accounts = accounts;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _failed = true);
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final user = TextEditingController();
    final password = TextEditingController();
    final path = TextEditingController(text: '/');
    final description = TextEditingController();
    List<String> systemUsers = const [];
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      systemUsers = await repository.loadUsers();
    } catch (_) {
      systemUsers = const [];
    }
    if (!mounted) return;
    final confirmed = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.toolbox_ftpAdd,
          saveLabel: l10n.action_create,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            if (systemUsers.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.toolbox_ftpSystemUser,
                ),
                items: [
                  for (final name in systemUsers)
                    DropdownMenuItem(value: name, child: Text(name)),
                ],
                onChanged: (name) {
                  if (name != null) user.text = name;
                },
              ),
              const SizedBox(height: AppTokens.s12),
            ],
            AppTextField(
              controller: user,
              label: l10n.toolbox_ftpUser,
              autofocus: true,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: password,
              label: l10n.toolbox_ftpPassword,
              obscure: true,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: path, label: l10n.toolbox_ftpPath),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: description,
              label: l10n.databases_description,
            ),
          ],
        ),
      ),
    );
    final name = user.text.trim();
    final pass = password.text;
    final root = path.text.trim();
    final desc = description.text.trim();
    user.dispose();
    password.dispose();
    path.dispose();
    description.dispose();
    if (confirmed != true || name.isEmpty || pass.isEmpty) return;
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.createFtp(
        user: name,
        password: pass,
        path: root.isEmpty ? '/' : root,
        description: desc,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _edit(Map<String, dynamic> item) async {
    final l10n = AppLocalizations.of(context);
    final id = (item['id'] as num?)?.toInt() ?? 0;
    if (id == 0) return;
    final password = TextEditingController(text: '${item['password'] ?? ''}');
    final path = TextEditingController(text: '${item['path'] ?? '/'}');
    final description = TextEditingController(
      text: '${item['description'] ?? ''}',
    );
    var status = '${item['status'] ?? 'Enable'}'.toLowerCase() == 'disable'
        ? 'Disable'
        : 'Enable';
    final confirmed = await pushFormPage<bool>(
      context,
      StatefulBuilder(
        builder: (pageContext, setPageState) => SimpleFormPage(
          title: l10n.toolbox_ftpEdit,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(
              controller: password,
              label: l10n.toolbox_ftpPassword,
              obscure: true,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: path, label: l10n.toolbox_ftpPath),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: description,
              label: l10n.databases_description,
            ),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: status,
              decoration: InputDecoration(labelText: l10n.toolbox_ftpStatus),
              items: [
                DropdownMenuItem(
                  value: 'Enable',
                  child: Text(l10n.websites_enabled),
                ),
                DropdownMenuItem(
                  value: 'Disable',
                  child: Text(l10n.websites_disabled),
                ),
              ],
              onChanged: (value) {
                if (value != null) setPageState(() => status = value);
              },
            ),
          ],
        ),
      ),
    );
    final newStatus = status;
    final newPassword = password.text;
    final newPath = path.text.trim();
    final newDescription = description.text.trim();
    password.dispose();
    path.dispose();
    description.dispose();
    if (confirmed != true || !mounted) return;
    if (newPassword.isEmpty) {
      AppToast.error(context, l10n.toolbox_ftpPasswordRequired);
      return;
    }
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.updateFtp({
        'id': id,
        'password': newPassword,
        'path': newPath.isEmpty ? '/' : newPath,
        'description': newDescription,
        'status': newStatus,
      });
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _operate() async {
    final l10n = AppLocalizations.of(context);
    final operation = await showSelectionMenu<String>(
      context,
      title: l10n.toolbox_ftpService,
      options: [
        SelectionOption(
          label: l10n.toolbox_ftpStart,
          value: 'start',
          icon: TablerIcons.player_play,
        ),
        SelectionOption(
          label: l10n.toolbox_ftpStop,
          value: 'stop',
          icon: TablerIcons.player_stop,
        ),
        SelectionOption(
          label: l10n.toolbox_ftpRestart,
          value: 'restart',
          icon: TablerIcons.refresh,
        ),
      ],
    );
    if (operation == null || !mounted) return;
    if (operation == 'stop' || operation == 'restart') {
      final confirmed = await showConfirmSheet(
        context,
        title: operation == 'stop'
            ? l10n.toolbox_ftpStop
            : l10n.toolbox_ftpRestart,
        message: l10n.toolbox_ftpServiceConfirm,
        confirmLabel: operation == 'stop'
            ? l10n.toolbox_ftpStop
            : l10n.toolbox_ftpRestart,
      );
      if (!confirmed || !mounted) return;
    }
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.operateFtp(operation);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _sync() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.syncFtp();
      if (!mounted) return;
      AppToast.success(context, l10n.toolbox_ftpSyncDone);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showLogs() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      final data = await repository.searchFtpLogs();
      if (!mounted) return;
      final items =
          (data['items'] as List?)
              ?.whereType<Map>()
              .map((row) => row.cast<String, dynamic>())
              .toList(growable: false) ??
          const <Map<String, dynamic>>[];
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.85,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.toolbox_ftpLogs, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s12),
            if (items.isEmpty)
              EmptyState(
                compact: true,
                icon: TablerIcons.file_text,
                title: l10n.toolbox_ftpLogEmpty,
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final item in items)
                      ListTile(
                        title: Text(
                          '${item['operation'] ?? ''} ${item['user'] ?? ''}',
                          style: AppTextStyles.bodyM,
                        ),
                        subtitle: Text(
                          '${item['path'] ?? ''} ${item['time'] ?? item['createdAt'] ?? ''}',
                          style: AppTextStyles.bodyS,
                        ),
                      ),
                  ],
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

  Future<void> _delete(Map<String, dynamic> item) async {
    final l10n = AppLocalizations.of(context);
    final id = (item['id'] as num?)?.toInt() ?? 0;
    final user = '${item['user'] ?? ''}';
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: user,
      confirmLabel: l10n.action_delete,
      requireText: user,
    );
    if (!confirmed || id == 0) return;
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.deleteFtp([id]);
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
    final installed = _base['isExist'] == true;
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.toolbox_ftp,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _load,
          ),
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.toolbox_ftpAdd,
            onPressed: installed ? _create : null,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _failed
          ? EmptyState(
              icon: TablerIcons.alert_triangle,
              title: l10n.toolbox_loadFailed,
              actionLabel: l10n.action_retry,
              onAction: _load,
            )
          : ListView(
              padding: EdgeInsets.all(context.pagePadding),
              children: [
                SplitListGroup(
                  children: [
                    SplitListTile(
                      title: l10n.toolbox_installed,
                      subtitle: _base['isExist'] == true
                          ? l10n.common_yes
                          : l10n.common_no,
                    ),
                    SplitListTile(
                      title: l10n.toolbox_running,
                      subtitle: _base['isActive'] == true
                          ? l10n.common_yes
                          : l10n.common_no,
                    ),
                    SplitListTile(
                      leading: const Icon(TablerIcons.settings_cog),
                      title: l10n.toolbox_ftpService,
                      trailing: const Icon(TablerIcons.chevron_right),
                      onTap: installed ? _operate : null,
                    ),
                    SplitListTile(
                      leading: const Icon(TablerIcons.refresh),
                      title: l10n.toolbox_ftpSync,
                      trailing: const Icon(TablerIcons.chevron_right),
                      onTap: installed ? _sync : null,
                    ),
                    SplitListTile(
                      leading: const Icon(TablerIcons.file_text),
                      title: l10n.toolbox_ftpLogs,
                      trailing: const Icon(TablerIcons.chevron_right),
                      onTap: _showLogs,
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s24),
                if (_accounts.isEmpty)
                  EmptyState(
                    icon: TablerIcons.folder,
                    title: l10n.toolbox_ftpEmptyTitle,
                    message: l10n.state_empty,
                    compact: true,
                  )
                else
                  SplitListGroup(
                    children: [
                      for (final item in _accounts)
                        SplitListTile(
                          leading: const Icon(TablerIcons.user),
                          title: displayValue(
                            context,
                            item['user']?.toString(),
                          ),
                          onTap: () => _edit(item),
                          subtitle: displayValue(
                            context,
                            item['path']?.toString(),
                          ),
                          trailing: IconButton(
                            tooltip: l10n.action_delete,
                            icon: const Icon(TablerIcons.trash),
                            onPressed: () => _delete(item),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
    );
  }
}
