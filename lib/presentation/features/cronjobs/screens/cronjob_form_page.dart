import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/cronjob/cronjob_dto.dart';
import '../../../../data/dto/cronjob/cronjob_form_data_dto.dart';
import '../../../../data/repositories_impl/backup_account_repository_impl.dart';
import '../../../../data/repositories_impl/cronjob_repository_impl.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/form_footer.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/error_toast.dart';
import '../providers/cronjobs_provider.dart';

final _backupAccountOptionsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final repository = await ref.watch(
        backupAccountRepositoryProvider.future,
      );
      final result = await repository.searchAccounts(page: 1, pageSize: 100);
      final items = result['items'];
      if (items is! List) return const [];
      return items
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList(growable: false);
    }, name: 'cronjobBackupAccountOptionsProvider');

final _databaseItemsProvider = FutureProvider.autoDispose
    .family<List<DatabaseItemDto>, String>((ref, dbType) async {
      final repository = await ref.watch(databaseRepositoryProvider.future);
      return repository.loadDatabaseItems(dbType);
    }, name: 'cronjobDatabaseItemsProvider');

class CronjobFormPage extends ConsumerStatefulWidget {
  const CronjobFormPage({
    super.key,
    required this.serverId,
    this.cronjobId,
    this.embedded = false,
  });

  final int serverId;
  final int? cronjobId;
  final bool embedded;

  bool get isEditing => cronjobId != null;

  @override
  ConsumerState<CronjobFormPage> createState() => _CronjobFormPageState();
}

class _CronjobFormPageState extends ConsumerState<CronjobFormPage> {
  final _name = TextEditingController();
  final _spec = TextEditingController(text: '30 1 * * *');
  final _script = TextEditingController();
  final _sourceDir = TextEditingController();
  final _urlItems = <_UrlFields>[_UrlFields()];
  final _website = TextEditingController();
  final _dbType = TextEditingController(text: 'mysql');
  final _dbName = TextEditingController();
  final _appId = TextEditingController();
  final _scopes = TextEditingController();
  final _retainCopies = TextEditingController(text: '3');
  final _retryTimes = TextEditingController(text: '3');
  final _timeout = TextEditingController(text: '60');

  String _type = 'shell';
  String _scriptMode = 'input';
  int? _scriptID;
  bool _isDir = true;
  bool _withImage = false;
  bool _submitting = false;
  bool _loaded = false;
  int? _backupAccountId;
  int? _groupID;
  String? _secret;
  String? _exclusionRules;
  String? _args;
  String? _executor;
  String? _command;
  String? _containerName;
  String? _user;
  List<int> _snapshotIgnoreAppIDs = const [];
  int _alertCount = 0;
  String _alertTitle = '';
  String _alertMethod = '';
  String _alertTriggerMode = '';

  static const _types = [
    'shell',
    'log',
    'curl',
    'website',
    'database',
    'directory',
    'app',
    'snapshot',
    'cleanLog',
    'clean',
    'ntp',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.cronjobId != null) _load();
  }

  Future<void> _load() async {
    try {
      final repository = await ref.read(cronjobRepositoryProvider.future);
      final item = await repository.getCronjobInfo(widget.cronjobId!);
      if (!mounted) return;
      setState(() {
        _type = item.type.isEmpty ? 'shell' : item.type;
        _name.text = item.name;
        _spec.text = item.spec;
        _script.text = item.script ?? item.command ?? '';
        _scriptMode = item.scriptMode ?? 'input';
        _scriptID = item.scriptID;
        _sourceDir.text = item.sourceDir ?? '';
        for (final field in _urlItems) {
          field.dispose();
        }
        _urlItems.clear();
        final existing = item.urlItems;
        if (existing != null && existing.isNotEmpty) {
          _urlItems.addAll(existing.map((entry) => _UrlFields()..fill(entry)));
        } else if ((item.url ?? '').trim().isNotEmpty) {
          _urlItems.add(_UrlFields()..url.text = item.url!.trim());
        }
        if (_urlItems.isEmpty) _urlItems.add(_UrlFields());
        _website.text = item.website ?? '';
        _dbType.text = item.dbType ?? 'mysql';
        _dbName.text = item.dbName ?? '';
        _appId.text = item.appID ?? '';
        _scopes.text = item.scopes?.join(',') ?? '';
        _retainCopies.text = '${item.retainCopies}';
        _retryTimes.text = '${item.retryTimes}';
        _timeout.text = '${item.timeout}';
        _isDir = item.isDir ?? true;
        _withImage = item.snapshotRule?.withImage ?? false;
        _snapshotIgnoreAppIDs = item.snapshotRule?.ignoreAppIDs ?? const [];
        _backupAccountId = item.downloadAccountID;
        _groupID = item.groupID;
        _secret = item.secret;
        _exclusionRules = item.exclusionRules;
        _args = item.args;
        _executor = item.executor;
        _command = item.command;
        _containerName = item.containerName;
        _user = item.user;
        _alertCount = item.alertCount;
        _alertTitle = item.alertTitle;
        _alertMethod = item.alertMethod;
        _alertTriggerMode = item.alertTriggerMode;
        _loaded = true;
      });
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _spec.dispose();
    _script.dispose();
    _sourceDir.dispose();
    for (final field in _urlItems) {
      field.dispose();
    }
    _website.dispose();
    _dbType.dispose();
    _dbName.dispose();
    _appId.dispose();
    _scopes.dispose();
    _retainCopies.dispose();
    _retryTimes.dispose();
    _timeout.dispose();
    super.dispose();
  }

  Future<void> _pickScript() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(cronjobRepositoryProvider.future);
      final options = await repository.loadScriptOptions();
      if (!mounted) return;
      if (options.isEmpty) {
        AppToast.warning(context, l10n.commandLibrary_empty);
        return;
      }
      final selected = await showSelectionMenu<ScriptOptionDto>(
        context,
        title: l10n.cronjobs_pickScript,
        options: [
          for (final option in options)
            SelectionOption(label: option.name, value: option),
        ],
      );
      if (selected == null || !mounted) return;
      setState(() {
        _scriptMode = 'library';
        _scriptID = selected.id;
        _script.text = selected.name;
      });
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    final spec = _spec.text.trim();
    if (name.isEmpty) {
      AppToast.warning(context, l10n.cronjobs_nameRequired);
      return;
    }
    if (spec.isEmpty) {
      AppToast.warning(context, l10n.cronjobs_specRequired);
      return;
    }
    if (_type == 'shell' &&
        _scriptMode == 'input' &&
        _script.text.trim().isEmpty) {
      AppToast.warning(context, l10n.cronjobs_scriptRequired);
      return;
    }
    final urlItems = _urlItems
        .map(
          (field) => CronjobUrlItemDto(
            url: field.url.text.trim(),
            header: field.header.text.trim(),
          ),
        )
        .where((item) => item.url.isNotEmpty)
        .toList();
    if (_type == 'curl' && urlItems.isEmpty) {
      AppToast.warning(context, l10n.cronjobs_urlRequired);
      return;
    }
    setState(() => _submitting = true);
    try {
      final repository = await ref.read(cronjobRepositoryProvider.future);
      final request = CronjobCreateReq(
        id: widget.cronjobId,
        name: name,
        type: _type,
        spec: spec,
        specCustom: true,
        scriptMode: _type == 'shell' ? _scriptMode : null,
        script: _type == 'shell' && _scriptMode == 'input'
            ? _script.text
            : null,
        scriptID: _type == 'shell' && _scriptMode == 'library'
            ? _scriptID
            : null,
        sourceDir: _sourceDir.text.trim().isEmpty
            ? null
            : _sourceDir.text.trim(),
        url: _type == 'curl' && urlItems.isNotEmpty
            ? urlItems.map((item) => item.url).join(',')
            : null,
        urlItems: _type == 'curl' ? urlItems : null,
        website: _website.text.trim().isEmpty ? null : _website.text.trim(),
        dbType: _type == 'database' ? _dbType.text.trim() : null,
        dbName: _dbName.text.trim().isEmpty ? null : _dbName.text.trim(),
        appID: _appId.text.trim().isEmpty ? null : _appId.text.trim(),
        isDir: _type == 'directory' ? _isDir : null,
        scopes: _type == 'cleanLog'
            ? _scopes.text
                  .split(',')
                  .map((item) => item.trim())
                  .where((item) => item.isNotEmpty)
                  .toList()
            : null,
        snapshotRule: _type == 'snapshot'
            ? SnapshotRuleDto(
                withImage: _withImage,
                ignoreAppIDs: _snapshotIgnoreAppIDs,
              )
            : null,
        retainCopies: int.tryParse(_retainCopies.text.trim()),
        retryTimes: int.tryParse(_retryTimes.text.trim()),
        timeout: int.tryParse(_timeout.text.trim()),
        sourceAccountIDs: _backupAccountId == null ? null : '$_backupAccountId',
        downloadAccountID: _backupAccountId,
        groupID: _groupID,
        secret: _secret,
        exclusionRules: _exclusionRules,
        args: _args,
        executor: _executor,
        command: _command,
        containerName: _containerName,
        user: _user,
        alertCount: _alertCount,
        alertTitle: _alertTitle,
        alertMethod: _alertMethod,
        alertTriggerMode: _alertTriggerMode,
      );
      if (widget.isEditing) {
        await repository.updateCronjob(request);
      } else {
        await repository.createCronjob(request);
      }
      ref.invalidate(cronjobsProvider);
      if (!mounted) return;
      AppToast.success(
        context,
        widget.isEditing ? l10n.cronjobs_updated : l10n.cronjobs_created,
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final children = <Widget>[
      SectionHeader(title: l10n.cronjobs_basic),
      TonalCard(
        child: Column(
          children: [
            AppTextField(
              controller: _name,
              label: l10n.cronjobs_name,
              hint: 'daily-backup',
            ),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: InputDecoration(labelText: l10n.cronjobs_type),
              items: [
                for (final type in _types)
                  DropdownMenuItem(
                    value: type,
                    child: Text(_typeLabel(type, l10n)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: _spec,
              label: l10n.cronjobs_spec,
              hint: '30 1 * * *',
              helper: l10n.cronjobs_specHint,
            ),
          ],
        ),
      ),
      const SizedBox(height: AppTokens.s24),
      SectionHeader(title: l10n.cronjobs_taskConfig),
      TonalCard(
        child: Column(
          children: [
            if (_type == 'shell') ...[
              AppTextField(
                controller: _script,
                label: l10n.cronjobs_script,
                hint: '#!/bin/bash\n...',
                maxLines: 8,
                onChanged: (_) {
                  if (_scriptMode != 'input') {
                    setState(() {
                      _scriptMode = 'input';
                      _scriptID = null;
                    });
                  }
                },
              ),
              const SizedBox(height: AppTokens.s8),
              SecondaryButton(
                label: l10n.cronjobs_pickScript,
                icon: TablerIcons.script,
                onPressed: _pickScript,
              ),
            ],
            if (_type == 'log')
              AppTextField(
                controller: _sourceDir,
                label: l10n.cronjobs_logFiles,
                hint: '/var/log/nginx/access.log',
                helper: l10n.cronjobs_logFilesHint,
              ),
            if (_type == 'curl') ...[
              for (var index = 0; index < _urlItems.length; index++) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _urlItems[index].url,
                        label: l10n.cronjobs_url,
                        hint: 'https://example.com/health',
                      ),
                    ),
                    const SizedBox(width: AppTokens.s8),
                    Expanded(
                      child: AppTextField(
                        controller: _urlItems[index].header,
                        label: l10n.cronjobs_urlHeader,
                        hint: 'Mozilla/5.0',
                      ),
                    ),
                    if (_urlItems.length > 1)
                      IconButton(
                        tooltip: l10n.action_delete,
                        onPressed: () =>
                            setState(() => _urlItems.removeAt(index).dispose()),
                        icon: const Icon(TablerIcons.trash),
                      ),
                  ],
                ),
                const SizedBox(height: AppTokens.s8),
              ],
              SecondaryButton(
                label: l10n.action_add,
                icon: TablerIcons.plus,
                onPressed: () => setState(() => _urlItems.add(_UrlFields())),
              ),
            ],
            if (_type == 'website')
              AppTextField(
                controller: _website,
                label: l10n.cronjobs_website,
                hint: 'example.com',
              ),
            if (_type == 'database') ...[
              DropdownButtonFormField<String>(
                initialValue: _dbType.text,
                decoration: InputDecoration(
                  labelText: l10n.cronjobs_databaseType,
                ),
                items: [
                  const DropdownMenuItem(value: 'mysql', child: Text('MySQL')),
                  const DropdownMenuItem(
                    value: 'mariadb',
                    child: Text('MariaDB'),
                  ),
                  const DropdownMenuItem(
                    value: 'postgresql',
                    child: Text('PostgreSQL'),
                  ),
                  DropdownMenuItem(
                    value: 'mysql-cluster',
                    child: Text(l10n.databases_typeMysqlCluster),
                  ),
                  DropdownMenuItem(
                    value: 'postgresql-cluster',
                    child: Text(l10n.databases_typePostgresqlCluster),
                  ),
                  const DropdownMenuItem(value: 'redis', child: Text('Redis')),
                  const DropdownMenuItem(
                    value: 'mongodb',
                    child: Text('MongoDB'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _dbType.text = value;
                      _dbName.clear();
                    });
                  }
                },
              ),
              const SizedBox(height: AppTokens.s12),
              ref
                  .watch(_databaseItemsProvider(_dbType.text))
                  .when(
                    loading: () => const LinearProgressIndicator(),
                    error: (error, _) => AppTextField(
                      controller: _dbName,
                      label: l10n.cronjobs_databaseName,
                      hint: 'app_db',
                      helper: describeError(error, l10n),
                    ),
                    data: (items) {
                      if (items.isEmpty) {
                        return AppTextField(
                          controller: _dbName,
                          label: l10n.cronjobs_databaseName,
                          hint: 'app_db',
                        );
                      }
                      final values = [for (final item in items) item.name];
                      final current = _dbName.text.trim();
                      if (current.isNotEmpty && !values.contains(current)) {
                        values.add(current);
                      }
                      return DropdownButtonFormField<String>(
                        initialValue: current.isEmpty ? null : current,
                        decoration: InputDecoration(
                          labelText: l10n.cronjobs_databaseName,
                        ),
                        items: [
                          for (final value in values)
                            DropdownMenuItem(value: value, child: Text(value)),
                        ],
                        onChanged: (value) =>
                            setState(() => _dbName.text = value ?? ''),
                      );
                    },
                  ),
            ],
            if (_type == 'directory') ...[
              AppTextField(
                controller: _sourceDir,
                label: _isDir ? l10n.cronjobs_directory : l10n.cronjobs_files,
                hint: _isDir ? '/opt/data' : '/opt/data/file.txt',
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.cronjobs_backupDirectory),
                value: _isDir,
                onChanged: (value) => setState(() => _isDir = value),
              ),
            ],
            if (_type == 'app')
              AppTextField(
                controller: _appId,
                label: l10n.cronjobs_app,
                hint: 'app-install-id',
              ),
            if (_type == 'snapshot')
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.cronjobs_withImage),
                value: _withImage,
                onChanged: (value) => setState(() => _withImage = value),
              ),
            if (_type == 'cleanLog')
              AppTextField(
                controller: _scopes,
                label: l10n.cronjobs_scopes,
                hint: 'system,ssh',
                helper: l10n.cronjobs_scopesHint,
              ),
            if (_type == 'clean' || _type == 'ntp')
              Text(
                _type == 'ntp'
                    ? l10n.cronjobs_ntpHint
                    : l10n.cronjobs_cleanHint,
                style: AppTextStyles.bodyS.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
      if (const {
        'website',
        'database',
        'directory',
        'app',
      }.contains(_type)) ...[
        const SizedBox(height: AppTokens.s24),
        SectionHeader(title: l10n.backups_accounts),
        TonalCard(
          child: Consumer(
            builder: (context, ref, _) {
              final accounts = ref
                  .watch(_backupAccountOptionsProvider)
                  .valueOrNull;
              final list = accounts ?? const <Map<String, dynamic>>[];
              final current = list.where(
                (item) => item['id'] == _backupAccountId,
              );
              final name = current.isEmpty
                  ? (list.isEmpty
                        ? l10n.backups_noAccounts
                        : l10n.panelSettings_notSet)
                  : '${current.first['name'] ?? _backupAccountId}';
              return SplitListTile(
                title: l10n.backups_accounts,
                subtitle: name,
                onTap: list.isEmpty
                    ? null
                    : () async {
                        final selected = await showSelectionMenu<int>(
                          context,
                          options: [
                            for (final item in list)
                              if (item['id'] is num)
                                SelectionOption<int>(
                                  label: '${item['name'] ?? item['id']}',
                                  value: (item['id'] as num).toInt(),
                                ),
                          ],
                        );
                        if (selected != null && mounted) {
                          setState(() => _backupAccountId = selected);
                        }
                      },
              );
            },
          ),
        ),
      ],
      const SizedBox(height: AppTokens.s24),
      SectionHeader(title: l10n.cronjobs_execution),
      TonalCard(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _retainCopies,
                    label: l10n.cronjobs_retainCopies,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: AppTextField(
                    controller: _retryTimes,
                    label: l10n.cronjobs_retryTimes,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: _timeout,
              label: l10n.cronjobs_timeout,
              keyboardType: TextInputType.number,
              helper: l10n.cronjobs_timeoutHint,
            ),
          ],
        ),
      ),
    ];
    if (widget.embedded) {
      return FormSheet(
        title: widget.isEditing ? l10n.cronjobs_edit : l10n.cronjobs_create,
        onSave: _submit,
        saving: _submitting || (widget.isEditing && !_loaded),
        saveLabel: widget.isEditing ? l10n.action_save : l10n.cronjobs_create,
        children: children,
      );
    }
    return Scaffold(
      appBar: AppBarLarge(
        title: widget.isEditing ? l10n.cronjobs_edit : l10n.cronjobs_create,
        leading: IconButton(
          tooltip: l10n.action_close,
          onPressed: () => context.pop(),
          icon: const Icon(TablerIcons.x),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s8,
          AppTokens.s16,
          AppTokens.s32,
        ),
        children: children,
      ),
      bottomNavigationBar: FormFooter(
        child: PrimaryButton(
          label: _submitting
              ? l10n.cronjobs_saving
              : widget.isEditing
              ? l10n.action_save
              : l10n.cronjobs_create,
          loading: _submitting || (widget.isEditing && !_loaded),
          onPressed: _submitting || (widget.isEditing && !_loaded)
              ? null
              : _submit,
        ),
      ),
    );
  }

  String _typeLabel(String type, AppLocalizations l10n) {
    return switch (type) {
      'shell' => l10n.cronjobs_typeShell,
      'log' => l10n.cronjobs_typeLog,
      'curl' => l10n.cronjobs_typeCurl,
      'website' => l10n.cronjobs_typeWebsite,
      'database' => l10n.cronjobs_typeDatabase,
      'directory' => l10n.cronjobs_typeDirectory,
      'app' => l10n.cronjobs_typeApp,
      'snapshot' => l10n.cronjobs_typeSnapshot,
      'cleanLog' => l10n.cronjobs_typeCleanLog,
      'clean' => l10n.cronjobs_typeClean,
      'ntp' => l10n.cronjobs_typeNtp,
      _ => type,
    };
  }
}

class _UrlFields {
  final url = TextEditingController();
  final header = TextEditingController();

  void fill(CronjobUrlItemDto item) {
    url.text = item.url;
    header.text = item.header;
  }

  void dispose() {
    url.dispose();
    header.dispose();
  }
}

Future<void> showCronjobFormSheet(
  BuildContext context, {
  required int serverId,
  int? cronjobId,
}) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.94,
    builder: (sheetContext) => SizedBox(
      height: MediaQuery.sizeOf(sheetContext).height * 0.78,
      child: CronjobFormPage(
        serverId: serverId,
        cronjobId: cronjobId,
        embedded: true,
      ),
    ),
  );
}
