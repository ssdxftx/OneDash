import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/common/page_result.dart';
import '../../../../data/dto/firewall/firewall_base_info_dto.dart';
import '../../../../data/dto/firewall/rule_info_dto.dart';
import '../../../../data/repositories_impl/firewall_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';

class _FirewallState {
  const _FirewallState({
    required this.base,
    required this.portRules,
    required this.ipRules,
  });

  final FirewallBaseInfoDto base;
  final PageResult<RuleInfoDto> portRules;
  final PageResult<RuleInfoDto> ipRules;
}

final _firewallProvider = FutureProvider.autoDispose<_FirewallState>((
  ref,
) async {
  final repository = await ref.watch(firewallRepositoryProvider.future);
  final base = await repository.getBaseInfo();
  PageResult<RuleInfoDto> portRules = const PageResult(total: 0, items: []);
  PageResult<RuleInfoDto> ipRules = const PageResult(total: 0, items: []);
  try {
    portRules = await repository.searchRules(type: 'port', pageSize: 100);
  } catch (_) {
    // 端口规则可能由统一防火墙接管，保留空列表。
  }
  try {
    ipRules = await repository.searchRules(type: 'ip', pageSize: 100);
  } catch (_) {
    // IP 规则可能由统一防火墙接管，保留空列表。
  }
  return _FirewallState(base: base, portRules: portRules, ipRules: ipRules);
}, name: 'firewallProvider');

class FirewallPage extends ConsumerStatefulWidget {
  const FirewallPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<FirewallPage> createState() => _FirewallPageState();
}

class _FirewallPageState extends ConsumerState<FirewallPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final firewall = ref.watch(_firewallProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.firewall_title,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_firewallProvider),
          ),
        ],
      ),
      body: AsyncStateView(
        value: firewall,
        onRetry: () => ref.invalidate(_firewallProvider),
        loading: const SkeletonList(itemCount: 6),
        builder: (state) => ListView(
          padding: const EdgeInsets.all(AppTokens.s16),
          children: [
            TonalCard(
              child: Row(
                children: [
                  Icon(
                    state.base.isActive
                        ? TablerIcons.shield_check
                        : TablerIcons.shield_off,
                    color: state.base.isActive
                        ? context.appColors.success
                        : context.appColors.danger,
                  ),
                  const SizedBox(width: AppTokens.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.firewall_status, style: AppTextStyles.titleM),
                        Text(
                          state.base.isActive
                              ? l10n.common_running
                              : l10n.common_stopped,
                          style: AppTextStyles.bodyS.copyWith(
                            color: context.scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: state.base.isActive,
                    onChanged: (value) async {
                      try {
                        final repository = await ref.read(
                          firewallRepositoryProvider.future,
                        );
                        await repository.operate(value ? 'start' : 'stop');
                        if (!context.mounted) return;
                        AppToast.success(context, l10n.action_done);
                        ref.invalidate(_firewallProvider);
                      } catch (error) {
                        if (!context.mounted) return;
                        AppToast.error(context, '$error');
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s24),
            SegmentedTabs(
              labels: [l10n.firewall_ports, l10n.firewall_ips],
              selectedIndex: _tab,
              scrollable: false,
              onChanged: (value) => setState(() => _tab = value),
            ),
            const SizedBox(height: AppTokens.s16),
            SectionHeader(
              title: _tab == 0 ? l10n.firewall_ports : l10n.firewall_ips,
            ),
            _RuleList(
              rules: _tab == 0 ? state.portRules.items : state.ipRules.items,
              onAdd: () => _showAddRule(context, _tab == 0 ? 'port' : 'ip'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddRule(BuildContext context, String type) async {
    final l10n = AppLocalizations.of(context);
    final firstController = TextEditingController();
    final descController = TextEditingController();
    String protocol = 'tcp';
    String strategy = 'accept';
    final isPort = type == 'port';
    final created = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPort ? l10n.firewall_add_rule : l10n.firewall_addIpRule,
              style: AppTextStyles.titleL,
            ),
            const SizedBox(height: AppTokens.s16),
            AppTextField(
              controller: firstController,
              label: isPort ? l10n.firewall_port : l10n.firewall_ipAddress,
              hint: isPort
                  ? l10n.firewall_portPlaceholder
                  : l10n.firewall_ipAddressPlaceholder,
              keyboardType: isPort ? TextInputType.number : TextInputType.text,
            ),
            const SizedBox(height: AppTokens.s12),
            Row(
              children: [
                if (isPort)
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: protocol,
                      decoration: InputDecoration(
                        labelText: l10n.firewall_protocolLabel,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'tcp', child: Text('TCP')),
                        DropdownMenuItem(value: 'udp', child: Text('UDP')),
                      ],
                      onChanged: (value) => setState(() => protocol = value!),
                    ),
                  ),
                if (isPort) const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: strategy,
                    decoration: InputDecoration(
                      labelText: l10n.firewall_strategy,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'accept',
                        child: Text(l10n.firewall_allow),
                      ),
                      DropdownMenuItem(
                        value: 'drop',
                        child: Text(l10n.firewall_deny),
                      ),
                    ],
                    onChanged: (value) => setState(() => strategy = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: descController,
              label: l10n.firewall_descriptionLabel,
            ),
            const SizedBox(height: AppTokens.s24),
            PrimaryButton(
              label: l10n.action_save,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    );
    if (created != true) return;
    try {
      final repository = await ref.read(firewallRepositoryProvider.future);
      if (isPort) {
        await repository.operatePortRule({
          'operation': 'add',
          'port': firstController.text.trim(),
          'protocol': protocol,
          'strategy': strategy,
          'description': descController.text.trim(),
          'address': '',
        });
      } else {
        await repository.operateIpRule({
          'operation': 'add',
          'address': firstController.text.trim(),
          'strategy': strategy,
          'description': descController.text.trim(),
        });
      }
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_firewallProvider);
    } catch (error) {
      if (!context.mounted) return;
      AppToast.error(context, '$error');
    } finally {
      firstController.dispose();
      descController.dispose();
    }
  }
}

class _RuleList extends StatelessWidget {
  const _RuleList({required this.rules, required this.onAdd});

  final List<RuleInfoDto> rules;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (rules.isEmpty) {
      return EmptyState(
        icon: TablerIcons.shield,
        title: l10n.firewall_ports,
        message: l10n.firewall_add_rule,
        actionLabel: l10n.firewall_add_rule,
        onAction: onAdd,
      );
    }
    return Column(
      children: [
        SplitListGroup(
          children: [
            for (final rule in rules)
              SplitListTile(
                leading: Icon(
                  rule.strategy == 'accept' ? TablerIcons.check : TablerIcons.x,
                ),
                title: rule.address != null && rule.address!.isNotEmpty
                    ? '${rule.address} · ${rule.port ?? '-'} / ${rule.protocol ?? '-'}'
                    : '${rule.port ?? '-'} / ${rule.protocol ?? '-'}',
                subtitle: rule.description ?? rule.address,
                trailing: Text(
                  rule.strategy == 'accept'
                      ? l10n.firewall_allow
                      : l10n.firewall_deny,
                  style: AppTextStyles.caption.copyWith(
                    color: rule.strategy == 'accept'
                        ? context.appColors.success
                        : context.appColors.danger,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTokens.s16),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(TablerIcons.plus),
          label: Text(l10n.firewall_add_rule),
        ),
      ],
    );
  }
}
