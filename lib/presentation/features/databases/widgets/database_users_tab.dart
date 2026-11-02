import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/database/database_instance_dto.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/error_toast.dart';

class DatabaseUsersTab extends ConsumerStatefulWidget {
  const DatabaseUsersTab({
    super.key,
    required this.item,
    required this.type,
    required this.instance,
  });

  final DatabaseSearchItemDto item;
  final String type;
  final String instance;

  @override
  ConsumerState<DatabaseUsersTab> createState() => _DatabaseUsersTabState();
}

class _DatabaseUsersTabState extends ConsumerState<DatabaseUsersTab> {
  List<Map<String, dynamic>> _users = const [];
  List<Map<String, dynamic>> _grants = const [];
  String _mongoPermission = '';
  bool _loading = true;

  bool get _isMysql => widget.type == 'mysql' || widget.type == 'mariadb';
  bool get _isPg => widget.type.startsWith('postgresql');
  bool get _isMongo => widget.type == 'mongodb';

  @override
  void initState() {
    super.initState();
    unawaited(_reload());
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      var users = const <Map<String, dynamic>>[];
      var grants = const <Map<String, dynamic>>[];
      var permission = '';
      if (_isMysql) {
        users = await repository.searchUsers(database: widget.instance);
        grants = await repository.searchGrants(database: widget.instance);
      } else if (_isMongo && widget.item.username.isNotEmpty) {
        permission = await repository.loadMongoPrivileges(
          database: widget.instance,
          name: widget.item.name,
          username: widget.item.username,
        );
      }
      if (!mounted) return;
      setState(() {
        _users = users;
        _grants = grants;
        _mongoPermission = permission;
      });
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _permissionLabel(AppLocalizations l10n, String value) {
    return switch (value) {
      'read' => l10n.databases_permissionRead,
      'readWrite' => l10n.databases_permissionReadWrite,
      'dbOwner' => l10n.databases_permissionDbOwner,
      'userAdmin' => l10n.databases_permissionUserAdmin,
      _ => value,
    };
  }

  List<String> _grantedDbs(String username, String host) {
    return _grants
        .where(
          (item) =>
              '${item['username']}' == username && '${item['host']}' == host,
        )
        .map((item) => '${item['db'] ?? item['database'] ?? ''}')
        .where((db) => db.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(AppTokens.pagePadding),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.databases_usersGrants,
                style: AppTextStyles.titleM,
              ),
            ),
            if (_isMysql)
              TextButton.icon(
                onPressed: _addMysqlUser,
                icon: const Icon(TablerIcons.plus, size: AppTokens.iconList),
                label: Text(l10n.databases_addUser),
              )
            else
              TextButton.icon(
                onPressed: _bindUser,
                icon: const Icon(TablerIcons.link, size: AppTokens.iconList),
                label: Text(l10n.databases_bindUser),
              ),
          ],
        ),
        const SizedBox(height: AppTokens.s12),
        if (_isMysql) _mysqlList(l10n) else _singleUser(l10n),
      ],
    );
  }

  Widget _mysqlList(AppLocalizations l10n) {
    if (_users.isEmpty) {
      return _empty(l10n);
    }
    return SplitListGroup(
      children: [
        for (final user in _users)
          _mysqlUserTile(
            l10n,
            username: '${user['username'] ?? ''}',
            host: '${user['host'] ?? '%'}',
            description: '${user['description'] ?? ''}',
          ),
      ],
    );
  }

  Widget _mysqlUserTile(
    AppLocalizations l10n, {
    required String username,
    required String host,
    required String description,
  }) {
    final granted = _grantedDbs(username, host);
    final subtitle = [
      '${l10n.databases_userHost}: $host',
      if (granted.isNotEmpty) granted.join(', '),
      if (description.isNotEmpty) description,
    ].join(' · ');
    return SplitListTile(
      leading: const Icon(TablerIcons.user),
      title: username,
      subtitle: subtitle,
      trailing: PopupMenuButton<String>(
        icon: const Icon(TablerIcons.dots_vertical),
        onSelected: (value) {
          switch (value) {
            case 'password':
              _changeUserPassword(username, host);
            case 'grant':
              _grant(username, host);
            case 'revoke':
              _revoke(username, host);
            case 'delete':
              _deleteUser(username, host);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'password',
            child: Text(l10n.databases_changePassword),
          ),
          PopupMenuItem(value: 'grant', child: Text(l10n.databases_grant)),
          PopupMenuItem(value: 'revoke', child: Text(l10n.databases_revoke)),
          PopupMenuItem(
            value: 'delete',
            child: Text(l10n.databases_deleteUser),
          ),
        ],
      ),
    );
  }

  Widget _singleUser(AppLocalizations l10n) {
    final username = widget.item.username;
    if (username.isEmpty) {
      return _empty(l10n);
    }
    if (_isPg) {
      return SplitListGroup(
        children: [
          SplitListTile(
            leading: const Icon(TablerIcons.user),
            title: username,
            subtitle: widget.item.superUser == true
                ? l10n.databases_superUser
                : l10n.databases_normalUser,
            trailing: Switch(
              value: widget.item.superUser == true,
              onChanged: _togglePgSuperUser,
            ),
          ),
        ],
      );
    }
    return SplitListGroup(
      children: [
        SplitListTile(
          leading: const Icon(TablerIcons.user),
          title: username,
          subtitle: _mongoPermission.isEmpty
              ? l10n.databases_noUsers
              : _permissionLabel(l10n, _mongoPermission),
          trailing: PopupMenuButton<String>(
            icon: const Icon(TablerIcons.dots_vertical),
            onSelected: _changeMongoPermission,
            itemBuilder: (context) => [
              for (final permission in const [
                'read',
                'readWrite',
                'dbOwner',
                'userAdmin',
              ])
                PopupMenuItem(
                  value: permission,
                  child: Text(_permissionLabel(l10n, permission)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _empty(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.s32),
      child: Center(
        child: Text(
          l10n.databases_noUsers,
          style: AppTextStyles.bodyM.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Future<void> _addMysqlUser() async {
    final l10n = AppLocalizations.of(context);
    final username = TextEditingController();
    final host = TextEditingController(text: '%');
    final password = TextEditingController();
    final description = TextEditingController();
    final confirmed = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.databases_addUser, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            controller: username,
            label: l10n.databases_username,
            autofocus: true,
          ),
          const SizedBox(height: AppTokens.s12),
          AppTextField(controller: host, label: l10n.databases_host),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: password,
            label: l10n.databases_password,
            obscure: true,
          ),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: description,
            label: l10n.databases_description,
          ),
          const SizedBox(height: AppTokens.s20),
          PrimaryButton(
            label: l10n.action_save,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
        ],
      ),
    );
    final name = username.text.trim();
    final hostValue = host.text.trim();
    final pass = password.text;
    final desc = description.text.trim();
    username.dispose();
    host.dispose();
    password.dispose();
    description.dispose();
    if (confirmed != true || name.isEmpty || pass.isEmpty) return;
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      await repository.createUser(
        database: widget.instance,
        username: name,
        host: hostValue.isEmpty ? '%' : hostValue,
        password: pass,
        dbs: [widget.item.name],
        description: desc,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.databases_userCreated);
      unawaited(_reload());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _bindUser() async {
    final l10n = AppLocalizations.of(context);
    final username = TextEditingController();
    final password = TextEditingController();
    var superUser = false;
    final confirmed = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.databases_bindUser, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            AppTextField(
              controller: username,
              label: l10n.databases_username,
              autofocus: true,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: password,
              label: l10n.databases_password,
              obscure: true,
            ),
            if (_isPg)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.databases_superUser),
                value: superUser,
                onChanged: (value) => setSheetState(() => superUser = value),
              ),
            const SizedBox(height: AppTokens.s20),
            PrimaryButton(
              label: l10n.action_save,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    );
    final name = username.text.trim();
    final pass = password.text;
    username.dispose();
    password.dispose();
    if (confirmed != true || name.isEmpty || pass.isEmpty) return;
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      if (_isPg) {
        await repository.bindPgUser(
          database: widget.instance,
          name: widget.item.name,
          username: name,
          password: pass,
          superUser: superUser,
        );
      } else {
        await repository.bindMongoUser(
          database: widget.instance,
          name: widget.item.name,
          username: name,
          password: pass,
        );
      }
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_reload());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _changeUserPassword(String username, String host) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final confirmed = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.databases_changePassword, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            controller: controller,
            label: l10n.databases_newPassword,
            obscure: true,
            autofocus: true,
          ),
          const SizedBox(height: AppTokens.s20),
          PrimaryButton(
            label: l10n.action_save,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
        ],
      ),
    );
    final value = controller.text;
    controller.dispose();
    if (confirmed != true || value.isEmpty) return;
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      await repository.changeUserPassword(
        database: widget.instance,
        username: username,
        host: host,
        password: value,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.databases_passwordChanged);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _grant(String username, String host) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: widget.item.name);
    final confirmed = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.databases_grant, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            controller: controller,
            label: l10n.databases_grantDatabase,
            autofocus: true,
          ),
          const SizedBox(height: AppTokens.s20),
          PrimaryButton(
            label: l10n.action_save,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
        ],
      ),
    );
    final db = controller.text.trim();
    controller.dispose();
    if (confirmed != true || db.isEmpty) return;
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      await repository.grantUser(
        database: widget.instance,
        db: db,
        username: username,
        host: host,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_reload());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _revoke(String username, String host) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: widget.item.name);
    final confirmed = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.databases_revoke, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            controller: controller,
            label: l10n.databases_grantDatabase,
            autofocus: true,
          ),
          const SizedBox(height: AppTokens.s20),
          PrimaryButton(
            label: l10n.action_save,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
        ],
      ),
    );
    final db = controller.text.trim();
    controller.dispose();
    if (confirmed != true || db.isEmpty) return;
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      await repository.revokeGrant(
        database: widget.instance,
        db: db,
        username: username,
        host: host,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_reload());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _deleteUser(String username, String host) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.databases_deleteUser,
      message: '$username@$host',
      confirmLabel: l10n.action_delete,
      requireText: username,
    );
    if (!confirmed) return;
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      await repository.deleteUser(
        database: widget.instance,
        username: username,
        host: host,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_reload());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _togglePgSuperUser(bool value) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      await repository.changePgPrivileges(
        database: widget.instance,
        name: widget.item.name,
        username: widget.item.username,
        superUser: value,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.databases_permissionUpdated);
      unawaited(_reload());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _changeMongoPermission(String permission) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      await repository.changeMongoPrivileges(
        database: widget.instance,
        name: widget.item.name,
        username: widget.item.username,
        permission: permission,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.databases_permissionUpdated);
      unawaited(_reload());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }
}
