import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/database/database_instance_dto.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/states/error_toast.dart';

Future<bool> showDatabaseCreateSheet(
  BuildContext context, {
  required String type,
  required List<DatabaseInstanceDto> instances,
}) async {
  final created = await pushFormPage<bool>(
    context,
    DatabaseCreatePage(type: type, instances: instances),
  );
  return created ?? false;
}

class DatabaseCreatePage extends StatelessWidget {
  const DatabaseCreatePage({
    super.key,
    required this.type,
    required this.instances,
  });

  final String type;
  final List<DatabaseInstanceDto> instances;

  @override
  Widget build(BuildContext context) {
    return DatabaseCreateSheet(type: type, instances: instances);
  }
}

class DatabaseCreateSheet extends ConsumerStatefulWidget {
  const DatabaseCreateSheet({
    super.key,
    required this.type,
    required this.instances,
  });

  final String type;
  final List<DatabaseInstanceDto> instances;

  @override
  ConsumerState<DatabaseCreateSheet> createState() =>
      _DatabaseCreateSheetState();
}

class _DatabaseCreateSheetState extends ConsumerState<DatabaseCreateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _host = TextEditingController(text: '%');
  final _address = TextEditingController();
  final _port = TextEditingController(text: '6379');

  DatabaseInstanceDto? _instance;
  List<FormatCollationOption> _formats = const [];
  String? _format;
  String? _collation;
  String _mongoPermission = 'readWrite';
  bool _superUser = true;
  bool _saving = false;
  bool _loadingFormats = false;

  bool get _isMysql => widget.type == 'mysql' || widget.type == 'mariadb';
  bool get _isPg => widget.type.startsWith('postgresql');
  bool get _isMongo => widget.type == 'mongodb';
  bool get _isRedis => widget.type == 'redis';

  List<DatabaseInstanceDto> get _candidates => widget.instances
      .where((item) {
        if (_isPg) return item.type.startsWith('postgresql');
        return item.type == widget.type;
      })
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    final candidates = _candidates;
    if (candidates.isNotEmpty) {
      _instance = candidates.first;
      if (_isMysql) _loadFormats();
    }
    if (_isRedis) _loadRedisPort();
  }

  Future<void> _loadRedisPort() async {
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      final port = await repository.getInstalledAppPort(type: 'redis');
      if (!mounted || port <= 0) return;
      _port.text = '$port';
    } catch (_) {
      // 未安装 Redis 时沿用默认端口，由提交阶段给出真实错误。
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _password.dispose();
    _host.dispose();
    _address.dispose();
    _port.dispose();
    super.dispose();
  }

  Future<void> _loadFormats() async {
    final instance = _instance;
    if (instance == null) return;
    setState(() => _loadingFormats = true);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      final formats = await repository.getFormatOptions(instance.database);
      if (!mounted) return;
      setState(() {
        _formats = formats;
        _format = formats.isEmpty ? null : formats.first.format;
        _collation = formats.isEmpty || formats.first.collations.isEmpty
            ? null
            : formats.first.collations.first;
      });
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loadingFormats = false);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_isRedis && _instance == null) return;
    setState(() => _saving = true);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      if (_isRedis) {
        await repository.createRemoteDatabase({
          'name': _name.text.trim(),
          'type': 'redis',
          'from': 'remote',
          'version': '7',
          'address': _address.text.trim(),
          'port': int.tryParse(_port.text.trim()) ?? 6379,
          'username': _username.text.trim(),
          'password': _password.text,
          'ssl': false,
          'timeout': 30,
          'description': '',
        });
      } else {
        final instance = _instance!;
        final body = <String, dynamic>{
          'name': _name.text.trim(),
          'from': instance.from,
          'database': instance.database,
          'username': _username.text.trim(),
          'password': _password.text,
          'description': '',
        };
        if (_isMysql) {
          body['format'] = _format ?? 'utf8mb4';
          body['collation'] = _collation ?? '';
          body['permission'] = _host.text.trim().isEmpty
              ? '%'
              : _host.text.trim();
          await repository.createDatabase(body);
        } else if (_isPg) {
          body['format'] = 'UTF8';
          body['superUser'] = _superUser;
          await repository.createPgDatabase(body);
        } else if (_isMongo) {
          body['permission'] = _mongoPermission;
          await repository.createMongoDatabase(body);
        }
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _isRedis ? l10n.databases_redisRemote : l10n.databases_create;
    return SimpleFormPage(
      title: title,
      subtitle: widget.type,
      formKey: _formKey,
      saving: _saving,
      onSave: _submit,
      children: [
        if (_isRedis) ..._redisFields(l10n) else ..._instanceFields(l10n),
      ],
    );
  }

  List<Widget> _instanceFields(AppLocalizations l10n) {
    final candidates = _candidates;
    if (candidates.isEmpty) {
      return [
        Text(
          l10n.databases_noInstance,
          style: AppTextStyles.bodyM.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
      ];
    }
    return [
      if (candidates.length > 1) ...[
        DropdownButtonFormField<DatabaseInstanceDto>(
          initialValue: _instance,
          decoration: InputDecoration(labelText: l10n.databases_instance),
          items: [
            for (final item in candidates)
              DropdownMenuItem(value: item, child: Text(item.database)),
          ],
          onChanged: (value) {
            setState(() => _instance = value);
            if (_isMysql) _loadFormats();
          },
        ),
        const SizedBox(height: AppTokens.s16),
      ],
      AppTextField(
        controller: _name,
        label: l10n.databases_databaseName,
        autofocus: true,
        validator: (value) => (value == null || value.trim().isEmpty)
            ? l10n.databases_nameRequired
            : null,
      ),
      if (_isMysql) ...[
        const SizedBox(height: AppTokens.s16),
        if (_loadingFormats)
          const LinearProgressIndicator()
        else ...[
          DropdownButtonFormField<String>(
            initialValue: _format,
            decoration: InputDecoration(labelText: l10n.databases_charset),
            items: [
              for (final format in _formats)
                DropdownMenuItem(
                  value: format.format,
                  child: Text(format.format),
                ),
            ],
            onChanged: (value) {
              final matched = _formats.where((item) => item.format == value);
              final option = matched.isEmpty ? null : matched.first;
              setState(() {
                _format = value;
                _collation = option == null || option.collations.isEmpty
                    ? null
                    : option.collations.first;
              });
            },
          ),
          if (_collation != null) ...[
            const SizedBox(height: AppTokens.s16),
            DropdownButtonFormField<String>(
              initialValue: _collation,
              decoration: InputDecoration(labelText: l10n.databases_collation),
              items: [
                for (final collation
                    in _formats
                        .where((item) => item.format == _format)
                        .expand((item) => item.collations))
                  DropdownMenuItem(value: collation, child: Text(collation)),
              ],
              onChanged: (value) => setState(() => _collation = value),
            ),
          ],
        ],
      ],
      if (_isPg) ...[
        const SizedBox(height: AppTokens.s16),
        DropdownButtonFormField<String>(
          initialValue: 'UTF8',
          decoration: InputDecoration(labelText: l10n.databases_template),
          items: const [DropdownMenuItem(value: 'UTF8', child: Text('UTF8'))],
          onChanged: (_) {},
        ),
      ],
      const SizedBox(height: AppTokens.s24),
      AppTextField(
        controller: _username,
        label: l10n.databases_username,
        validator: (value) {
          if (_isMysql) return null;
          return (value == null || value.trim().isEmpty)
              ? l10n.databases_usernameRequired
              : null;
        },
      ),
      const SizedBox(height: AppTokens.s16),
      AppTextField(
        controller: _password,
        label: l10n.databases_password,
        obscure: true,
        validator: (value) {
          if (_isMysql && _username.text.trim().isEmpty) return null;
          return (value == null || value.isEmpty)
              ? l10n.databases_passwordRequired
              : null;
        },
      ),
      const SizedBox(height: AppTokens.s24),
      if (_isMysql)
        AppTextField(
          controller: _host,
          label: l10n.databases_host,
          helper: l10n.databases_hostHint,
        ),
      if (_isMongo)
        DropdownButtonFormField<String>(
          initialValue: _mongoPermission,
          decoration: InputDecoration(labelText: l10n.databases_permission),
          items: [
            DropdownMenuItem(
              value: 'read',
              child: Text(l10n.databases_permissionRead),
            ),
            DropdownMenuItem(
              value: 'readWrite',
              child: Text(l10n.databases_permissionReadWrite),
            ),
            DropdownMenuItem(
              value: 'dbOwner',
              child: Text(l10n.databases_permissionDbOwner),
            ),
            DropdownMenuItem(
              value: 'userAdmin',
              child: Text(l10n.databases_permissionUserAdmin),
            ),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _mongoPermission = value);
          },
        ),
      if (_isPg)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.databases_superUser, style: AppTextStyles.bodyM),
          value: _superUser,
          onChanged: (value) => setState(() => _superUser = value),
        ),
    ];
  }

  List<Widget> _redisFields(AppLocalizations l10n) {
    return [
      Text(
        l10n.databases_redisHint,
        style: AppTextStyles.bodyS.copyWith(
          color: context.scheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: AppTokens.s16),
      AppTextField(
        controller: _name,
        label: l10n.databases_instance,
        autofocus: true,
        validator: (value) => (value == null || value.trim().isEmpty)
            ? l10n.databases_nameRequired
            : null,
      ),
      const SizedBox(height: AppTokens.s16),
      AppTextField(
        controller: _address,
        label: l10n.databases_address,
        validator: (value) => (value == null || value.trim().isEmpty)
            ? l10n.databases_nameRequired
            : null,
      ),
      const SizedBox(height: AppTokens.s16),
      AppTextField(
        controller: _port,
        label: l10n.databases_port,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: AppTokens.s16),
      AppTextField(
        controller: _username,
        label: l10n.databases_username,
        validator: (value) => (value == null || value.trim().isEmpty)
            ? l10n.databases_usernameRequired
            : null,
      ),
      const SizedBox(height: AppTokens.s16),
      AppTextField(
        controller: _password,
        label: l10n.databases_password,
        obscure: true,
      ),
    ];
  }
}
