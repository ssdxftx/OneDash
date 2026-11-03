import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/database/database_instance_dto.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../widgets/database_create_sheet.dart';

class _DatabasesState {
  const _DatabasesState({
    required this.items,
    required this.types,
    required this.instances,
  });

  final List<DatabaseSearchItemDto> items;
  final List<String> types;
  final List<DatabaseInstanceDto> instances;
}

final _databasesProvider = FutureProvider.autoDispose<_DatabasesState>((
  ref,
) async {
  final repository = await ref.watch(databaseRepositoryProvider.future);
  List<DatabaseInstanceDto> instances = const [];
  try {
    instances = await repository.listInstances(
      'mysql,postgresql,redis,mongodb',
    );
  } catch (_) {
    // 忽略：下方按默认类型兜底查询。
  }
  final types = instances.isEmpty
      ? ['mysql', 'postgresql', 'redis', 'mongodb']
      : instances.map((e) => e.type).toSet().toList();
  var failures = 0;
  Object? firstError;
  final results = await Future.wait<List<DatabaseSearchItemDto>>(
    types.map((type) async {
      try {
        final page = switch (type) {
          'postgresql' ||
          'postgresql-cluster' => await repository.searchPgDatabases(
            database: type,
            page: 1,
            pageSize: 100,
          ),
          'mongodb' => await repository.searchMongoDatabases(
            database: type,
            page: 1,
            pageSize: 100,
          ),
          _ => await repository.searchDatabases(
            database: type,
            page: 1,
            pageSize: 100,
          ),
        };
        return page.items.map((item) => item.withType(type)).toList();
      } catch (error) {
        failures++;
        firstError ??= error;
        return <DatabaseSearchItemDto>[];
      }
    }),
  );
  if (types.isNotEmpty && failures == types.length && firstError != null) {
    throw firstError!;
  }
  return _DatabasesState(
    items: results.expand((e) => e).toList(),
    types: types,
    instances: instances,
  );
}, name: 'databasesProvider');

class DatabasesPage extends ConsumerStatefulWidget {
  const DatabasesPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<DatabasesPage> createState() => _DatabasesPageState();
}

class _DatabasesPageState extends ConsumerState<DatabasesPage> {
  String _type = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final databases = ref.watch(_databasesProvider);
    final state = databases.valueOrNull;
    final types = ['', ...?state?.types];
    final filtered = state == null
        ? const <DatabaseSearchItemDto>[]
        : _type.isEmpty
        ? state.items
        : state.items.where((e) => e.dbType == _type).toList();

    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.databases_title,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_databasesProvider),
          ),
          AppIconButton(
            icon: TablerIcons.server,
            tooltip: l10n.databases_remoteInstances,
            onPressed: _showRemote,
          ),
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.databases_create,
            onPressed: () => _showCreateType(state),
          ),
        ],
      ),
      body: Column(
        children: [
          AppFilterChips<String>(
            options: types,
            labelOf: (value) =>
                value.isEmpty ? l10n.websites_all : _typeLabel(value),
            selected: {_type},
            onChanged: (selection) {
              if (selection.isEmpty) return;
              setState(() => _type = selection.first);
            },
          ),
          Expanded(
            child: AsyncStateView(
              value: databases,
              onRetry: () => ref.invalidate(_databasesProvider),
              loading: const SkeletonList(itemCount: 8),
              isEmpty: (_) => filtered.isEmpty,
              empty: EmptyState(
                icon: TablerIcons.database,
                title: l10n.databases_empty_title,
                message: l10n.databases_empty_message,
              ),
              builder: (_) => ListView.builder(
                padding: const EdgeInsets.all(AppTokens.pagePadding),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.s12),
                    child: _DatabaseCard(
                      item: item,
                      onTap: () => context.push(
                        '/s/${widget.serverId}/more/databases/${Uri.encodeComponent(item.name)}?type=${Uri.encodeComponent(item.dbType)}&instance=${Uri.encodeComponent(item.instanceName)}',
                      ),
                      onLongPress: () => _showActions(item),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String type) {
    return switch (type) {
      'mysql' => 'MySQL',
      'mariadb' => 'MariaDB',
      'postgresql' => 'PostgreSQL',
      'postgresql-cluster' => 'PostgreSQL Cluster',
      'mongodb' => 'MongoDB',
      'redis' => 'Redis',
      'redis-cluster' => 'Redis Cluster',
      _ => type,
    };
  }

  Future<void> _showRemote() async {
    await showAppSheet<void>(
      context: context,
      maxHeightFactor: 0.9,
      builder: (sheetContext) => const _RemoteInstancesSheet(),
    );
  }

  Future<void> _showCreateType(_DatabasesState? state) async {
    final l10n = AppLocalizations.of(context);
    final instances = state?.instances ?? const <DatabaseInstanceDto>[];
    final type = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.databases_createType, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              for (final option in [
                ('mysql', 'MySQL', TablerIcons.brand_mysql),
                ('postgresql', 'PostgreSQL', TablerIcons.database),
                ('mongodb', 'MongoDB', TablerIcons.leaf),
                ('redis', 'Redis', TablerIcons.stack_2),
              ])
                SplitListTile(
                  leading: Icon(option.$3),
                  title: option.$2,
                  onTap: () => Navigator.of(sheetContext).pop(option.$1),
                ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
        ],
      ),
    );
    if (type == null || !mounted) return;
    final created = await showDatabaseCreateSheet(
      context,
      type: type,
      instances: instances,
    );
    if (!created || !mounted) return;
    AppToast.success(context, l10n.databases_created);
    ref.invalidate(_databasesProvider);
  }

  Future<void> _showActions(DatabaseSearchItemDto item) async {
    final l10n = AppLocalizations.of(context);
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s4),
          Text(
            '${item.instanceName} · ${item.username}',
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.copy),
                title: l10n.action_copy,
                subtitle: item.name,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await Clipboard.setData(ClipboardData(text: item.name));
                  if (!context.mounted) return;
                  // ignore: use_build_context_synchronously
                  AppToast.success(context, l10n.action_copy);
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.trash),
                title: l10n.action_delete,
                danger: true,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final confirmed = await showConfirmSheet(
                    context,
                    title: l10n.action_delete,
                    message: item.name,
                    confirmLabel: l10n.action_delete,
                    requireText: item.name,
                  );
                  if (!confirmed) return;
                  try {
                    final repository = await ref.read(
                      databaseRepositoryProvider.future,
                    );
                    await repository.deleteDatabase(
                      id: item.id,
                      type: item.from,
                      database: item.name,
                      forceDelete: false,
                      deleteBackup: false,
                    );
                    if (!context.mounted) return;
                    // ignore: use_build_context_synchronously
                    AppToast.success(context, l10n.action_done);
                    ref.invalidate(_databasesProvider);
                  } catch (error) {
                    if (!context.mounted) return;
                    // ignore: use_build_context_synchronously
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
}

class _DatabaseCard extends StatelessWidget {
  const _DatabaseCard({
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  final DatabaseSearchItemDto item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return TonalCard(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.s8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppTokens.rXs),
                ),
                child: Text(
                  item.from,
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.s8),
              Expanded(
                child: Text(
                  item.name,
                  style: AppTextStyles.titleM,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Text(
            '${item.username} · ${item.format}',
            style: AppTextStyles.bodyS.copyWith(color: scheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RemoteInstancesSheet extends ConsumerStatefulWidget {
  const _RemoteInstancesSheet();

  @override
  ConsumerState<_RemoteInstancesSheet> createState() =>
      _RemoteInstancesSheetState();
}

class _RemoteInstancesSheetState extends ConsumerState<_RemoteInstancesSheet> {
  List<DatabaseInstanceDto> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      final items = <DatabaseInstanceDto>[];
      for (final type in const ['mysql', 'postgresql', 'mongodb', 'redis']) {
        try {
          final page = await repository.searchRemoteDatabases(type: type);
          items.addAll(page.items);
        } catch (_) {
          // Skip types the panel does not support.
        }
      }
      if (!mounted) return;
      setState(() => _items = items);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit([DatabaseInstanceDto? current]) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController(text: current?.name ?? '');
    final address = TextEditingController(text: current?.address ?? '');
    final port = TextEditingController(
      text: current == null || current.port == 0 ? '' : '${current.port}',
    );
    final username = TextEditingController(text: current?.username ?? '');
    final password = TextEditingController(text: current?.password ?? '');
    final description = TextEditingController(text: current?.description ?? '');
    final type = current?.type ?? 'mysql';
    bool ssl = current?.ssl ?? false;
    final saved = await showAppSheet<bool>(
      context: context,
      maxHeightFactor: 0.92,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              current == null
                  ? l10n.databases_addRemote
                  : l10n.databases_editRemote,
              style: AppTextStyles.titleL,
            ),
            const SizedBox(height: AppTokens.s16),
            AppTextField(controller: name, label: l10n.files_name),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: address, label: l10n.databases_address),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: port,
              label: l10n.databases_port,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: username, label: l10n.databases_username),
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.databases_ssl),
              value: ssl,
              onChanged: (value) => setState(() => ssl = value),
            ),
            const SizedBox(height: AppTokens.s16),
            PrimaryButton(
              label: l10n.action_save,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    );
    final nameValue = name.text.trim();
    final addressValue = address.text.trim();
    final portValue = int.tryParse(port.text.trim()) ?? 0;
    final usernameValue = username.text.trim();
    final passwordValue = password.text;
    final note = description.text.trim();
    name.dispose();
    address.dispose();
    port.dispose();
    username.dispose();
    password.dispose();
    description.dispose();
    if (saved != true || !mounted || nameValue.isEmpty) return;
    final body = <String, dynamic>{
      if (current != null) 'id': current.id,
      'name': nameValue,
      'type': type,
      'from': current?.from ?? 'remote',
      'version': current?.version ?? '',
      'database': current?.database ?? nameValue,
      'address': addressValue,
      'port': portValue,
      'username': usernameValue,
      'password': passwordValue,
      'description': note,
      'ssl': ssl,
      'timeout': current?.timeout ?? 30,
    };
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      if (await repository.checkRemoteConnection(body)) {
        await repository.updateRemoteDatabase(body);
        if (!mounted) return;
        AppToast.success(context, l10n.action_saved);
        await _load();
      } else {
        if (!mounted) return;
        AppToast.warning(context, l10n.databases_connectionFailed);
      }
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _test(DatabaseInstanceDto item) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      final ok = await repository.checkRemoteConnection({
        'name': item.name,
        'type': item.type,
        'from': item.from,
        'address': item.address,
        'port': item.port,
        'username': item.username,
        'password': item.password,
        'ssl': item.ssl,
        'timeout': item.timeout,
      });
      if (!mounted) return;
      if (ok) {
        AppToast.success(context, l10n.databases_connectionOk);
      } else {
        AppToast.warning(context, l10n.databases_connectionFailed);
      }
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _loadDatabases(DatabaseInstanceDto item) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      if (item.type.startsWith('postgresql')) {
        await repository.loadPgFromRemote(database: item.name);
      } else {
        await repository.loadFromRemote(
          from: item.from.isEmpty ? 'remote' : item.from,
          type: item.type,
          database: item.name,
        );
      }
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(DatabaseInstanceDto item) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: item.name,
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      await repository.deleteRemoteDatabase(
        id: item.id,
        database: item.name,
        forceDelete: true,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      await _load();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.databases_remoteInstances,
                style: AppTextStyles.titleL,
              ),
            ),
            TextButton.icon(
              onPressed: _loading ? null : _edit,
              icon: const Icon(TablerIcons.plus, size: 18),
              label: Text(l10n.databases_addRemote),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s8),
        if (_loading)
          const SkeletonList(itemCount: 3)
        else if (_items.isEmpty)
          EmptyState(
            compact: true,
            icon: TablerIcons.database_off,
            title: l10n.state_empty,
          )
        else
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final item in _items)
                  ListTile(
                    leading: const Icon(TablerIcons.database),
                    title: Text(item.name),
                    subtitle: Text(
                      '${item.type} · ${item.address}${item.port == 0 ? '' : ':${item.port}'}',
                    ),
                    trailing: PopupMenuButton<String>(
                      tooltip: l10n.action_more,
                      icon: const Icon(TablerIcons.dots),
                      onSelected: (value) {
                        if (value == 'load') _loadDatabases(item);
                        if (value == 'test') _test(item);
                        if (value == 'edit') _edit(item);
                        if (value == 'delete') _delete(item);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'load',
                          child: Text(l10n.databases_loadDatabases),
                        ),
                        PopupMenuItem(
                          value: 'test',
                          child: Text(l10n.databases_testConnection),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(l10n.action_edit),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(l10n.action_delete),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
