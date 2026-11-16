import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/host/remote_host_dto.dart';
import '../../../../data/repositories_impl/host_repository_impl.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

final _remoteHostsProvider = FutureProvider.autoDispose
    .family<_RemoteHostsData, int>((ref, serverId) async {
      final repository = await ref.watch(
        hostRepositoryProvider(serverId).future,
      );
      final results = await Future.wait<Object>([
        repository.searchRemoteHosts(),
        repository.getRemoteHostTree(),
      ]);
      return _RemoteHostsData(
        hosts: results[0] as List<RemoteHostDto>,
        groups: results[1] as List<RemoteHostTreeDto>,
      );
    }, name: 'remoteHostsProvider');

class HostRemoteTab extends ConsumerStatefulWidget {
  const HostRemoteTab({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<HostRemoteTab> createState() => _HostRemoteTabState();
}

class _HostRemoteTabState extends ConsumerState<HostRemoteTab> {
  void _refresh() {
    ref.invalidate(_remoteHostsProvider(widget.serverId));
  }

  Future<void> _edit({
    RemoteHostDto? host,
    required List<RemoteHostTreeDto> groups,
  }) async {
    final request = await pushFormPage<_RemoteHostRequest>(
      context,
      _RemoteHostForm(serverId: widget.serverId, host: host, groups: groups),
    );
    if (request == null || !mounted) return;
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      if (host == null) {
        await repository.createRemoteHost(request.toJson());
      } else {
        await repository.updateRemoteHost(request.toJson());
      }
      if (!mounted) return;
      AppToast.success(context, AppLocalizations.of(context).host_remoteSaved);
      _refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(RemoteHostDto host) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.host_deleteRemote,
      message: l10n.host_deleteRemoteMessage(
        host.name.isEmpty ? host.addr : host.name,
      ),
      confirmLabel: l10n.action_delete,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      await repository.deleteRemoteHosts([host.id]);
      _refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _test(RemoteHostDto host) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      final ok = await repository.testRemoteHostById(host.id);
      if (!mounted) return;
      if (ok) {
        AppToast.success(context, l10n.host_connectionOk);
      } else {
        AppToast.error(context, l10n.host_connectionFailed);
      }
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = ref.watch(_remoteHostsProvider(widget.serverId));
    return AsyncStateView(
      value: value,
      onRetry: _refresh,
      loading: const SkeletonList(itemCount: 5),
      isEmpty: (data) => data.hosts.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.server_2,
        title: l10n.host_noRemote,
        message: l10n.host_noRemoteHint,
        actionLabel: l10n.host_addRemote,
        onAction: () async {
          final data = value.valueOrNull;
          if (data == null) return;
          await _edit(groups: data.groups);
        },
      ),
      builder: (data) => RefreshIndicator(
        onRefresh: () async {
          _refresh();
          await ref.read(_remoteHostsProvider(widget.serverId).future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(context.pagePadding),
          children: [
            SizedBox(
              width: double.infinity,
              child: SecondaryButton(
                label: l10n.host_addRemote,
                icon: TablerIcons.plus,
                onPressed: () => _edit(groups: data.groups),
              ),
            ),
            const SizedBox(height: AppTokens.s16),
            for (final host in data.hosts) ...[
              TonalCard(
                onTap: () => _edit(host: host, groups: data.groups),
                child: Row(
                  children: [
                    Icon(
                      host.authMode == 'key'
                          ? TablerIcons.key
                          : TablerIcons.lock,
                      color: context.scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppTokens.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            host.name.isEmpty ? host.addr : host.name,
                            style: AppTextStyles.titleM,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${host.user}@${host.addr}:${host.port}',
                            style: AppTextStyles.caption.copyWith(
                              color: context.scheme.onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.host_sshTerminal,
                      icon: const Icon(TablerIcons.terminal_2),
                      onPressed: () => context.push(
                        '/s/${widget.serverId}/terminal?sshHostId=${host.id}',
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.host_testConnection,
                      icon: const Icon(TablerIcons.plug_connected),
                      onPressed: () => _test(host),
                    ),
                    IconButton(
                      tooltip: l10n.action_delete,
                      icon: const Icon(TablerIcons.trash),
                      onPressed: () => _delete(host),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.s8),
            ],
          ],
        ),
      ),
    );
  }
}

class _RemoteHostsData {
  const _RemoteHostsData({required this.hosts, required this.groups});

  final List<RemoteHostDto> hosts;
  final List<RemoteHostTreeDto> groups;
}

class _RemoteHostRequest {
  const _RemoteHostRequest(this.json);

  final Map<String, dynamic> json;

  Map<String, dynamic> toJson() => json;
}

List<RemoteHostTreeDto> _flattenGroups(List<RemoteHostTreeDto> groups) {
  final result = <RemoteHostTreeDto>[];
  void walk(List<RemoteHostTreeDto> items) {
    for (final item in items) {
      result.add(item);
      if (item.children.isNotEmpty) walk(item.children);
    }
  }

  walk(groups);
  return result;
}

class _RemoteHostForm extends ConsumerStatefulWidget {
  const _RemoteHostForm({
    required this.serverId,
    this.host,
    required this.groups,
  });

  final int serverId;
  final RemoteHostDto? host;
  final List<RemoteHostTreeDto> groups;

  @override
  ConsumerState<_RemoteHostForm> createState() => _RemoteHostFormState();
}

class _RemoteHostFormState extends ConsumerState<_RemoteHostForm> {
  late final TextEditingController _name = TextEditingController(
    text: widget.host?.name ?? '',
  );
  late final TextEditingController _addr = TextEditingController(
    text: widget.host?.addr ?? '',
  );
  late final TextEditingController _port = TextEditingController(
    text: '${widget.host?.port ?? 22}',
  );
  late final TextEditingController _user = TextEditingController(
    text: widget.host?.user ?? 'root',
  );
  late final TextEditingController _password = TextEditingController(
    text: '${widget.host?.json['password'] ?? ''}',
  );
  late final TextEditingController _privateKey = TextEditingController(
    text: '${widget.host?.json['privateKey'] ?? ''}',
  );
  late final TextEditingController _passphrase = TextEditingController(
    text: '${widget.host?.json['passPhrase'] ?? ''}',
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.host?.description ?? '',
  );
  late String _authMode = widget.host?.authMode == 'key' ? 'key' : 'password';
  late final List<RemoteHostTreeDto> _groupOptions = _flattenGroups(
    widget.groups,
  );
  late int _groupId =
      _groupOptions.any((group) => group.id == (widget.host?.groupId ?? 0))
      ? (widget.host?.groupId ?? 0)
      : 0;
  late bool _rememberPassword = widget.host?.rememberPassword ?? false;
  bool _testing = false;

  @override
  void dispose() {
    _name.dispose();
    _addr.dispose();
    _port.dispose();
    _user.dispose();
    _password.dispose();
    _privateKey.dispose();
    _passphrase.dispose();
    _description.dispose();
    super.dispose();
  }

  Map<String, dynamic> _body() {
    return {
      'id': widget.host?.id ?? 0,
      'groupID': _groupId,
      'name': _name.text.trim(),
      'addr': _addr.text.trim(),
      'port': int.tryParse(_port.text.trim()) ?? 22,
      'user': _user.text.trim(),
      'authMode': _authMode,
      'password': _authMode == 'password'
          ? base64Encode(utf8.encode(_password.text))
          : '',
      'privateKey': _authMode == 'key'
          ? base64Encode(utf8.encode(_privateKey.text))
          : '',
      'passPhrase': _passphrase.text,
      'rememberPassword': _rememberPassword,
      'description': _description.text.trim(),
    };
  }

  Future<void> _test() async {
    final l10n = AppLocalizations.of(context);
    final body = _body()..remove('id');
    setState(() => _testing = true);
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      final ok = await repository.testRemoteHost(body);
      if (!mounted) return;
      if (ok) {
        AppToast.success(context, l10n.host_connectionOk);
      } else {
        AppToast.error(context, l10n.host_connectionFailed);
      }
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SimpleFormPage(
      title: widget.host == null ? l10n.host_addRemote : l10n.action_edit,
      onSave: () async {
        if (_addr.text.trim().isEmpty || _user.text.trim().isEmpty) return;
        Navigator.of(context).pop(_RemoteHostRequest(_body()));
      },
      children: [
        AppTextField(controller: _name, label: l10n.host_remoteName),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: _addr, label: l10n.host_address),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _port,
          label: l10n.host_port,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: _user, label: l10n.host_user),
        const SizedBox(height: AppTokens.s12),
        DropdownButtonFormField<String>(
          initialValue: _authMode,
          decoration: InputDecoration(labelText: l10n.host_authMode),
          items: [
            DropdownMenuItem(
              value: 'password',
              child: Text(l10n.host_authPassword),
            ),
            DropdownMenuItem(value: 'key', child: Text(l10n.host_authKey)),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _authMode = value);
          },
        ),
        const SizedBox(height: AppTokens.s12),
        if (_authMode == 'password')
          AppTextField(
            controller: _password,
            label: l10n.host_password,
            obscure: true,
          )
        else ...[
          AppTextField(
            controller: _privateKey,
            label: l10n.host_privateKey,
            maxLines: 4,
          ),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: _passphrase,
            label: l10n.host_passphrase,
            obscure: true,
          ),
        ],
        const SizedBox(height: AppTokens.s12),
        DropdownButtonFormField<int>(
          initialValue: _groupId,
          decoration: InputDecoration(labelText: l10n.host_group),
          items: [
            DropdownMenuItem(value: 0, child: Text(l10n.host_noGroup)),
            for (final group in _groupOptions)
              DropdownMenuItem(value: group.id, child: Text(group.label)),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _groupId = value);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.host_rememberPassword),
          value: _rememberPassword,
          onChanged: (value) => setState(() => _rememberPassword = value),
        ),
        AppTextField(controller: _description, label: l10n.host_description),
        const SizedBox(height: AppTokens.s16),
        SecondaryButton(
          label: l10n.host_testConnection,
          icon: TablerIcons.plug_connected,
          loading: _testing,
          onPressed: _testing ? null : _test,
        ),
      ],
    );
  }
}
