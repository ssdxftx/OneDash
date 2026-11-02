import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/website/website_load_balance_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

class WebsiteLoadBalanceTab extends ConsumerStatefulWidget {
  const WebsiteLoadBalanceTab({super.key, required this.websiteId});

  final int websiteId;

  @override
  ConsumerState<WebsiteLoadBalanceTab> createState() =>
      _WebsiteLoadBalanceTabState();
}

class _WebsiteLoadBalanceTabState extends ConsumerState<WebsiteLoadBalanceTab> {
  List<WebsiteLoadBalanceDto> _upstreams = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final upstreams = await repository.listLoadBalances(widget.websiteId);
      if (!mounted) return;
      setState(() => _upstreams = upstreams);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _algorithmLabel(AppLocalizations l10n, String algorithm) {
    return switch (algorithm) {
      'ip_hash' => l10n.websites_lbIpHash,
      'least_conn' => l10n.websites_lbLeastConn,
      _ => l10n.websites_lbDefault,
    };
  }

  String _flagLabel(AppLocalizations l10n, String flag) {
    return switch (flag) {
      'down' => l10n.websites_lbFlagDown,
      'backup' => l10n.websites_lbFlagBackup,
      _ => l10n.websites_lbFlagNone,
    };
  }

  Future<void> _delete(WebsiteLoadBalanceDto upstream) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.websites_lbDelete,
      message: upstream.name,
      confirmLabel: l10n.action_delete,
      requireText: upstream.name,
    );
    if (!confirmed) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.deleteLoadBalance(widget.websiteId, upstream.name);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showForm({WebsiteLoadBalanceDto? existing}) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController(text: existing?.name ?? '');
    var algorithm = existing?.algorithm.isNotEmpty == true
        ? existing!.algorithm
        : 'default';
    final drafts = <_ServerDraft>[
      if (existing != null && existing.servers.isNotEmpty)
        for (final server in existing.servers) _ServerDraft.fromDto(server)
      else
        _ServerDraft(),
    ];
    final confirmed = await showAppSheet<bool>(
      context: context,
      maxHeightFactor: 0.95,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              existing == null
                  ? l10n.websites_lbAdd
                  : l10n.websites_loadBalance,
              style: AppTextStyles.titleL,
            ),
            const SizedBox(height: AppTokens.s16),
            AppTextField(
              controller: name,
              label: l10n.websites_lbName,
              enabled: existing == null,
              autofocus: existing == null,
            ),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: algorithm,
              decoration: InputDecoration(labelText: l10n.websites_lbAlgorithm),
              items: [
                DropdownMenuItem(
                  value: 'default',
                  child: Text(l10n.websites_lbDefault),
                ),
                DropdownMenuItem(
                  value: 'ip_hash',
                  child: Text(l10n.websites_lbIpHash),
                ),
                DropdownMenuItem(
                  value: 'least_conn',
                  child: Text(l10n.websites_lbLeastConn),
                ),
              ],
              onChanged: (value) {
                if (value != null) setSheetState(() => algorithm = value);
              },
            ),
            const SizedBox(height: AppTokens.s24),
            SectionHeader(title: l10n.websites_lbServers),
            for (var i = 0; i < drafts.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.s12),
                child: _serverEditor(
                  context,
                  l10n,
                  index: i,
                  draft: drafts[i],
                  canRemove: drafts.length > 1,
                  onRemove: () {
                    final removed = drafts.removeAt(i);
                    removed.dispose();
                    setSheetState(() {});
                  },
                ),
              ),
            SecondaryButton(
              label: l10n.websites_lbAddServer,
              icon: TablerIcons.plus,
              onPressed: () {
                setSheetState(() => drafts.add(_ServerDraft()));
              },
            ),
            const SizedBox(height: AppTokens.s24),
            PrimaryButton(
              label: l10n.action_save,
              onPressed: () {
                final upstreamName = name.text.trim();
                if (upstreamName.isEmpty) return;
                final servers = drafts
                    .map((draft) => draft.toDto())
                    .where((server) => server.server.isNotEmpty)
                    .toList(growable: false);
                if (servers.isEmpty) return;
                Navigator.of(sheetContext).pop(true);
                unawaited(
                  _save(
                    existing: existing,
                    name: upstreamName,
                    algorithm: algorithm,
                    servers: servers,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
    name.dispose();
    for (final draft in drafts) {
      draft.dispose();
    }
    if (confirmed != true || !mounted) return;
  }

  Widget _serverEditor(
    BuildContext context,
    AppLocalizations l10n, {
    required int index,
    required _ServerDraft draft,
    required bool canRemove,
    required VoidCallback onRemove,
  }) {
    return TonalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.websites_lbServers} ${index + 1}',
                  style: AppTextStyles.titleS,
                ),
              ),
              if (canRemove)
                IconButton(
                  tooltip: l10n.action_delete,
                  icon: const Icon(TablerIcons.trash),
                  onPressed: onRemove,
                ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          AppTextField(
            controller: draft.server,
            label: l10n.websites_lbServerAddress,
            hint: '127.0.0.1:8080',
          ),
          const SizedBox(height: AppTokens.s8),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: draft.weight,
                  label: l10n.websites_lbWeight,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppTokens.s8),
              Expanded(
                child: AppTextField(
                  controller: draft.maxFails,
                  label: l10n.websites_lbMaxFails,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: AppTextField(
                  controller: draft.failTimeout,
                  label: l10n.websites_lbFailTimeout,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppTokens.s8),
              SizedBox(
                width: 88,
                child: DropdownButtonFormField<String>(
                  initialValue: draft.failTimeoutUnit,
                  items: const [
                    DropdownMenuItem(value: 's', child: Text('s')),
                    DropdownMenuItem(value: 'm', child: Text('m')),
                    DropdownMenuItem(value: 'h', child: Text('h')),
                    DropdownMenuItem(value: 'd', child: Text('d')),
                  ],
                  onChanged: (value) {
                    if (value != null) draft.failTimeoutUnit = value;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          AppTextField(
            controller: draft.maxConns,
            label: l10n.websites_lbMaxConns,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppTokens.s8),
          DropdownButtonFormField<String>(
            initialValue: draft.flag,
            decoration: InputDecoration(labelText: l10n.websites_lbFlag),
            items: [
              DropdownMenuItem(
                value: '',
                child: Text(l10n.websites_lbFlagNone),
              ),
              DropdownMenuItem(
                value: 'down',
                child: Text(l10n.websites_lbFlagDown),
              ),
              DropdownMenuItem(
                value: 'backup',
                child: Text(l10n.websites_lbFlagBackup),
              ),
            ],
            onChanged: (value) => draft.flag = value ?? '',
          ),
        ],
      ),
    );
  }

  Future<void> _save({
    required WebsiteLoadBalanceDto? existing,
    required String name,
    required String algorithm,
    required List<WebsiteLoadBalanceServerDto> servers,
  }) async {
    final l10n = AppLocalizations.of(context);
    final req = WebsiteLoadBalanceReq(
      websiteId: widget.websiteId,
      name: name,
      algorithm: algorithm,
      servers: servers,
    );
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      if (existing == null) {
        await repository.createLoadBalance(req);
      } else {
        await repository.updateLoadBalance(req);
      }
      if (!mounted) return;
      AppToast.success(context, l10n.websites_lbSaved);
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
      return const Center(child: CircularProgressIndicator());
    }
    if (_upstreams.isEmpty) {
      return EmptyState(
        icon: TablerIcons.arrows_exchange,
        title: l10n.websites_loadBalanceEmptyTitle,
        message: l10n.websites_lbEmpty,
        actionLabel: l10n.websites_lbAdd,
        onAction: _showForm,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          SectionHeader(
            title: l10n.websites_loadBalance,
            trailing: TextButton.icon(
              onPressed: _showForm,
              icon: const Icon(TablerIcons.plus, size: AppTokens.iconList),
              label: Text(l10n.websites_lbAdd),
            ),
          ),
          for (final upstream in _upstreams)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.s12),
              child: TonalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            upstream.name,
                            style: AppTextStyles.titleS,
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.action_edit,
                          icon: const Icon(TablerIcons.edit),
                          onPressed: () => _showForm(existing: upstream),
                        ),
                        IconButton(
                          tooltip: l10n.websites_lbDelete,
                          icon: const Icon(TablerIcons.trash),
                          onPressed: () => _delete(upstream),
                        ),
                      ],
                    ),
                    Text(
                      '${l10n.websites_lbAlgorithm}: '
                      '${_algorithmLabel(l10n, upstream.algorithm)}',
                      style: AppTextStyles.bodyS.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.s8),
                    for (final (index, server) in upstream.servers.indexed) ...[
                      if (index > 0)
                        Divider(
                          height: AppTokens.s16,
                          color: context.scheme.outlineVariant,
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  server.server,
                                  style: AppTextStyles.bodyM,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppTokens.s8),
                              Text(
                                _flagLabel(l10n, server.flag),
                                style: AppTextStyles.bodyS.copyWith(
                                  color: context.scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${l10n.websites_lbWeight} '
                            '${server.weight} · '
                            '${l10n.websites_lbMaxFails} '
                            '${server.maxFails} · '
                            '${l10n.websites_lbFailTimeout} '
                            '${server.failTimeout}'
                            '${server.failTimeoutUnit} · '
                            '${l10n.websites_lbMaxConns} '
                            '${server.maxConns}',
                            style: AppTextStyles.bodyS.copyWith(
                              color: context.scheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ServerDraft {
  _ServerDraft()
    : server = TextEditingController(),
      weight = TextEditingController(text: '1'),
      failTimeout = TextEditingController(text: '10'),
      maxFails = TextEditingController(text: '3'),
      maxConns = TextEditingController(text: '0'),
      failTimeoutUnit = 's',
      flag = '';

  _ServerDraft.fromDto(WebsiteLoadBalanceServerDto dto)
    : server = TextEditingController(text: dto.server),
      weight = TextEditingController(text: '${dto.weight}'),
      failTimeout = TextEditingController(text: '${dto.failTimeout}'),
      maxFails = TextEditingController(text: '${dto.maxFails}'),
      maxConns = TextEditingController(text: '${dto.maxConns}'),
      failTimeoutUnit = dto.failTimeoutUnit.isEmpty ? 's' : dto.failTimeoutUnit,
      flag = dto.flag;

  final TextEditingController server;
  final TextEditingController weight;
  final TextEditingController failTimeout;
  final TextEditingController maxFails;
  final TextEditingController maxConns;
  String failTimeoutUnit;
  String flag;

  WebsiteLoadBalanceServerDto toDto() {
    return WebsiteLoadBalanceServerDto(
      server: server.text.trim(),
      weight: int.tryParse(weight.text.trim()) ?? 1,
      failTimeout: int.tryParse(failTimeout.text.trim()) ?? 10,
      failTimeoutUnit: failTimeoutUnit,
      maxFails: int.tryParse(maxFails.text.trim()) ?? 3,
      maxConns: int.tryParse(maxConns.text.trim()) ?? 0,
      flag: flag,
    );
  }

  void dispose() {
    server.dispose();
    weight.dispose();
    failTimeout.dispose();
    maxFails.dispose();
    maxConns.dispose();
  }
}
