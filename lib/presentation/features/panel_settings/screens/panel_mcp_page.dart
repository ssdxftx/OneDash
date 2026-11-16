import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/mcp_repository_impl.dart';
import '../../../../domain/repositories/mcp_repository.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

class PanelMcpPage extends ConsumerStatefulWidget {
  const PanelMcpPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<PanelMcpPage> createState() => _PanelMcpPageState();
}

class _PanelMcpPageState extends ConsumerState<PanelMcpPage> {
  McpRepository? _repository;
  Map<String, dynamic> _status = const {};
  Map<String, dynamic> _settings = const {};
  Map<String, dynamic> _website = const {};
  Map<String, dynamic> _catalog = const {};
  List<Map<String, dynamic>> _credentials = const [];
  List<Map<String, dynamic>> _invocations = const [];
  List<Map<String, dynamic>> _nodes = const [];
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final repository = await ref.read(mcpRepositoryProvider.future);
      _repository = repository;
      final status = await repository.getStatus();
      final results = await Future.wait<Object?>([
        _optional(repository.getSettings()),
        _optional(repository.getWebsiteStatus()),
        _optional(repository.getCatalog()),
        _optional(repository.searchCredentials()),
        _optional(repository.searchInvocations()),
        _optional(repository.getNodes()),
      ]);
      if (!mounted) return;
      final credentials = results[3] as Map<String, dynamic>?;
      final invocations = results[4] as Map<String, dynamic>?;
      setState(() {
        _status = status;
        _settings = (results[0] as Map<String, dynamic>?) ?? const {};
        _website = (results[1] as Map<String, dynamic>?) ?? const {};
        _catalog = (results[2] as Map<String, dynamic>?) ?? const {};
        _credentials = _items(credentials);
        _invocations = _items(invocations);
        _nodes = (results[5] as List<Map<String, dynamic>>?) ?? const [];
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
      showErrorToast(context, error);
    }
  }

  Future<T?> _optional<T>(Future<T> future) async {
    try {
      return await future;
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _items(Map<String, dynamic>? response) {
    final raw = response?['items'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(Map<String, dynamic>.from)
        .toList(growable: false);
  }

  String _text(Map<String, dynamic> source, String key) =>
      '${source[key] ?? ''}'.trim();

  bool _bool(Map<String, dynamic> source, String key) => source[key] == true;

  int _int(Map<String, dynamic> source, String key) {
    final value = source[key];
    return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.panelMcp_title,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const SkeletonList(itemCount: 8)
          : _failed
          ? EmptyState(
              icon: TablerIcons.alert_triangle,
              title: l10n.panelMcp_loadFailed,
              actionLabel: l10n.action_retry,
              onAction: _load,
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.all(context.pagePadding),
                children: [
                  _serviceSection(context, l10n),
                  const SizedBox(height: AppTokens.s24),
                  if (_canManage) ...[
                    _websiteSection(context, l10n),
                    const SizedBox(height: AppTokens.s24),
                  ],
                  _credentialsSection(context, l10n),
                  const SizedBox(height: AppTokens.s24),
                  _invocationsSection(context, l10n),
                  const SizedBox(height: AppTokens.s32),
                ],
              ),
            ),
    );
  }

  bool get _canManage => _bool(_status, 'canManageService');

  Widget _serviceSection(BuildContext context, AppLocalizations l10n) {
    final installed = _bool(_status, 'installed');
    final ready = _bool(_status, 'ready');
    final enabled = _bool(_status, 'enabled');
    final statusText = installed
        ? (ready ? l10n.panelMcp_ready : _text(_status, 'status'))
        : l10n.panelMcp_notInstalled;
    final image = _text(_status, 'dockerImage').isNotEmpty
        ? _text(_status, 'dockerImage')
        : _text(_settings, 'dockerImage');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.panelMcp_service,
          subtitle: l10n.panelMcp_subtitle,
          trailing: _canManage
              ? AppIconButton(
                  icon: TablerIcons.adjustments,
                  tooltip: l10n.panelMcp_settings,
                  onPressed: _editServiceSettings,
                )
              : null,
        ),
        TonalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(
                context,
                l10n.panelMcp_status,
                installed
                    ? '$statusText · ${enabled ? l10n.panelMcp_serviceRunning : l10n.panelMcp_serviceStopped}'
                    : statusText,
              ),
              if (_text(_status, 'endpoint').isNotEmpty)
                _infoRow(
                  context,
                  l10n.panelMcp_endpoint,
                  _text(_status, 'endpoint'),
                ),
              if (image.isNotEmpty)
                _infoRow(context, l10n.panelMcp_dockerImage, image),
              if (_text(_status, 'reason').isNotEmpty)
                _infoRow(
                  context,
                  l10n.panelMcp_reason,
                  _text(_status, 'reason'),
                ),
              if (_bool(_status, 'installing'))
                _infoRow(
                  context,
                  l10n.panelMcp_installing,
                  l10n.common_installing,
                ),
              if (!installed) ...[
                const SizedBox(height: AppTokens.s12),
                PrimaryButton(
                  label: l10n.panelMcp_install,
                  icon: TablerIcons.download,
                  onPressed: _canManage ? _installService : null,
                ),
              ],
            ],
          ),
        ),
        if (installed) ...[
          const SizedBox(height: AppTokens.s12),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.player_play),
                title: l10n.panelMcp_start,
                onTap: _canManage ? () => _operateService('start') : null,
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.player_stop),
                title: l10n.panelMcp_stop,
                onTap: _canManage ? () => _operateService('stop') : null,
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.refresh),
                title: l10n.panelMcp_restart,
                onTap: _canManage ? () => _operateService('restart') : null,
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.file_text),
                title: l10n.panelMcp_logs,
                trailing: const Icon(TablerIcons.chevron_right),
                onTap: _showLogs,
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.list_details),
                title: l10n.panelMcp_catalog,
                subtitle: l10n.panelMcp_catalogHint,
                trailing: const Icon(TablerIcons.chevron_right),
                onTap: _showCatalog,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _websiteSection(BuildContext context, AppLocalizations l10n) {
    final state = _text(_website, 'state');
    final bound = state.isNotEmpty && state != 'unbound';
    final domain = _text(_website, 'domain');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.panelMcp_website,
          subtitle: bound ? l10n.panelMcp_bound : l10n.panelMcp_unbound,
        ),
        TonalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(
                context,
                l10n.panelMcp_websiteState,
                state.isEmpty ? l10n.panelMcp_unbound : state,
              ),
              if (domain.isNotEmpty)
                _infoRow(context, l10n.panelMcp_domain, domain),
              if (_text(_website, 'endpoint').isNotEmpty)
                _infoRow(
                  context,
                  l10n.panelMcp_endpoint,
                  _text(_website, 'endpoint'),
                ),
              if (_text(_website, 'reason').isNotEmpty)
                _infoRow(
                  context,
                  l10n.panelMcp_reason,
                  _text(_website, 'reason'),
                ),
              const SizedBox(height: AppTokens.s12),
              if (bound) ...[
                SecondaryButton(
                  label: l10n.panelMcp_updateWebsite,
                  icon: TablerIcons.edit,
                  onPressed: _editWebsite,
                ),
                const SizedBox(height: AppTokens.s8),
                SecondaryButton(
                  label: l10n.panelMcp_unbindWebsite,
                  icon: TablerIcons.unlink,
                  onPressed: () => _unbindWebsite(false),
                ),
                const SizedBox(height: AppTokens.s8),
                SecondaryButton(
                  label: l10n.panelMcp_deleteWebsite,
                  icon: TablerIcons.trash,
                  onPressed: () => _unbindWebsite(true),
                ),
              ] else
                PrimaryButton(
                  label: l10n.panelMcp_bindWebsite,
                  icon: TablerIcons.link,
                  onPressed: _editWebsite,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _credentialsSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.panelMcp_credentials,
          trailing: AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.panelMcp_createCredential,
            onPressed: _canManage ? _createCredential : null,
          ),
        ),
        if (_credentials.isEmpty)
          EmptyState(
            icon: TablerIcons.key,
            title: l10n.panelMcp_noCredentials,
            compact: true,
          )
        else
          for (final item in _credentials) ...[
            TonalCard(
              onTap: () => _showCredentialActions(item),
              child: Row(
                children: [
                  Icon(
                    _text(item, 'status') == 'Enable'
                        ? TablerIcons.key
                        : TablerIcons.key_off,
                    color: context.scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppTokens.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _text(item, 'name'),
                          style: AppTextStyles.titleS,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          [
                            _text(item, 'keyHint'),
                            '${l10n.panelMcp_status}: ${_text(item, 'status')}',
                            l10n.panelMcp_toolsCount(
                              (_asList(item['tools'])).length,
                            ),
                          ].join(' · '),
                          style: AppTextStyles.caption.copyWith(
                            color: context.scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    TablerIcons.chevron_right,
                    size: AppTokens.iconList,
                    color: context.scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s8),
          ],
      ],
    );
  }

  Widget _invocationsSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.panelMcp_invocations),
        if (_invocations.isEmpty)
          EmptyState(
            icon: TablerIcons.history,
            title: l10n.panelMcp_noInvocations,
            compact: true,
          )
        else
          for (final item in _invocations.take(AppTokens.pageSizePhone)) ...[
            TonalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _text(item, 'toolId'),
                          style: AppTextStyles.titleS,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _text(item, 'status'),
                        style: AppTextStyles.caption.copyWith(
                          color: context.scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s4),
                  Text(
                    '${l10n.panelMcp_credential}: ${_text(item, 'credentialName')} · ${_text(item, 'durationMs')} ms',
                    style: AppTextStyles.caption.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                  if (_text(item, 'startedAt').isNotEmpty)
                    Text(
                      _text(item, 'startedAt'),
                      style: AppTextStyles.caption.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s8),
          ],
      ],
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppTokens.s40 + AppTokens.s24 * 2,
            child: Text(
              label,
              style: AppTextStyles.bodyS.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyS,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _asList(Object? value) =>
      value is List ? value : const <dynamic>[];

  Future<void> _run(
    Future<void> Function(McpRepository repository) action, {
    bool reload = true,
  }) async {
    final l10n = AppLocalizations.of(context);
    final repository = _repository;
    if (repository == null) return;
    try {
      await action(repository);
      if (!mounted) return;
      AppToast.success(context, l10n.panelMcp_operationCompleted);
      if (reload) await _load();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _operateService(String operation) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.panelMcp_service,
      message: l10n.panelMcp_serviceConfirm(operation),
      confirmLabel: operation,
    );
    if (!confirmed) return;
    await _run((repo) => repo.operateService(operation));
  }

  Future<void> _installService() async {
    final l10n = AppLocalizations.of(context);
    final result = await pushFormPage<Map<String, dynamic>>(
      context,
      _ServiceFormPage(
        title: l10n.panelMcp_install,
        initial: _settings,
        installing: true,
      ),
    );
    if (result == null || !mounted) return;
    await _run(
      (repo) => repo.installService({
        ...result,
        'runtimeType': 'docker',
        'deleteOldImage': false,
        'revision': _int(_settings, 'revision'),
      }),
    );
  }

  Future<void> _editServiceSettings() async {
    final l10n = AppLocalizations.of(context);
    final result = await pushFormPage<Map<String, dynamic>>(
      context,
      _ServiceFormPage(
        title: l10n.panelMcp_settings,
        initial: _settings,
        installing: false,
      ),
    );
    if (result == null || !mounted) return;
    await _run(
      (repo) => repo.updateSettings({
        ...result,
        'runtimeType': 'docker',
        'revision': _int(_settings, 'revision'),
      }),
    );
  }

  Future<void> _showLogs() async {
    final l10n = AppLocalizations.of(context);
    final repository = _repository;
    if (repository == null) return;
    try {
      final content = await repository.getServiceLogs();
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.panelMcp_logs, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s12),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: AppTokens.logPanelMaxHeight,
              ),
              child: SingleChildScrollView(
                child: Text(
                  content.isEmpty ? l10n.common_notAvailable : content,
                  style: AppTextStyles.caption,
                ),
              ),
            ),
            const SizedBox(height: AppTokens.s12),
            SecondaryButton(
              label: l10n.action_copy,
              icon: TablerIcons.copy,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: content));
                if (!sheetContext.mounted) return;
                AppToast.success(sheetContext, l10n.action_copy);
              },
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showCatalog() async {
    final l10n = AppLocalizations.of(context);
    final tools = _asList(_catalog['tools']);
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.panelMcp_catalog, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s4),
          Text(
            l10n.panelMcp_toolsCount(tools.length),
            style: AppTextStyles.bodyS.copyWith(
              color: sheetContext.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s12),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final tool in tools.whereType<Map>())
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${tool['name'] ?? tool['toolId'] ?? ''}'),
                    subtitle: Text(
                      '${tool['toolId'] ?? ''} · ${tool['categoryName'] ?? ''}',
                    ),
                    trailing: tool['readOnly'] == true
                        ? const Icon(TablerIcons.eye)
                        : null,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s8),
        ],
      ),
    );
  }

  Future<void> _editWebsite() async {
    final bound =
        _text(_website, 'state') != 'unbound' &&
        _text(_website, 'state').isNotEmpty;
    final result = await pushFormPage<Map<String, dynamic>>(
      context,
      _WebsiteFormPage(initial: _website, binding: !bound),
    );
    if (result == null || !mounted) return;
    await _run(
      (repo) => bound
          ? repo.updateWebsite({
              ...result,
              'requestId': const Uuid().v4(),
              'revision': _int(_settings, 'revision'),
            })
          : repo.bindWebsite({
              ...result,
              'requestId': const Uuid().v4(),
              'revision': _int(_settings, 'revision'),
            }),
    );
  }

  Future<void> _unbindWebsite(bool deleteWebsite) async {
    final l10n = AppLocalizations.of(context);
    final domain = _text(_website, 'domain');
    final confirmed = await showConfirmSheet(
      context,
      title: deleteWebsite
          ? l10n.panelMcp_deleteWebsite
          : l10n.panelMcp_unbindWebsite,
      message: l10n.panelMcp_unbindConfirm(domain),
      confirmLabel: deleteWebsite
          ? l10n.action_delete
          : l10n.panelMcp_unbindWebsite,
    );
    if (!confirmed) return;
    await _run(
      (repo) => repo.unbindWebsite({
        'requestId': const Uuid().v4(),
        'revision': _int(_settings, 'revision'),
        'deleteWebsite': deleteWebsite,
      }),
    );
  }

  Future<void> _createCredential() async {
    final result = await pushFormPage<Map<String, dynamic>>(
      context,
      _CredentialFormPage(catalog: _catalog, nodes: _nodes),
    );
    if (result == null || !mounted) return;
    final created = await _createCredentialRequest(result);
    if (created == null || !mounted) return;
    final item = created['item'];
    final token = '${created['token'] ?? ''}';
    if (token.isNotEmpty) await _showSecret(token);
    if (item is Map) {
      await _load();
    }
  }

  Future<Map<String, dynamic>?> _createCredentialRequest(
    Map<String, dynamic> body,
  ) async {
    final l10n = AppLocalizations.of(context);
    final repository = _repository;
    if (repository == null) return null;
    try {
      final result = await repository.createCredential(body);
      if (!mounted) return null;
      AppToast.success(context, l10n.panelMcp_createSuccess);
      return result;
    } catch (error) {
      if (!mounted) return null;
      showErrorToast(context, error);
      return null;
    }
  }

  Future<void> _showCredentialActions(Map<String, dynamic> item) async {
    final l10n = AppLocalizations.of(context);
    final enabled = _text(item, 'status') == 'Enable';
    final action = await showSelectionMenu<String>(
      context,
      title: _text(item, 'name'),
      options: [
        SelectionOption(
          label: l10n.action_edit,
          value: 'edit',
          icon: TablerIcons.edit,
        ),
        SelectionOption(
          label: enabled ? l10n.action_disable : l10n.action_enable,
          value: 'status',
          icon: enabled ? TablerIcons.toggle_left : TablerIcons.toggle_right,
        ),
        SelectionOption(
          label: l10n.panelMcp_revealToken,
          value: 'reveal',
          icon: TablerIcons.eye,
        ),
        SelectionOption(
          label: l10n.panelMcp_rotateToken,
          value: 'rotate',
          icon: TablerIcons.refresh,
        ),
        SelectionOption(
          label: l10n.panelMcp_exportCredential,
          value: 'export',
          icon: TablerIcons.file_download,
        ),
        SelectionOption(
          label: l10n.panelMcp_revoke,
          value: 'revoke',
          icon: TablerIcons.ban,
          danger: true,
        ),
        SelectionOption(
          label: l10n.action_delete,
          value: 'delete',
          icon: TablerIcons.trash,
          danger: true,
        ),
      ],
    );
    if (action == null || !mounted) return;
    switch (action) {
      case 'edit':
        await _editCredential(item);
      case 'status':
        await _setCredentialStatus(item, enabled);
      case 'reveal':
        await _revealOrRotate(item, false);
      case 'rotate':
        await _revealOrRotate(item, true);
      case 'export':
        await _exportCredential(item);
      case 'revoke':
        await _revokeCredential(item);
      case 'delete':
        await _deleteCredential(item);
    }
  }

  Future<void> _editCredential(Map<String, dynamic> item) async {
    final result = await pushFormPage<Map<String, dynamic>>(
      context,
      _CredentialFormPage(catalog: _catalog, nodes: _nodes, initial: item),
    );
    if (result == null || !mounted) return;
    await _run(
      (repo) => repo.updateCredential({
        ...result,
        'id': _text(item, 'id'),
        'revision': _int(item, 'revision'),
      }),
    );
  }

  Future<void> _setCredentialStatus(
    Map<String, dynamic> item,
    bool enabled,
  ) async {
    await _run(
      (repo) => repo.setCredentialStatus(
        id: _text(item, 'id'),
        revision: _int(item, 'revision'),
        status: enabled ? 'Disable' : 'Enable',
      ),
    );
  }

  Future<void> _revealOrRotate(Map<String, dynamic> item, bool rotate) async {
    final repository = _repository;
    if (repository == null) return;
    try {
      final token = rotate
          ? await repository.rotateCredential(
              id: _text(item, 'id'),
              revision: _int(item, 'revision'),
            )
          : await repository.revealCredential(
              id: _text(item, 'id'),
              revision: _int(item, 'revision'),
            );
      if (!mounted) return;
      await _showSecret(token);
      if (rotate) await _load();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showSecret(String token) async {
    final l10n = AppLocalizations.of(context);
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.panelMcp_tokenTitle, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s8),
          Text(
            l10n.panelMcp_tokenHint,
            style: AppTextStyles.bodyS.copyWith(
              color: sheetContext.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s12),
          SelectableText(token, style: AppTextStyles.bodyS),
          const SizedBox(height: AppTokens.s12),
          SecondaryButton(
            label: l10n.action_copy,
            icon: TablerIcons.copy,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: token));
              if (!sheetContext.mounted) return;
              AppToast.success(sheetContext, l10n.panelMcp_tokenCopied);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _exportCredential(Map<String, dynamic> item) async {
    final l10n = AppLocalizations.of(context);
    final client = await _promptExportClient();
    if (client == null || client.isEmpty || !mounted) return;
    final repository = _repository;
    if (repository == null) return;
    try {
      final document = await repository.exportCredential(
        id: _text(item, 'id'),
        revision: _int(item, 'revision'),
        client: client,
      );
      if (!mounted) return;
      final content = '${document['content'] ?? ''}';
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.panelMcp_exportTitle, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s8),
            Text(
              '${document['filename'] ?? ''}',
              style: AppTextStyles.bodyS.copyWith(
                color: sheetContext.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.s12),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: AppTokens.logPanelMaxHeight,
              ),
              child: SingleChildScrollView(
                child: SelectableText(content, style: AppTextStyles.caption),
              ),
            ),
            const SizedBox(height: AppTokens.s12),
            SecondaryButton(
              label: l10n.action_copy,
              icon: TablerIcons.copy,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: content));
                if (!sheetContext.mounted) return;
                AppToast.success(sheetContext, l10n.action_copy);
              },
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<String?> _promptExportClient() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: 'claude');
    final result = await pushFormPage<String>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.panelMcp_exportCredential,
          onSave: () async {
            final value = controller.text.trim();
            Navigator.of(pageContext).pop(value);
          },
          children: [
            AppTextField(
              controller: controller,
              label: l10n.panelMcp_exportClient,
              hint: l10n.panelMcp_exportClientHint,
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _revokeCredential(Map<String, dynamic> item) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.panelMcp_revoke,
      message: l10n.panelMcp_revokeConfirm(_text(item, 'name')),
      confirmLabel: l10n.panelMcp_revoke,
    );
    if (!confirmed) return;
    await _run(
      (repo) => repo.revokeCredential(
        id: _text(item, 'id'),
        revision: _int(item, 'revision'),
      ),
    );
  }

  Future<void> _deleteCredential(Map<String, dynamic> item) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: l10n.panelMcp_deleteConfirm(_text(item, 'name')),
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed) return;
    await _run(
      (repo) => repo.deleteCredential(
        id: _text(item, 'id'),
        revision: _int(item, 'revision'),
      ),
    );
  }
}

class _ServiceFormPage extends StatefulWidget {
  const _ServiceFormPage({
    required this.title,
    required this.initial,
    required this.installing,
  });

  final String title;
  final Map<String, dynamic> initial;
  final bool installing;

  @override
  State<_ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<_ServiceFormPage> {
  late final _image = TextEditingController(
    text: '${widget.initial['dockerImage'] ?? ''}',
  );
  late final _port = TextEditingController(
    text: '${widget.initial['listenPort'] ?? 18081}',
  );
  late final _externalUrl = TextEditingController(
    text: '${widget.initial['externalUrl'] ?? ''}',
  );
  late final _ips = TextEditingController(
    text: ((widget.initial['allowedIPs'] as List?) ?? const [])
        .map((item) => '$item')
        .join('\n'),
  );
  late String _policy = _validPolicy(
    '${widget.initial['accessPolicy'] ?? 'inherit'}',
  );
  late bool _enabled = widget.initial['enabled'] == true;

  String _validPolicy(String value) =>
      const {'inherit', 'all', 'restricted'}.contains(value)
      ? value
      : 'inherit';

  @override
  void dispose() {
    _image.dispose();
    _port.dispose();
    _externalUrl.dispose();
    _ips.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SimpleFormPage(
      title: widget.title,
      onSave: _save,
      children: [
        AppTextField(
          controller: _image,
          label: l10n.panelMcp_dockerImage,
          hint: '1panel/mcp-server:v2.0.0',
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _port,
          label: l10n.panelMcp_listenPort,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _externalUrl,
          label: l10n.panelMcp_externalUrl,
          hint: 'https://mcp.example.com',
        ),
        const SizedBox(height: AppTokens.s12),
        DropdownButtonFormField<String>(
          initialValue: _policy,
          decoration: InputDecoration(labelText: l10n.panelMcp_accessPolicy),
          items: [
            DropdownMenuItem(
              value: 'inherit',
              child: Text(l10n.panelMcp_accessInherit),
            ),
            DropdownMenuItem(
              value: 'all',
              child: Text(l10n.panelMcp_accessAll),
            ),
            DropdownMenuItem(
              value: 'restricted',
              child: Text(l10n.panelMcp_accessRestricted),
            ),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _policy = value);
          },
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _ips,
          label: l10n.panelMcp_allowedIPs,
          hint: l10n.panelMcp_allowedIPsHint,
          maxLines: 4,
        ),
        if (!widget.installing) ...[
          const SizedBox(height: AppTokens.s8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.panelMcp_serviceRunning),
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
          ),
        ],
      ],
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final ips = _ips.text
        .split(RegExp(r'[\n,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (_image.text.trim().isEmpty || _port.text.trim().isEmpty) {
      AppToast.error(context, l10n.panelMcp_requiredFields);
      return;
    }
    Navigator.of(context).pop({
      'dockerImage': _image.text.trim(),
      'listenPort': int.tryParse(_port.text.trim()) ?? 0,
      'externalUrl': _externalUrl.text.trim(),
      'accessPolicy': _policy,
      'allowedIPs': ips,
      if (!widget.installing) 'enabled': _enabled,
    });
  }
}

class _WebsiteFormPage extends StatefulWidget {
  const _WebsiteFormPage({required this.initial, required this.binding});

  final Map<String, dynamic> initial;
  final bool binding;

  @override
  State<_WebsiteFormPage> createState() => _WebsiteFormPageState();
}

class _WebsiteFormPageState extends State<_WebsiteFormPage> {
  late final _domain = TextEditingController(
    text: '${widget.initial['domain'] ?? ''}',
  );
  late final _sslId = TextEditingController(
    text: '${widget.initial['sslID'] ?? 0}',
  );
  late bool _enableSsl = widget.initial['enableSSL'] == true;

  @override
  void dispose() {
    _domain.dispose();
    _sslId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SimpleFormPage(
      title: widget.binding
          ? l10n.panelMcp_bindWebsite
          : l10n.panelMcp_updateWebsite,
      onSave: _save,
      children: [
        if (widget.binding) ...[
          AppTextField(
            controller: _domain,
            label: l10n.panelMcp_domain,
            hint: 'mcp.example.com',
          ),
          const SizedBox(height: AppTokens.s12),
        ],
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.panelMcp_enableSsl),
          value: _enableSsl,
          onChanged: (value) => setState(() => _enableSsl = value),
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _sslId,
          label: l10n.panelMcp_sslId,
          helper: l10n.panelMcp_sslHint,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (widget.binding && _domain.text.trim().isEmpty) {
      AppToast.error(context, l10n.panelMcp_requiredFields);
      return;
    }
    Navigator.of(context).pop({
      if (widget.binding) 'domain': _domain.text.trim(),
      'enableSSL': _enableSsl,
      'sslID': int.tryParse(_sslId.text.trim()) ?? 0,
    });
  }
}

class _CredentialFormPage extends StatefulWidget {
  const _CredentialFormPage({
    required this.catalog,
    required this.nodes,
    this.initial,
  });

  final Map<String, dynamic> catalog;
  final List<Map<String, dynamic>> nodes;
  final Map<String, dynamic>? initial;

  @override
  State<_CredentialFormPage> createState() => _CredentialFormPageState();
}

class _CredentialFormPageState extends State<_CredentialFormPage> {
  late final _name = TextEditingController(
    text: '${widget.initial?['name'] ?? ''}',
  );
  late final _description = TextEditingController(
    text: '${widget.initial?['description'] ?? ''}',
  );
  late final _expires = TextEditingController(
    text: _dateText(widget.initial?['expiresAt']),
  );
  late final Set<String> _tools = {
    for (final item in (widget.initial?['tools'] as List?) ?? const []) '$item',
  };
  late final Set<String> _nodes = {
    for (final item in (widget.initial?['nodeIds'] as List?) ?? const [])
      '$item',
  };

  String _dateText(Object? value) {
    final text = '${value ?? ''}';
    return text.startsWith('0001-') ? '' : text;
  }

  List<Map<String, dynamic>> get _toolsCatalog =>
      widget.catalog['tools'] is List
      ? (widget.catalog['tools'] as List)
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList(growable: false)
      : const [];

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _expires.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tools = _toolsCatalog;
    return SimpleFormPage(
      title: widget.initial == null
          ? l10n.panelMcp_createCredential
          : l10n.panelMcp_editCredential,
      onSave: _save,
      children: [
        AppTextField(controller: _name, label: l10n.panelMcp_credentialName),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _description,
          label: l10n.panelMcp_credentialDescription,
          maxLines: 3,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _expires,
          label: l10n.panelMcp_expiresAt,
          hint: '2026-12-31T00:00:00Z',
        ),
        const SizedBox(height: AppTokens.s12),
        SectionHeader(title: l10n.panelMcp_tools),
        if (tools.isEmpty)
          Text(
            l10n.panelMcp_catalogHint,
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          )
        else
          for (final tool in tools)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _tools.contains('${tool['toolId']}'),
              title: Text('${tool['name'] ?? tool['toolId'] ?? ''}'),
              subtitle: Text(
                '${tool['toolId'] ?? ''} · ${tool['categoryName'] ?? ''}',
              ),
              onChanged: (value) {
                final id = '${tool['toolId']}';
                setState(() {
                  if (value == true) {
                    _tools.add(id);
                  } else {
                    _tools.remove(id);
                  }
                });
              },
            ),
        if (widget.nodes.isNotEmpty) ...[
          const SizedBox(height: AppTokens.s12),
          SectionHeader(title: l10n.panelMcp_nodes),
          for (final node in widget.nodes)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _nodes.contains('${node['id']}'),
              title: Text('${node['name'] ?? node['id'] ?? ''}'),
              subtitle: Text('${node['status'] ?? ''}'),
              onChanged: (value) {
                final id = '${node['id']}';
                setState(() {
                  if (value == true) {
                    _nodes.add(id);
                  } else {
                    _nodes.remove(id);
                  }
                });
              },
            ),
        ],
      ],
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty) {
      AppToast.error(context, l10n.panelMcp_requiredFields);
      return;
    }
    DateTime? expires;
    final expiresText = _expires.text.trim();
    if (expiresText.isNotEmpty) {
      expires = DateTime.tryParse(expiresText);
      if (expires == null) {
        AppToast.error(context, l10n.panelMcp_expiresAt);
        return;
      }
    }
    final catalog = {
      for (final tool in _toolsCatalog) '${tool['toolId']}': tool,
    };
    final toolPolicies = <String, String>{};
    final toolReadOnly = <String, bool>{};
    for (final id in _tools) {
      final tool = catalog[id];
      if (tool == null) continue;
      toolPolicies[id] = '${tool['policyHash'] ?? ''}';
      toolReadOnly[id] = tool['readOnly'] == true;
    }
    Navigator.of(context).pop({
      'name': _name.text.trim(),
      'description': _description.text.trim(),
      'expiresAt': expires?.toUtc().toIso8601String(),
      'tools': _tools.toList(growable: false),
      'toolPolicies': toolPolicies,
      'toolReadOnly': toolReadOnly,
      'nodeIds': _nodes.toList(growable: false),
    });
  }
}
