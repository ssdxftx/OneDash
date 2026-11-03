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

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
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
    final confirmed = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.toolbox_ftpAdd, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
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
          const SizedBox(height: AppTokens.s24),
          PrimaryButton(
            label: l10n.action_create,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
        ],
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
            onPressed: _create,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.pagePadding),
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
                    title: displayValue(context, item['user']?.toString()),
                    subtitle: displayValue(context, item['path']?.toString()),
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
