import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../providers/database_detail_provider.dart';
import '../widgets/database_advanced_tab.dart';
import '../widgets/database_users_tab.dart';
import '../../../common/states/error_toast.dart';

class DatabaseDetailPage extends ConsumerStatefulWidget {
  const DatabaseDetailPage({
    super.key,
    required this.serverId,
    required this.databaseName,
    required this.type,
    required this.instance,
  });

  final int serverId;
  final String databaseName;
  final String type;
  final String instance;

  @override
  ConsumerState<DatabaseDetailPage> createState() => _DatabaseDetailPageState();
}

class _DatabaseDetailPageState extends ConsumerState<DatabaseDetailPage> {
  bool _showPassword = false;
  Timer? _hideTimer;

  DatabaseKey get _key =>
      (name: widget.databaseName, type: widget.type, instance: widget.instance);

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _togglePassword() {
    setState(() => _showPassword = !_showPassword);
    _hideTimer?.cancel();
    if (_showPassword) {
      _hideTimer = Timer(const Duration(seconds: 15), () {
        if (mounted) setState(() => _showPassword = false);
      });
    }
  }

  void _copy(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    AppToast.success(
      context,
      AppLocalizations.of(context).common_copiedLabel(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(databaseDetailProvider(_key));
    return Scaffold(
      appBar: AppBarLarge(
        title: widget.databaseName,
        subtitle: widget.type,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(databaseDetailProvider(_key)),
          ),
        ],
      ),
      body: AsyncStateView(
        value: detail,
        onRetry: () => ref.invalidate(databaseDetailProvider(_key)),
        loading: const SkeletonList(itemCount: 6),
        builder: (state) => SegmentedTabsView(
          labels: [
            l10n.databases_title,
            l10n.databases_usersGrants,
            l10n.databases_advanced,
          ],
          children: [
            ListView(
              padding: const EdgeInsets.all(AppTokens.pagePadding),
              children: [
                TonalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.item.name, style: AppTextStyles.titleL),
                      const SizedBox(height: AppTokens.s4),
                      Text(
                        '${state.item.from} · ${state.item.format}',
                        style: AppTextStyles.bodyS.copyWith(
                          color: context.scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.s24),
                SplitListGroup(
                  children: [
                    _CopyRow(
                      label: l10n.databases_address,
                      value: _conn('host', state),
                      onCopy: _copy,
                    ),
                    _CopyRow(
                      label: l10n.databases_port,
                      value: _conn('port', state),
                      onCopy: _copy,
                    ),
                    _CopyRow(
                      label: l10n.databases_username,
                      value: state.item.username,
                      onCopy: _copy,
                    ),
                    _PasswordRow(
                      label: l10n.databases_password,
                      value: state.item.password,
                      visible: _showPassword,
                      onToggle: _togglePassword,
                      onCopy: _copy,
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s24),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.s8,
                  ),
                  title: Text(
                    l10n.databases_remoteAccess,
                    style: AppTextStyles.bodyM,
                  ),
                  subtitle: Text(
                    state.remoteAccess
                        ? l10n.databases_enabled
                        : l10n.databases_disabled,
                    style: AppTextStyles.bodyS.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                  value: state.remoteAccess,
                  onChanged: _setRemoteAccess,
                ),
                const SizedBox(height: AppTokens.s16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showStatus(state),
                        icon: const Icon(TablerIcons.activity),
                        label: Text(l10n.databases_status),
                      ),
                    ),
                    const SizedBox(width: AppTokens.s12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _changePassword(state.item.id),
                        icon: const Icon(TablerIcons.key),
                        label: Text(l10n.databases_changePassword),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s12),
                OutlinedButton.icon(
                  onPressed: _delete,
                  icon: const Icon(TablerIcons.trash),
                  label: Text(l10n.databases_deleteDatabase),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.appColors.danger,
                  ),
                ),
              ],
            ),
            DatabaseUsersTab(
              item: state.item,
              type: widget.type,
              instance: widget.instance,
            ),
            DatabaseAdvancedTab(
              type: widget.type,
              instance: widget.instance,
              databaseName: widget.databaseName,
            ),
          ],
        ),
      ),
    );
  }

  String get _from {
    final state = ref.read(databaseDetailProvider(_key)).valueOrNull;
    final from = state?.item.from ?? '';
    return from.isEmpty ? 'local' : from;
  }

  String _conn(String key, DatabaseDetailState state) {
    final value = state.connection[key];
    if (value != null && '$value'.isNotEmpty) return '$value';
    return '-';
  }

  Future<void> _showStatus(DatabaseDetailState state) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      final status = await repository.getStatus(
        type: widget.type,
        name: state.item.name,
      );
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.databases_status, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            if (status.isEmpty)
              Text(l10n.state_empty)
            else
              SplitListGroup(
                children: [
                  for (final entry in status.entries)
                    SplitListTile(
                      title: entry.key,
                      trailing: Text(entry.value),
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

  Future<void> _setRemoteAccess(bool value) async {
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      await repository.updateRemoteAccess(
        type: widget.type,
        database: widget.instance,
        remote: value,
      );
      if (!mounted) return;
      AppToast.success(context, AppLocalizations.of(context).action_done);
      ref.invalidate(databaseDetailProvider(_key));
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _changePassword(int id) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final value = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.databases_changePasswordSubtitle,
            style: AppTextStyles.titleL,
          ),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            controller: controller,
            label: l10n.databases_newPassword,
            obscure: true,
            autofocus: true,
          ),
          const SizedBox(height: AppTokens.s24),
          PrimaryButton(
            label: l10n.action_save,
            onPressed: () => Navigator.of(sheetContext).pop(controller.text),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty) return;
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      await repository.changePassword(
        id: id,
        from: _from,
        type: widget.type,
        database: widget.instance,
        value: value,
        name: widget.databaseName,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.databases_passwordChanged);
      ref.invalidate(databaseDetailProvider(_key));
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      final state = ref.read(databaseDetailProvider(_key)).valueOrNull;
      if (state == null) return;
      var related = 0;
      try {
        final resources = await repository.checkDelete(
          id: state.item.id,
          type: widget.type,
          database: widget.instance,
        );
        related = resources.length;
      } catch (_) {
        // 关联资源检查失败时仍允许输入名称确认删除。
      }
      if (!mounted) return;
      final confirmed = await showConfirmSheet(
        context,
        title: l10n.databases_deleteDatabase,
        message: related == 0
            ? l10n.databases_deleteMessage
            : l10n.databases_deleteRelatedMessage(related),
        confirmLabel: l10n.action_delete,
        requireText: widget.databaseName,
      );
      if (!confirmed) return;
      if (widget.type.startsWith('postgresql')) {
        await repository.deletePgDatabase(
          id: state.item.id,
          type: widget.type,
          database: widget.instance,
        );
      } else if (widget.type == 'mongodb') {
        await repository.deleteMongoDatabase(
          id: state.item.id,
          database: widget.instance,
        );
      } else {
        await repository.deleteDatabase(
          id: state.item.id,
          type: widget.type,
          database: widget.instance,
          forceDelete: false,
          deleteBackup: false,
        );
      }
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  final String label;
  final String value;
  final void Function(String value, String label) onCopy;

  @override
  Widget build(BuildContext context) {
    return SplitListTile(
      title: label,
      subtitle: value,
      trailing: IconButton(
        tooltip: AppLocalizations.of(context).action_copy,
        icon: const Icon(TablerIcons.copy, size: AppTokens.iconList),
        onPressed: () => onCopy(value, label),
      ),
    );
  }
}

class _PasswordRow extends StatelessWidget {
  const _PasswordRow({
    required this.label,
    required this.value,
    required this.visible,
    required this.onToggle,
    required this.onCopy,
  });

  final String label;
  final String value;
  final bool visible;
  final VoidCallback onToggle;
  final void Function(String value, String label) onCopy;

  @override
  Widget build(BuildContext context) {
    return SplitListTile(
      title: label,
      subtitle: visible ? value : '••••••••',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: visible
                ? AppLocalizations.of(context).common_hide
                : AppLocalizations.of(context).common_show,
            icon: Icon(
              visible ? TablerIcons.eye_off : TablerIcons.eye,
              size: AppTokens.iconList,
            ),
            onPressed: onToggle,
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).action_copy,
            icon: const Icon(TablerIcons.copy, size: AppTokens.iconList),
            onPressed: () => onCopy(value, label),
          ),
        ],
      ),
    );
  }
}
