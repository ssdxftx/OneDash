import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/common/page_result.dart';
import '../../../../data/dto/cronjob/cronjob_form_data_dto.dart';
import '../../../../data/dto/runtime/runtime_dto.dart';
import '../../../../data/dto/website/ssl_manage_dtos.dart';
import '../../../../data/dto/website/website_create_req.dart';
import '../../../../data/dto/website/website_domain_req.dart';
import '../../../../data/repositories_impl/runtime_repository_impl.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/pill_app_bar.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/error_toast.dart';
import '../providers/websites_provider.dart';

class WebsiteCreateWizard extends ConsumerStatefulWidget {
  const WebsiteCreateWizard({
    super.key,
    required this.serverId,
    this.type = 'static',
  });

  final int serverId;
  final String type;

  @override
  ConsumerState<WebsiteCreateWizard> createState() =>
      _WebsiteCreateWizardState();
}

class _WebsiteCreateWizardState extends ConsumerState<WebsiteCreateWizard> {
  final _domainController = TextEditingController();
  final _aliasController = TextEditingController();
  final _proxyController = TextEditingController();
  final _portController = TextEditingController(text: '80');
  final _remarkController = TextEditingController();
  final _ftpUserController = TextEditingController();
  final _ftpPasswordController = TextEditingController();
  final _dbHostController = TextEditingController();
  final _dbNameController = TextEditingController();
  final _dbUserController = TextEditingController();
  final _dbPasswordController = TextEditingController();

  final List<String> _domains = [];
  String _protocol = 'http://';
  String _runtimeType = 'php';
  String _dbType = 'mysql';
  bool _aliasTouched = false;
  bool _enableSsl = false;
  bool _ipv6 = false;
  bool _enableFtp = false;
  bool _createDb = false;
  bool _creating = false;
  int _groupId = 1;
  int? _sslId;
  int? _acmeId;
  RuntimeDto? _runtime;
  List<RuntimeDto> _runtimes = const [];
  List<SslManageDto> _certificates = const [];

  @override
  void initState() {
    super.initState();
    _aliasController.addListener(() {
      if (_aliasController.text.trim().isNotEmpty) _aliasTouched = true;
    });
    if (widget.type == 'runtime') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadRuntimes());
    }
  }

  @override
  void dispose() {
    _domainController.dispose();
    _aliasController.dispose();
    _proxyController.dispose();
    _portController.dispose();
    _remarkController.dispose();
    _ftpUserController.dispose();
    _ftpPasswordController.dispose();
    _dbHostController.dispose();
    _dbNameController.dispose();
    _dbUserController.dispose();
    _dbPasswordController.dispose();
    super.dispose();
  }

  String _title(AppLocalizations l10n) {
    return switch (widget.type) {
      'proxy' => l10n.websites_createProxyTitle,
      'runtime' => l10n.websites_createRuntimeTitle,
      'stream' => l10n.websites_createStreamTitle,
      _ => l10n.websites_createStaticTitle,
    };
  }

  String _aliasFromDomain(String domain) {
    final base = domain.split('.').first.toLowerCase();
    final value = base
        .replaceAll(RegExp(r'[^a-z0-9-]'), '-')
        .replaceAll(RegExp('-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return value.isEmpty ? domain : value;
  }

  void _addDomain() {
    final l10n = AppLocalizations.of(context);
    final value = _domainController.text.trim();
    if (value.isEmpty || _domains.contains(value)) return;
    if (!RegExp(r'^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value) &&
        !RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(value)) {
      AppToast.error(context, l10n.websites_invalidDomainFormat);
      return;
    }
    setState(() {
      _domains.add(value);
      _domainController.clear();
      if (!_aliasTouched && _domains.length == 1) {
        _aliasController.text = _aliasFromDomain(value);
      }
    });
    if (_domains.length == 1) {
      _loadCertificates(value);
    }
  }

  Future<void> _copyFromExisting() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final options = await repository.getWebsiteOptions();
      if (!mounted) return;
      if (options.isEmpty) {
        AppToast.warning(context, l10n.state_empty);
        return;
      }
      final picked = await showAppSheet<WebsiteOptionDto>(
        context: context,
        maxHeightFactor: 0.85,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.websites_copyFromExisting, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final option in options)
                    ListTile(
                      leading: const Icon(TablerIcons.world),
                      title: Text(option.primaryDomain),
                      subtitle: Text(option.alias),
                      onTap: () => Navigator.of(sheetContext).pop(option),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
      if (picked == null || !mounted) return;
      setState(() {
        _aliasController.text = picked.alias;
        if (picked.primaryDomain.isNotEmpty) {
          _domains
            ..clear()
            ..add(picked.primaryDomain);
        }
      });
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _loadCertificates(String domain) async {
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final result = await repository.searchSsl({
        'page': 1,
        'pageSize': 100,
        'domain': domain,
      });
      if (!mounted) return;
      setState(() => _certificates = result.items);
    } catch (_) {
      // Certificates are optional; keep the form usable when the query fails.
    }
  }

  Future<void> _loadRuntimes() async {
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      final PageResult<RuntimeDto> result = await repository.searchRuntimes({
        'page': 1,
        'pageSize': 100,
        'type': _runtimeType,
        'status': 'Running',
      });
      if (!mounted) return;
      setState(() {
        _runtimes = result.items;
        _runtime = result.items.isEmpty ? null : result.items.first;
        final port = int.tryParse(_runtime?.port ?? '') ?? 0;
        if (port > 0) _portController.text = '$port';
      });
    } catch (_) {
      // Runtime list is optional; keep the form usable.
    }
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    if (_domains.isEmpty) {
      AppToast.error(context, l10n.websites_domainAtLeastOne);
      return;
    }
    if (widget.type == 'proxy' && _proxyController.text.trim().isEmpty) {
      AppToast.error(context, l10n.websites_proxyTargetRequired);
      return;
    }
    if (widget.type == 'runtime' && _runtime == null) {
      AppToast.error(context, l10n.state_empty);
      return;
    }
    if (_enableSsl && _sslId == null) {
      AppToast.error(context, l10n.websites_sslRequired);
      return;
    }
    final port = int.tryParse(_portController.text.trim()) ?? 80;
    if (port <= 0 || port >= 65536) {
      AppToast.error(context, l10n.websites_invalidDomainFormat);
      return;
    }
    setState(() => _creating = true);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.createWebsite(
        WebsiteCreateReq(
          alias: _aliasController.text.trim().isEmpty
              ? _aliasFromDomain(_domains.first)
              : _aliasController.text.trim(),
          type: widget.type,
          domains: [
            for (final domain in _domains)
              WebsiteDomainReq(
                domain: domain,
                host: domain,
                port: port,
                ssl: _enableSsl,
              ),
          ],
          webSiteGroupID: _groupId,
          remark: _remarkController.text.trim(),
          proxy: widget.type == 'proxy'
              ? '$_protocol${_proxyController.text.trim()}'
              : '',
          port: port,
          runtimeID: _runtime?.id ?? 0,
          siteDir: _domains.first,
          taskID: const Uuid().v4(),
          enableSSL: _enableSsl,
          websiteSSLID: _enableSsl ? (_sslId ?? 0) : 0,
          acmeAccountID: _enableSsl ? (_acmeId ?? 0) : 0,
          ipv6: _ipv6,
          enableFtp: _enableFtp,
          ftpUser: _enableFtp ? _ftpUserController.text.trim() : '',
          ftpPassword: _enableFtp
              ? base64Encode(utf8.encode(_ftpPasswordController.text))
              : '',
          createDb: _createDb,
          dbName: _createDb ? _dbNameController.text.trim() : '',
          dbUser: _createDb ? _dbUserController.text.trim() : '',
          dbPassword: _createDb ? _dbPasswordController.text : '',
          dbHost: _createDb ? _dbHostController.text.trim() : '',
          dbType: _dbType,
        ),
      );
      if (!mounted) return;
      await ref.read(websitesProvider.notifier).refresh();
      if (!mounted) return;
      AppToast.success(context, l10n.websites_createSuccess);
      context.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _creating = false);
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metadata = ref.watch(websiteCreateMetadataProvider);
    final groups = metadata.valueOrNull?.groups ?? const [];
    final defaultGroup = metadata.valueOrNull?.defaultGroup;
    if (defaultGroup != null && _groupId == 1 && defaultGroup.id != 1) {
      _groupId = defaultGroup.id;
    }
    return Scaffold(
      appBar: PillAppBar(
        title: _title(l10n),
        onBack: () => context.pop(),
        actionLabel: l10n.action_create,
        actionBusy: _creating,
        onAction: _creating ? null : _create,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s8,
          AppTokens.s16,
          AppTokens.s32 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          SectionHeader(title: l10n.websites_domains),
          TonalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _domainController,
                        hint: 'example.com',
                        keyboardType: TextInputType.url,
                        onSubmitted: (_) => _addDomain(),
                      ),
                    ),
                    const SizedBox(width: AppTokens.s8),
                    IconButton.filledTonal(
                      onPressed: _addDomain,
                      icon: const Icon(TablerIcons.plus),
                    ),
                  ],
                ),
                if (_domains.isNotEmpty) ...[
                  const SizedBox(height: AppTokens.s12),
                  Wrap(
                    spacing: AppTokens.s8,
                    runSpacing: AppTokens.s8,
                    children: [
                      for (final domain in _domains)
                        InputChip(
                          label: Text(domain),
                          onDeleted: () =>
                              setState(() => _domains.remove(domain)),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _copyFromExisting,
              child: Text(l10n.websites_copyFromExisting),
            ),
          ),
          const SizedBox(height: AppTokens.s24),
          SectionHeader(title: l10n.websites_basicConfig),
          TonalCard(
            child: Column(
              children: [
                AppTextField(
                  controller: _aliasController,
                  label: l10n.websites_alias,
                  hint: l10n.websites_optional,
                ),
                const SizedBox(height: AppTokens.s12),
                DropdownButtonFormField<int>(
                  key: ValueKey('group-${groups.length}-${defaultGroup?.id}'),
                  initialValue: groups.any((group) => group.id == _groupId)
                      ? _groupId
                      : defaultGroup?.id ?? 1,
                  decoration: InputDecoration(labelText: l10n.websites_group),
                  items: [
                    for (final group in groups)
                      DropdownMenuItem(
                        value: group.id,
                        child: Text(group.name),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _groupId = value);
                  },
                ),
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: _portController,
                  label: l10n.websites_port,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppTokens.s8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.websites_relativeDir(
                      '${metadata.valueOrNull?.sitesRootDir ?? '/'}/'
                      '${_domains.isEmpty ? '' : _domains.first}',
                    ),
                    style: AppTextStyles.caption.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.type == 'proxy') ...[
            const SizedBox(height: AppTokens.s24),
            SectionHeader(title: l10n.websites_proxySettings),
            TonalCard(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _protocol,
                    decoration: InputDecoration(
                      labelText: l10n.websites_protocol,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'http://',
                        child: Text('http://'),
                      ),
                      DropdownMenuItem(
                        value: 'https://',
                        child: Text('https://'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _protocol = value);
                    },
                  ),
                  const SizedBox(height: AppTokens.s12),
                  AppTextField(
                    controller: _proxyController,
                    label: l10n.websites_targetAddress,
                    hint: '127.0.0.1:8080',
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
            ),
          ],
          if (widget.type == 'runtime') ...[
            const SizedBox(height: AppTokens.s24),
            SectionHeader(title: l10n.websites_runtime),
            TonalCard(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _runtimeType,
                    decoration: InputDecoration(
                      labelText: l10n.websites_runtime,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'php', child: Text('PHP')),
                      DropdownMenuItem(value: 'nodejs', child: Text('Node.js')),
                      DropdownMenuItem(value: 'java', child: Text('Java')),
                      DropdownMenuItem(value: 'go', child: Text('Go')),
                      DropdownMenuItem(value: 'python', child: Text('Python')),
                      DropdownMenuItem(value: 'dotnet', child: Text('.NET')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _runtimeType = value;
                        _runtimes = const [];
                        _runtime = null;
                      });
                      _loadRuntimes();
                    },
                  ),
                  const SizedBox(height: AppTokens.s12),
                  DropdownButtonFormField<int>(
                    initialValue: _runtime?.id,
                    decoration: InputDecoration(
                      labelText: l10n.websites_runtime,
                    ),
                    items: [
                      for (final runtime in _runtimes)
                        DropdownMenuItem(
                          value: runtime.id,
                          child: Text('${runtime.name} ${runtime.version}'),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _runtime = _runtimes
                            .where((runtime) => runtime.id == value)
                            .firstOrNull;
                        final port = int.tryParse(_runtime?.port ?? '') ?? 0;
                        if (port > 0) _portController.text = '$port';
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppTokens.s24),
          SectionHeader(title: l10n.websites_enableSsl),
          TonalCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.websites_enableSsl),
                  value: _enableSsl,
                  onChanged: (value) => setState(() => _enableSsl = value),
                ),
                if (_enableSsl)
                  DropdownButtonFormField<int>(
                    initialValue: _sslId,
                    decoration: InputDecoration(
                      labelText: l10n.websites_sslCertificate,
                    ),
                    items: [
                      for (final certificate in _certificates)
                        DropdownMenuItem(
                          value: certificate.id,
                          child: Text(certificate.primaryDomain),
                        ),
                    ],
                    onChanged: (value) {
                      final picked = _certificates
                          .where((item) => item.id == value)
                          .firstOrNull;
                      setState(() {
                        _sslId = value;
                        _acmeId = picked?.acmeAccountId;
                      });
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s24),
          SectionHeader(title: l10n.websites_optional),
          TonalCard(
            child: Column(
              children: [
                AppTextField(
                  controller: _remarkController,
                  label: l10n.websites_remark,
                  maxLines: 2,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.websites_ipv6),
                  value: _ipv6,
                  onChanged: (value) => setState(() => _ipv6 = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.websites_enableFtp),
                  value: _enableFtp,
                  onChanged: (value) => setState(() => _enableFtp = value),
                ),
                if (_enableFtp) ...[
                  AppTextField(
                    controller: _ftpUserController,
                    label: l10n.websites_ftpUser,
                  ),
                  const SizedBox(height: AppTokens.s12),
                  AppTextField(
                    controller: _ftpPasswordController,
                    label: l10n.websites_ftpPassword,
                    obscure: true,
                  ),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.websites_createDb),
                  value: _createDb,
                  onChanged: (value) => setState(() => _createDb = value),
                ),
                if (_createDb) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _dbType,
                    decoration: InputDecoration(
                      labelText: l10n.websites_database,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'mysql', child: Text('MySQL')),
                      DropdownMenuItem(
                        value: 'postgresql',
                        child: Text('PostgreSQL'),
                      ),
                      DropdownMenuItem(
                        value: 'mongodb',
                        child: Text('MongoDB'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _dbType = value);
                    },
                  ),
                  const SizedBox(height: AppTokens.s12),
                  AppTextField(
                    controller: _dbHostController,
                    label: l10n.databases_host,
                  ),
                  const SizedBox(height: AppTokens.s12),
                  AppTextField(
                    controller: _dbNameController,
                    label: l10n.websites_dbName,
                  ),
                  const SizedBox(height: AppTokens.s12),
                  AppTextField(
                    controller: _dbUserController,
                    label: l10n.databases_username,
                  ),
                  const SizedBox(height: AppTokens.s12),
                  AppTextField(
                    controller: _dbPasswordController,
                    label: l10n.databases_password,
                    obscure: true,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
