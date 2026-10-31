import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/api/firewall_api.dart';
import '../../../../data/dto/firewall/firewall_base_info_dto.dart';
import '../../../../data/dto/firewall/firewall_v2_dto.dart';
import '../../../../data/repositories_impl/firewall_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/search_field.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../../servers/providers/servers_provider.dart';

class _FirewallData {
  const _FirewallData({
    required this.base,
    required this.settings,
    required this.inventory,
    required this.forwardBase,
    required this.forward,
    required this.docker,
  });

  final FirewallBaseInfoDto base;
  final FirewallSettingsInfo settings;
  final FirewallInventory inventory;
  final FirewallBaseInfoDto forwardBase;
  final FirewallForwardPage forward;
  final DockerGuardInfo docker;

  String get provider => base.name.isEmpty ? 'iptables' : base.name;
}

final _firewallProvider = FutureProvider.autoDispose<_FirewallData>(
  (ref) async {
    final repository = await ref.watch(firewallRepositoryProvider.future);
    final base = await repository.getBaseInfo();
    final provider = base.name.isEmpty ? 'iptables' : base.name;

    FirewallSettingsInfo settings = const FirewallSettingsInfo({});
    try {
      settings = await repository.getSettings();
    } catch (_) {
      // Settings are optional for the rules view.
    }

    FirewallBaseInfoDto forwardBase = const FirewallBaseInfoDto(
      name: '',
      isExist: false,
      isActive: false,
      isInit: false,
      isBind: false,
      version: '',
      pingStatus: '',
    );
    try {
      forwardBase = await repository.getForwardBase();
    } catch (_) {
      // Forwarding is optional on minimal panels.
    }

    FirewallForwardPage forward = const FirewallForwardPage(
      total: 0,
      items: [],
    );
    try {
      forward = await repository.searchForwardRules();
    } catch (_) {
      // Keep the rules tab usable when forwarding is unavailable.
    }

    DockerGuardInfo docker = const DockerGuardInfo({});
    try {
      docker = await repository.getDockerGuard();
    } catch (_) {
      // Docker guard is optional.
    }

    final inventory = await repository.searchRules(provider: provider);
    return _FirewallData(
      base: base,
      settings: settings,
      inventory: inventory,
      forwardBase: forwardBase,
      forward: forward,
      docker: docker,
    );
  },
  dependencies: [firewallRepositoryProvider],
  name: 'firewallProvider',
);

class FirewallPage extends ConsumerStatefulWidget {
  const FirewallPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<FirewallPage> createState() => _FirewallPageState();
}

class _FirewallPageState extends ConsumerState<FirewallPage> {
  final _searchController = TextEditingController();
  int _tab = 0;
  bool _searching = false;
  bool _operating = false;
  String _filter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(_firewallProvider);
    await ref.read(_firewallProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final server = ref.watch(serverByIdProvider(widget.serverId)).valueOrNull;
    final firewall = ref.watch(_firewallProvider);

    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.firewall_title,
        subtitle: server?.displayName,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _refresh,
          ),
        ],
      ),
      floatingActionButton: _tab == 0 || _tab == 1
          ? FloatingActionButton(
              tooltip: _tab == 0
                  ? l10n.firewall_add_rule
                  : l10n.firewall_addForward,
              onPressed: _openAdd,
              child: const Icon(TablerIcons.plus),
            )
          : null,
      body: AsyncStateView(
        value: firewall,
        onRetry: () => ref.invalidate(_firewallProvider),
        loading: const SkeletonList(itemCount: 6),
        builder: (data) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s16,
                AppTokens.s8,
                AppTokens.s16,
                AppTokens.s16,
              ),
              child: _StatusCard(
                data: data,
                operating: _operating,
                onToggle: (value) => _toggleService(data, value),
              ),
            ),
            SegmentedTabs(
              labels: [
                l10n.firewall_tabRules,
                l10n.firewall_tabForward,
                l10n.firewall_tabDocker,
                l10n.firewall_tabSettings,
              ],
              selectedIndex: _tab,
              onChanged: (value) => setState(() => _tab = value),
            ),
            if (_tab == 0) ...[
              if (_searching)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.s16,
                    vertical: AppTokens.s8,
                  ),
                  child: SearchField(
                    controller: _searchController,
                    hint: l10n.firewall_searchHint,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              AppFilterChips<String>(
                options: const ['all', 'ipv4', 'ipv6', 'allow', 'deny'],
                labelOf: (value) => switch (value) {
                  'ipv4' => l10n.firewall_filterIpv4,
                  'ipv6' => l10n.firewall_filterIpv6,
                  'allow' => l10n.firewall_filterAllow,
                  'deny' => l10n.firewall_filterDeny,
                  _ => l10n.firewall_filterAll,
                },
                selected: {_filter},
                onChanged: (selection) {
                  if (selection.isEmpty) return;
                  setState(() => _filter = selection.first);
                },
              ),
            ],
            Expanded(
              child: switch (_tab) {
                0 => _RulesTab(
                  data: data,
                  query: _searchController.text.trim().toLowerCase(),
                  filter: _filter,
                  onSearchToggle: () {
                    setState(() {
                      _searching = !_searching;
                      if (!_searching) _searchController.clear();
                    });
                  },
                  onEdit: (item) => _showRuleSheet(data, item: item),
                  onDelete: _deleteRule,
                  onReorder: _reorderRule,
                  onAdd: () => _showRuleSheet(data),
                  onRefresh: _refresh,
                ),
                1 => _ForwardTab(
                  data: data,
                  onAdd: () => _showForwardSheet(data),
                  onEdit: (rule) => _showForwardSheet(data, rule: rule),
                  onDelete: _deleteForward,
                  onEnable: _enableForward,
                ),
                2 => _DockerTab(
                  data: data,
                  operating: _operating,
                  onToggle: _toggleDockerGuard,
                ),
                _ => _SettingsTab(
                  data: data,
                  onIpv6Changed: _updateIpv6,
                  onAddWhitelist: _showWhitelistSheet,
                  onDeleteWhitelist: _deleteWhitelist,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleService(_FirewallData data, bool value) async {
    if (_operating) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _operating = true);
    try {
      final repository = await ref.read(firewallRepositoryProvider.future);
      await repository.operate(value ? 'start' : 'stop');
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_firewallProvider);
      await Future<void>.delayed(const Duration(seconds: 2));
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _operating = false);
    }
  }

  Future<void> _openAdd() async {
    final data = ref.read(_firewallProvider).valueOrNull;
    if (data == null) return;
    if (_tab == 0) {
      await _showRuleSheet(data);
    } else if (_tab == 1) {
      await _showForwardSheet(data);
    }
  }

  Future<void> _deleteRule(FirewallRuleItem item) async {
    final l10n = AppLocalizations.of(context);
    final title = _ruleTitle(item.rule, l10n);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.firewall_ruleDeleteTitle(title),
      message: l10n.firewall_ruleDeleteMessage,
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(firewallRepositoryProvider.future);
      await repository.deleteRule(item);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_firewallProvider);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _reorderRule(FirewallRuleItem item, int delta) async {
    final l10n = AppLocalizations.of(context);
    final position = item.position;
    if (position == null) return;
    final target = position + delta;
    if (target < 1) return;
    try {
      final repository = await ref.read(firewallRepositoryProvider.future);
      await repository.reorderRule(item, targetPosition: target);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_firewallProvider);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showRuleSheet(
    _FirewallData data, {
    FirewallRuleItem? item,
  }) async {
    final draft = await showAppSheet<_RuleDraft>(
      context: context,
      builder: (sheetContext) =>
          _RuleSheet(baseProvider: data.provider, item: item),
    );
    if (draft == null || !mounted) return;
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(firewallRepositoryProvider.future);
      if (item == null) {
        await repository.createRule(draft.toRuleJson(data.provider));
      } else {
        await repository.updateRule(
          item,
          rule: draft.toRuleJson(data.provider, existing: item.rule.json),
        );
      }
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_firewallProvider);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showForwardSheet(
    _FirewallData data, {
    FirewallForwardRule? rule,
  }) async {
    final draft = await showAppSheet<_ForwardDraft>(
      context: context,
      builder: (sheetContext) => _ForwardSheet(rule: rule),
    );
    if (draft == null || !mounted) return;
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(firewallRepositoryProvider.future);
      final operations = <Map<String, dynamic>>[];
      if (rule != null) {
        operations.add(rule.toJson(operation: 'remove'));
      }
      operations.add(draft.toJson(operation: 'add'));
      await repository.operateForwardRule(operations);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_firewallProvider);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _deleteForward(FirewallForwardRule rule) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.firewall_ruleDeleteTitle(
        '${rule.port}/${rule.protocol} → ${rule.targetIP}:${rule.targetPort}',
      ),
      message: l10n.firewall_ruleDeleteMessage,
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(firewallRepositoryProvider.future);
      await repository.operateForwardRule([rule.toJson(operation: 'remove')]);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_firewallProvider);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _enableForward() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(firewallRepositoryProvider.future);
      await repository.enableForwarding();
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_firewallProvider);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _toggleDockerGuard(bool value) async {
    if (_operating) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _operating = true);
    try {
      final repository = await ref.read(firewallRepositoryProvider.future);
      await repository.operateDockerGuard(value ? 'bind' : 'unbind');
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_firewallProvider);
      await Future<void>.delayed(const Duration(seconds: 2));
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _operating = false);
    }
  }

  Future<void> _updateIpv6(bool value) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(firewallRepositoryProvider.future);
      await repository.updateIPv6(value);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_firewallProvider);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showWhitelistSheet() async {
    final l10n = AppLocalizations.of(context);
    final portController = TextEditingController();
    final sourcesController = TextEditingController();
    String protocol = 'tcp';
    final rule = await showAppSheet<FirewallWhitelistRule>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.firewall_whitelistAdd, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            AppTextField(
              controller: portController,
              label: l10n.firewall_whitelistPort,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: protocol,
              decoration: InputDecoration(
                labelText: l10n.firewall_whitelistProtocol,
              ),
              items: const [
                DropdownMenuItem(value: 'tcp', child: Text('TCP')),
                DropdownMenuItem(value: 'udp', child: Text('UDP')),
              ],
              onChanged: (value) {
                if (value != null) setSheetState(() => protocol = value);
              },
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: sourcesController,
              label: l10n.firewall_whitelistSources,
              hint: l10n.firewall_whitelistSourcesHint,
            ),
            const SizedBox(height: AppTokens.s24),
            PrimaryButton(
              label: l10n.action_save,
              onPressed: () {
                final port = portController.text.trim();
                final sources = sourcesController.text
                    .split(',')
                    .map((value) => value.trim())
                    .where((value) => value.isNotEmpty)
                    .toList();
                if (port.isEmpty || sources.isEmpty) {
                  AppToast.warning(context, l10n.firewall_whitelistRequired);
                  return;
                }
                Navigator.of(sheetContext).pop(
                  FirewallWhitelistRule({
                    'port': port,
                    'protocol': protocol,
                    'sources': sources,
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
    portController.dispose();
    sourcesController.dispose();
    if (rule == null || !mounted) return;
    try {
      final repository = await ref.read(firewallRepositoryProvider.future);
      await repository.createWhitelist(rule);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_firewallProvider);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _deleteWhitelist(FirewallWhitelistRule rule) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.firewall_ruleDeleteTitle('${rule.port}/${rule.protocol}'),
      message: l10n.firewall_ruleDeleteMessage,
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(firewallRepositoryProvider.future);
      await repository.deleteWhitelist(rule);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_firewallProvider);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.data,
    required this.operating,
    required this.onToggle,
  });

  final _FirewallData data;
  final bool operating;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final active = data.base.isActive;
    return TonalCard(
      child: Row(
        children: [
          Icon(
            active ? TablerIcons.shield_check : TablerIcons.shield_off,
            color: active
                ? context.appColors.success
                : context.appColors.danger,
          ),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active ? l10n.common_running : l10n.common_stopped,
                  style: AppTextStyles.titleM,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    data.base.backend.isEmpty
                        ? data.base.name
                        : data.base.backend,
                    'v${data.base.version}',
                    l10n.firewall_rulesCount(data.inventory.total),
                  ].where((value) => value.isNotEmpty).join(' · '),
                  style: AppTextStyles.bodyS.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: active, onChanged: operating ? null : onToggle),
        ],
      ),
    );
  }
}

class _RulesTab extends StatelessWidget {
  const _RulesTab({
    required this.data,
    required this.query,
    required this.filter,
    required this.onSearchToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
    required this.onAdd,
    required this.onRefresh,
  });

  final _FirewallData data;
  final String query;
  final String filter;
  final VoidCallback onSearchToggle;
  final ValueChanged<FirewallRuleItem> onEdit;
  final ValueChanged<FirewallRuleItem> onDelete;
  final void Function(FirewallRuleItem item, int delta) onReorder;
  final VoidCallback onAdd;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = data.inventory.items.where((item) {
      final rule = item.rule;
      if (filter == 'ipv4' && rule.scope.family != 'ipv4') return false;
      if (filter == 'ipv6' && rule.scope.family != 'ipv6') return false;
      if (filter == 'allow' && !rule.isAccept) return false;
      if (filter == 'deny' && !rule.isDeny) return false;
      if (query.isEmpty) return true;
      return [
        rule.sourceAddress,
        rule.destinationAddress,
        rule.destinationPort,
        rule.protocol,
        rule.description,
        rule.interface,
      ].any((value) => value.toLowerCase().contains(query));
    }).toList();

    if (items.isEmpty) {
      return EmptyState(
        icon: TablerIcons.shield,
        title: l10n.firewall_tabRules,
        message: l10n.firewall_add_rule,
        actionLabel: l10n.firewall_add_rule,
        onAction: onAdd,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s8,
          AppTokens.s16,
          AppTokens.s32 + AppTokens.buttonHeight,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.firewall_rulesCount(items.length),
                  style: AppTextStyles.bodyS.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.action_search,
                onPressed: onSearchToggle,
                icon: const Icon(TablerIcons.search),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          SplitListGroup(
            children: [
              for (final item in items)
                _RuleTile(
                  item: item,
                  onEdit: () => onEdit(item),
                  onDelete: () => onDelete(item),
                  onMoveUp: () => onReorder(item, -1),
                  onMoveDown: () => onReorder(item, 1),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  const _RuleTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final FirewallRuleItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rule = item.rule;
    final scheme = context.scheme;
    final canManage = item.canDelete && !item.isWhitelist;
    final subtitle = [
      if (rule.description.isNotEmpty) rule.description,
      if (rule.interface.isNotEmpty) rule.interface,
      if (item.isWhitelist) 'whitelist',
    ].join(' · ');

    return SplitListTile(
      leading: Icon(
        rule.isAccept ? TablerIcons.check : TablerIcons.x,
        color: rule.isAccept
            ? context.appColors.success
            : context.appColors.danger,
      ),
      title: _ruleTitle(rule, l10n),
      subtitle: subtitle.isEmpty ? null : subtitle,
      trailing: canManage
          ? PopupMenuButton<String>(
              tooltip: l10n.action_more,
              icon: Icon(
                TablerIcons.dots_vertical,
                color: scheme.onSurfaceVariant,
              ),
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
                if (value == 'up') onMoveUp();
                if (value == 'down') onMoveDown();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(l10n.firewall_editRule),
                ),
                PopupMenuItem(
                  value: 'up',
                  enabled: item.position != null && item.position! > 1,
                  child: Text(l10n.firewall_moveUp),
                ),
                PopupMenuItem(
                  value: 'down',
                  child: Text(l10n.firewall_moveDown),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(l10n.firewall_deleteRule),
                ),
              ],
            )
          : null,
    );
  }
}

String _ruleTitle(FirewallRuleInfo rule, AppLocalizations l10n) {
  final address = rule.sourceAddress.isEmpty
      ? l10n.firewall_anyAddress
      : rule.sourceAddress;
  final port = rule.displayPort.isEmpty
      ? l10n.firewall_anyPort
      : rule.displayPort;
  final protocol = rule.protocol.isEmpty ? 'all' : rule.protocol;
  return '$address · $port/$protocol';
}

class _ForwardTab extends StatelessWidget {
  const _ForwardTab({
    required this.data,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onEnable,
  });

  final _FirewallData data;
  final VoidCallback onAdd;
  final ValueChanged<FirewallForwardRule> onEdit;
  final ValueChanged<FirewallForwardRule> onDelete;
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final enabled = data.forwardBase.isActive;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.s16,
        AppTokens.s8,
        AppTokens.s16,
        AppTokens.s32 + AppTokens.buttonHeight,
      ),
      children: [
        TonalCard(
          child: Row(
            children: [
              Icon(
                enabled
                    ? TablerIcons.arrows_exchange
                    : TablerIcons.arrows_exchange,
                color: enabled
                    ? context.appColors.success
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppTokens.s12),
              Expanded(
                child: Text(
                  enabled
                      ? l10n.firewall_forwardEnabled
                      : l10n.firewall_tabForward,
                  style: AppTextStyles.titleM,
                ),
              ),
              if (!enabled)
                TextButton(
                  onPressed: onEnable,
                  child: Text(l10n.firewall_enableForward),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.s24),
        SectionHeader(title: l10n.firewall_tabForward),
        if (data.forward.items.isEmpty)
          EmptyState(
            icon: TablerIcons.arrows_exchange,
            title: l10n.firewall_forwardEmptyTitle,
            message: l10n.firewall_forwardEmptyMessage,
            actionLabel: l10n.firewall_addForward,
            onAction: onAdd,
          )
        else
          SplitListGroup(
            children: [
              for (final rule in data.forward.items)
                SplitListTile(
                  leading: const Icon(TablerIcons.arrows_exchange),
                  title:
                      '${rule.port}/${rule.protocol} → ${rule.targetIP}:${rule.targetPort}',
                  subtitle: [
                    rule.family.toUpperCase(),
                    if (rule.interface.isNotEmpty) rule.interface,
                  ].join(' · '),
                  trailing: PopupMenuButton<String>(
                    tooltip: l10n.action_more,
                    icon: Icon(
                      TablerIcons.dots_vertical,
                      color: scheme.onSurfaceVariant,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') onEdit(rule);
                      if (value == 'delete') onDelete(rule);
                    },
                    itemBuilder: (context) => [
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
      ],
    );
  }
}

class _DockerTab extends StatelessWidget {
  const _DockerTab({
    required this.data,
    required this.operating,
    required this.onToggle,
  });

  final _FirewallData data;
  final bool operating;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final docker = data.docker;
    final endpoints = docker.endpoints;
    final active = docker.isEffective;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.s16,
        AppTokens.s8,
        AppTokens.s16,
        AppTokens.s32,
      ),
      children: [
        TonalCard(
          child: Row(
            children: [
              Icon(
                active ? TablerIcons.shield_check : TablerIcons.shield_off,
                color: active
                    ? context.appColors.success
                    : context.appColors.warning,
              ),
              const SizedBox(width: AppTokens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.firewall_dockerGuard,
                      style: AppTextStyles.titleM,
                    ),
                    Text(
                      active
                          ? l10n.firewall_dockerGuardEnabled
                          : l10n.firewall_dockerGuardDisabled,
                      style: AppTextStyles.bodyS.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(value: active, onChanged: operating ? null : onToggle),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.s24),
        SectionHeader(title: l10n.firewall_dockerEndpoint),
        if (endpoints.isEmpty)
          EmptyState(
            icon: TablerIcons.shield,
            title: l10n.firewall_dockerGuardEmpty,
            message: l10n.firewall_dockerGuard,
          )
        else
          SplitListGroup(
            children: [
              for (final endpoint in endpoints)
                SplitListTile(
                  leading: Icon(
                    endpoint.effective
                        ? TablerIcons.lock
                        : TablerIcons.lock_open,
                  ),
                  title:
                      '${endpoint.hostPort}/${endpoint.protocol} → ${endpoint.containerPort}',
                  subtitle: [
                    endpoint.containerName,
                    endpoint.hostIP.isEmpty ? '0.0.0.0' : endpoint.hostIP,
                  ].where((value) => value.isNotEmpty).join(' · '),
                ),
            ],
          ),
      ],
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({
    required this.data,
    required this.onIpv6Changed,
    required this.onAddWhitelist,
    required this.onDeleteWhitelist,
  });

  final _FirewallData data;
  final ValueChanged<bool> onIpv6Changed;
  final VoidCallback onAddWhitelist;
  final ValueChanged<FirewallWhitelistRule> onDeleteWhitelist;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = data.settings;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.s16,
        AppTokens.s8,
        AppTokens.s16,
        AppTokens.s32,
      ),
      children: [
        SectionHeader(title: l10n.firewall_tabSettings),
        SplitListGroup(
          children: [
            SplitListTile(
              leading: const Icon(TablerIcons.server),
              title: l10n.firewall_settingsBackend,
              trailing: Text(
                settings.system.current.isEmpty
                    ? data.base.backend
                    : settings.system.current,
              ),
            ),
            SplitListTile(
              leading: const Icon(TablerIcons.info_circle),
              title: l10n.firewall_settingsVersion,
              trailing: Text(data.base.version),
            ),
            SplitListTile(
              leading: const Icon(TablerIcons.network),
              title: l10n.firewall_settingsPanelPort,
              trailing: Text(settings.panelPort),
            ),
            SplitListTile(
              leading: const Icon(TablerIcons.terminal),
              title: l10n.firewall_settingsSshPort,
              trailing: Text(settings.sshPort),
            ),
            SplitListTile(
              leading: const Icon(TablerIcons.world),
              title: l10n.firewall_settingsIpv6,
              subtitle: l10n.firewall_settingsIpv6Hint,
              trailing: Switch(
                value: settings.ipv6Enabled,
                onChanged: onIpv6Changed,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s24),
        SectionHeader(
          title: l10n.firewall_settingsWhitelist,
          trailing: TextButton(
            onPressed: onAddWhitelist,
            child: Text(l10n.action_add),
          ),
        ),
        if (settings.whitelist.isEmpty)
          EmptyState(
            icon: TablerIcons.list,
            title: l10n.firewall_settingsWhitelist,
            message: l10n.firewall_whitelistSourcesHint,
            actionLabel: l10n.firewall_whitelistAdd,
            onAction: onAddWhitelist,
          )
        else
          SplitListGroup(
            children: [
              for (final rule in settings.whitelist)
                SplitListTile(
                  leading: const Icon(TablerIcons.list),
                  title: '${rule.port}/${rule.protocol}',
                  subtitle: rule.sources.join(', '),
                  trailing: IconButton(
                    tooltip: l10n.action_delete,
                    onPressed: () => onDeleteWhitelist(rule),
                    icon: const Icon(TablerIcons.trash),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _RuleDraft {
  const _RuleDraft({
    required this.family,
    required this.protocol,
    required this.action,
    required this.address,
    required this.port,
    required this.remark,
    required this.interface,
  });

  final String family;
  final String protocol;
  final String action;
  final String address;
  final String port;
  final String remark;
  final String interface;

  Map<String, dynamic> toRuleJson(
    String provider, {
    Map<String, dynamic> existing = const {},
  }) {
    return {
      ...existing,
      'scope': FirewallApi.scopeFor(provider, family),
      'nativeKind': 'rule',
      'protocol': protocol,
      'sourceAddress': address,
      'destinationPort': port,
      'action': action,
      'description': remark,
      if (interface.isNotEmpty) 'interface': interface,
    };
  }
}

class _RuleSheet extends StatefulWidget {
  const _RuleSheet({required this.baseProvider, this.item});

  final String baseProvider;
  final FirewallRuleItem? item;

  @override
  State<_RuleSheet> createState() => _RuleSheetState();
}

class _RuleSheetState extends State<_RuleSheet> {
  late final TextEditingController _address;
  late final TextEditingController _port;
  late final TextEditingController _remark;
  late final TextEditingController _interface;
  late String _family;
  late String _protocol;
  late String _action;
  String? _error;

  @override
  void initState() {
    super.initState();
    final rule = widget.item?.rule;
    _address = TextEditingController(text: rule?.sourceAddress ?? '');
    _port = TextEditingController(text: rule?.destinationPort ?? '');
    _remark = TextEditingController(text: rule?.description ?? '');
    _interface = TextEditingController(text: rule?.interface ?? '');
    _family = rule?.scope.family == 'ipv6' ? 'ipv6' : 'ipv4';
    _protocol = rule?.protocol == 'udp' ? 'udp' : 'tcp';
    _action = rule?.isDeny == true ? 'drop' : 'accept';
  }

  @override
  void dispose() {
    _address.dispose();
    _port.dispose();
    _remark.dispose();
    _interface.dispose();
    super.dispose();
  }

  bool _validPorts(String value) {
    if (value.isEmpty) return true;
    for (final part in value.split(',')) {
      final pieces = part.trim().split('-');
      if (pieces.length > 2) return false;
      for (final piece in pieces) {
        final port = int.tryParse(piece);
        if (port == null || port < 1 || port > 65535) return false;
      }
      if (pieces.length == 2 && int.parse(pieces[0]) > int.parse(pieces[1])) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final editing = widget.item != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          editing ? l10n.firewall_editRule : l10n.firewall_add_rule,
          style: AppTextStyles.titleL,
        ),
        const SizedBox(height: AppTokens.s16),
        AppTextField(
          controller: _address,
          label: l10n.firewall_ruleAddress,
          hint: l10n.firewall_ruleAddressHint,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _port,
          label: l10n.firewall_rulePort,
          hint: l10n.firewall_rulePortHint,
          keyboardType: TextInputType.text,
          errorText: _error,
        ),
        const SizedBox(height: AppTokens.s12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _family,
                decoration: InputDecoration(
                  labelText: l10n.firewall_ruleFamily,
                ),
                items: const [
                  DropdownMenuItem(value: 'ipv4', child: Text('IPv4')),
                  DropdownMenuItem(value: 'ipv6', child: Text('IPv6')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _family = value);
                },
              ),
            ),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _protocol,
                decoration: InputDecoration(
                  labelText: l10n.firewall_ruleProtocol,
                ),
                items: const [
                  DropdownMenuItem(value: 'tcp', child: Text('TCP')),
                  DropdownMenuItem(value: 'udp', child: Text('UDP')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _protocol = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s12),
        DropdownButtonFormField<String>(
          initialValue: _action,
          decoration: InputDecoration(labelText: l10n.firewall_ruleStrategy),
          items: [
            DropdownMenuItem(value: 'accept', child: Text(l10n.firewall_allow)),
            DropdownMenuItem(value: 'drop', child: Text(l10n.firewall_deny)),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _action = value);
          },
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: _remark, label: l10n.firewall_ruleRemark),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _interface,
          label: l10n.firewall_ruleInterface,
        ),
        const SizedBox(height: AppTokens.s24),
        PrimaryButton(
          label: l10n.action_save,
          onPressed: () {
            if (!_validPorts(_port.text.trim())) {
              setState(() => _error = l10n.firewall_ruleInvalidPort);
              return;
            }
            Navigator.of(context).pop(
              _RuleDraft(
                family: _family,
                protocol: _protocol,
                action: _action,
                address: _address.text.trim(),
                port: _port.text.trim(),
                remark: _remark.text.trim(),
                interface: _interface.text.trim(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ForwardDraft {
  const _ForwardDraft({
    required this.family,
    required this.protocol,
    required this.port,
    required this.targetIP,
    required this.targetPort,
    required this.interface,
  });

  final String family;
  final String protocol;
  final String port;
  final String targetIP;
  final String targetPort;
  final String interface;

  Map<String, dynamic> toJson({required String operation}) => {
    'operation': operation,
    'family': family,
    'protocol': protocol,
    'port': port,
    'targetIP': targetIP,
    'targetPort': targetPort,
    'interface': interface,
  };
}

class _ForwardSheet extends StatefulWidget {
  const _ForwardSheet({this.rule});

  final FirewallForwardRule? rule;

  @override
  State<_ForwardSheet> createState() => _ForwardSheetState();
}

class _ForwardSheetState extends State<_ForwardSheet> {
  late final TextEditingController _port;
  late final TextEditingController _targetIP;
  late final TextEditingController _targetPort;
  late final TextEditingController _interface;
  late String _family;
  late String _protocol;

  @override
  void initState() {
    super.initState();
    _port = TextEditingController(text: widget.rule?.port ?? '');
    _targetIP = TextEditingController(text: widget.rule?.targetIP ?? '');
    _targetPort = TextEditingController(text: widget.rule?.targetPort ?? '');
    _interface = TextEditingController(text: widget.rule?.interface ?? '');
    _family = widget.rule?.family == 'ipv6' ? 'ipv6' : 'ipv4';
    _protocol = widget.rule?.protocol == 'udp' ? 'udp' : 'tcp';
  }

  @override
  void dispose() {
    _port.dispose();
    _targetIP.dispose();
    _targetPort.dispose();
    _interface.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final editing = widget.rule != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          editing ? l10n.firewall_editForward : l10n.firewall_addForward,
          style: AppTextStyles.titleL,
        ),
        const SizedBox(height: AppTokens.s16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _family,
                decoration: InputDecoration(
                  labelText: l10n.firewall_ruleFamily,
                ),
                items: const [
                  DropdownMenuItem(value: 'ipv4', child: Text('IPv4')),
                  DropdownMenuItem(value: 'ipv6', child: Text('IPv6')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _family = value);
                },
              ),
            ),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _protocol,
                decoration: InputDecoration(
                  labelText: l10n.firewall_ruleProtocol,
                ),
                items: const [
                  DropdownMenuItem(value: 'tcp', child: Text('TCP')),
                  DropdownMenuItem(value: 'udp', child: Text('UDP')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _protocol = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _port,
          label: l10n.firewall_forwardPort,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _targetIP,
          label: l10n.firewall_forwardTargetIp,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _targetPort,
          label: l10n.firewall_forwardTargetPort,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _interface,
          label: l10n.firewall_forwardInterface,
        ),
        const SizedBox(height: AppTokens.s24),
        PrimaryButton(
          label: l10n.action_save,
          onPressed: () {
            final port = _port.text.trim();
            final targetIP = _targetIP.text.trim();
            final targetPort = _targetPort.text.trim();
            if (port.isEmpty || targetIP.isEmpty || targetPort.isEmpty) {
              AppToast.warning(context, l10n.firewall_forwardRequired);
              return;
            }
            Navigator.of(context).pop(
              _ForwardDraft(
                family: _family,
                protocol: _protocol,
                port: port,
                targetIP: targetIP,
                targetPort: targetPort,
                interface: _interface.text.trim(),
              ),
            );
          },
        ),
      ],
    );
  }
}
