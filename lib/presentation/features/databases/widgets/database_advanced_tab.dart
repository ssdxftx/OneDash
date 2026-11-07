import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/error_toast.dart';
import '../../log/screens/log_preview_page.dart';

class DatabaseAdvancedTab extends ConsumerWidget {
  const DatabaseAdvancedTab({
    super.key,
    required this.type,
    required this.instance,
    required this.databaseName,
    this.serverId = 0,
    this.from = 'local',
  });

  final String type;
  final String instance;
  final String databaseName;
  final int serverId;
  final String from;

  bool get _isRedis => type.toLowerCase() == 'redis';
  bool get _isMysql => const ['mysql', 'mariadb'].contains(type.toLowerCase());
  bool get _isPg => type.toLowerCase() == 'postgresql';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.all(context.pagePadding),
      children: [
        TonalCard(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(TablerIcons.file_code),
                title: Text(l10n.databases_configFile),
                subtitle: Text(l10n.databases_configFileHint),
                trailing: const Icon(TablerIcons.chevron_right),
                onTap: () => _editConfig(context, ref),
              ),
              if (_isMysql || _isPg)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(TablerIcons.file_alert),
                  title: Text(l10n.databases_slowLog),
                  subtitle: Text(l10n.databases_slowLogHint),
                  trailing: const Icon(TablerIcons.chevron_right),
                  onTap: () => _showSlowLog(context, ref),
                ),
              if (_isMysql)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(TablerIcons.adjustments),
                  title: Text(l10n.databases_variables),
                  subtitle: Text(l10n.databases_variablesHint),
                  trailing: const Icon(TablerIcons.chevron_right),
                  onTap: () => _editVariables(context, ref),
                ),
            ],
          ),
        ),
        if (_isRedis) ...[
          const SizedBox(height: AppTokens.s24),
          Text(l10n.databases_redis, style: AppTextStyles.titleS),
          const SizedBox(height: AppTokens.s8),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.activity),
                title: l10n.databases_redisStatus,
                trailing: const Icon(TablerIcons.chevron_right),
                onTap: () => _showRedisStatus(context, ref),
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.settings),
                title: l10n.databases_redisConfig,
                trailing: const Icon(TablerIcons.chevron_right),
                onTap: () => _editRedisConf(context, ref),
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.key),
                title: l10n.databases_redisPassword,
                trailing: const Icon(TablerIcons.chevron_right),
                onTap: () => _changeRedisPassword(context, ref),
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.database_export),
                title: l10n.databases_redisPersistence,
                trailing: const Icon(TablerIcons.chevron_right),
                onTap: () => _editRedisPersistence(context, ref),
              ),
              if (serverId > 0) ...[
                SplitListTile(
                  leading: const Icon(TablerIcons.terminal_2),
                  title: l10n.databases_redisCommand,
                  subtitle: l10n.databases_redis,
                  trailing: const Icon(TablerIcons.chevron_right),
                  onTap: () => context.push(
                    '/s/$serverId/terminal'
                    '?redis=${Uri.encodeComponent(instance)}'
                    '&redisFrom=${Uri.encodeComponent(from)}',
                  ),
                ),
                SplitListTile(
                  leading: const Icon(TablerIcons.key),
                  title: l10n.databases_redisKeys,
                  subtitle: 'SCAN 0 COUNT 100',
                  trailing: const Icon(TablerIcons.chevron_right),
                  onTap: () => context.push(
                    '/s/$serverId/terminal'
                    '?redis=${Uri.encodeComponent(instance)}'
                    '&redisFrom=${Uri.encodeComponent(from)}'
                    '&redisCommand=${Uri.encodeComponent('SCAN 0 COUNT 100')}',
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _editVariables(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      final vars = await repository.loadVariables(type: type, name: instance);
      final values = <String, String>{
        'max_connections': vars.maxConnections ?? '',
        'innodb_buffer_pool_size': vars.innodbBufferPoolSize ?? '',
        'innodb_log_buffer_size': vars.innodbLogBufferSize ?? '',
        'key_buffer_size': vars.keyBufferSize ?? '',
        'join_buffer_size': vars.joinBufferSize ?? '',
        'read_buffer_size': vars.readBufferSize ?? '',
        'read_rnd_buffer_size': vars.readRndBufferSize ?? '',
        'sort_buffer_size': vars.sortBufferSize ?? '',
        'table_open_cache': vars.tableOpenCache ?? '',
        'thread_cache_size': vars.threadCacheSize ?? '',
        'thread_stack': vars.threadStackSize ?? '',
        'tmp_table_size': vars.tmpTableSize ?? '',
        'long_query_time': vars.longQueryTime ?? '',
        'slow_query_log': vars.slowQueryLog ?? '',
      };
      if (!context.mounted) return;
      final controllers = {
        for (final entry in values.entries)
          entry.key: TextEditingController(text: entry.value),
      };
      final saved = await pushFormPage<bool>(
        context,
        Builder(
          builder: (pageContext) => SimpleFormPage(
            title: l10n.databases_variables,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              for (final entry in controllers.entries) ...[
                AppTextField(controller: entry.value, label: entry.key),
                const SizedBox(height: AppTokens.s8),
              ],
            ],
          ),
        ),
      );
      final request = [
        for (final entry in controllers.entries)
          {'param': entry.key, 'value': entry.value.text.trim()},
      ];
      for (final controller in controllers.values) {
        controller.dispose();
      }
      if (saved != true || !context.mounted) return;
      await repository.updateVariables(
        type: type,
        database: instance,
        variables: request,
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showRedisStatus(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      final status = await repository.getRedisStatus(
        type: type,
        name: instance,
      );
      if (!context.mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.92,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.databases_redisStatus, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            ...status.entries.map(
              (entry) => ListTile(
                dense: true,
                title: Text(entry.key),
                trailing: Text(entry.value),
              ),
            ),
            const SizedBox(height: AppTokens.s8),
            SecondaryButton(
              label: l10n.databases_installRedisCli,
              onPressed: () async {
                try {
                  await repository.installRedisCli();
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
      );
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editConfig(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      final content = await repository.loadConfigFile(
        type: type,
        name: instance,
      );
      if (!context.mounted) return;
      final controller = TextEditingController(text: content);
      final saved = await pushFormPage<bool>(
        context,
        Builder(
          builder: (pageContext) => SimpleFormPage(
            title: l10n.databases_configFile,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [AppTextField(controller: controller, maxLines: 16)],
          ),
        ),
      );
      final text = controller.text;
      controller.dispose();
      if (saved != true || !context.mounted) return;
      await repository.updateConfigFile(
        type: type,
        database: instance,
        file: text,
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showSlowLog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      final log = await repository.readSlowLog(type: type, name: instance);
      if (!context.mounted) return;
      await Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => LogPreviewPage(
            title: l10n.databases_slowLog,
            subtitle: log.path,
            sources: [
              LogSourceOption(
                label: l10n.databases_slowLog,
                load: () async {
                  final current = await repository.readSlowLog(
                    type: type,
                    name: instance,
                  );
                  return current.lines;
                },
              ),
            ],
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editRedisConf(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      final conf = await repository.getRedisConf(type: type, name: instance);
      if (!context.mounted) return;
      final timeout = TextEditingController(text: conf.timeout);
      final maxclients = TextEditingController(text: conf.maxclients);
      final maxmemory = TextEditingController(text: conf.maxmemory);
      final saved = await pushFormPage<bool>(
        context,
        Builder(
          builder: (pageContext) => SimpleFormPage(
            title: l10n.databases_redisConfig,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              AppTextField(
                controller: timeout,
                label: 'timeout',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: maxclients,
                label: 'maxclients',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(controller: maxmemory, label: 'maxmemory'),
            ],
          ),
        ),
      );
      final values = (
        timeout.text.trim(),
        maxclients.text.trim(),
        maxmemory.text.trim(),
      );
      timeout.dispose();
      maxclients.dispose();
      maxmemory.dispose();
      if (saved != true || !context.mounted) return;
      await repository.updateRedisConf(
        dbType: type,
        database: instance,
        timeout: values.$1,
        maxclients: values.$2,
        maxmemory: values.$3,
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _changeRedisPassword(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final value = await pushFormPage<String>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.databases_redisPassword,
          onSave: () async => Navigator.of(pageContext).pop(controller.text),
          children: [
            AppTextField(
              controller: controller,
              obscure: true,
              autofocus: true,
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty || !context.mounted) return;
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      await repository.changeRedisPassword(database: instance, value: value);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editRedisPersistence(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      final persistence = await repository.getRedisPersistence(
        type: type,
        name: instance,
      );
      if (!context.mounted) return;
      final save = TextEditingController(text: persistence.save);
      final appendfsync = TextEditingController(text: persistence.appendfsync);
      bool aof = persistence.aofEnabled == 'yes';
      bool rdb = persistence.rdbEnabled == 'yes';
      final saved = await pushFormPage<bool>(
        context,
        StatefulBuilder(
          builder: (pageContext, setState) => SimpleFormPage(
            title: l10n.databases_redisPersistence,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('AOF'),
                value: aof,
                onChanged: (value) => setState(() => aof = value),
              ),
              AppTextField(controller: appendfsync, label: 'appendfsync'),
              const SizedBox(height: AppTokens.s12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('RDB'),
                value: rdb,
                onChanged: (value) => setState(() => rdb = value),
              ),
              AppTextField(controller: save, label: 'save'),
            ],
          ),
        ),
      );
      final append = appendfsync.text.trim();
      final saveValue = save.text.trim();
      appendfsync.dispose();
      save.dispose();
      if (saved != true || !context.mounted) return;
      await repository.updateRedisAofPersistence(
        dbType: type,
        database: instance,
        appendonly: aof ? 'yes' : 'no',
        appendfsync: append,
      );
      await repository.updateRedisRdbPersistence(
        dbType: type,
        database: instance,
        save: rdb ? saveValue : '',
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}
