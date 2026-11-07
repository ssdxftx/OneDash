import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/ai/ai_account_dto.dart';
import '../../../../data/dto/ai/ai_agent_dto.dart';
import '../../../../data/dto/ai/ai_agent_role_dto.dart';
import '../../../../data/dto/ai/ai_provider_dto.dart';
import '../../../../data/dto/ai/mcp_server_dto.dart';
import '../../../../data/dto/ai/ollama_model_dto.dart';
import '../../../../data/repositories_impl/ai_repository_impl.dart';
import '../../../../data/dto/website/website_search_req.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../log/screens/log_preview_page.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../providers/ai_provider.dart';

part 'ai_models_actions.dart';
part 'ai_mcp_actions.dart';
part 'ai_accounts_actions.dart';
part 'ai_agents_actions.dart';

class AiPage extends ConsumerStatefulWidget {
  const AiPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<AiPage> createState() => _AiPageState();
}

class _AiPageState extends ConsumerState<AiPage>
    with _AiModelsActions, _AiMcpActions, _AiAccountsActions, _AiAgentsActions {
  int _tab = 0;

  Future<void> _refresh() async {
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final servers = await repository.searchMcpServers();
      if (servers.items.isNotEmpty) {
        await repository.syncMcpStatus(
          servers.items.map((server) => server.id).toList(growable: false),
        );
      }
    } catch (_) {
      // Keep the refresh usable when the MCP module is unavailable.
    }
    ref.invalidate(ollamaModelsProvider);
    ref.invalidate(gpuInfoProvider);
    ref.invalidate(mcpServersProvider);
    ref.invalidate(aiAccountsProvider);
    ref.invalidate(aiAgentsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.ai_title,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _refresh,
          ),
          if (_tab == 0 || _tab == 2 || _tab == 3 || _tab == 4)
            AppIconButton(
              icon: TablerIcons.plus,
              tooltip: _tab == 0
                  ? l10n.ai_model_add
                  : _tab == 2
                  ? l10n.ai_mcp_add
                  : _tab == 3
                  ? l10n.ai_account_add
                  : l10n.ai_agent_add,
              onPressed: _tab == 0
                  ? _addModel
                  : _tab == 2
                  ? _editMcp
                  : _tab == 3
                  ? _editAccount
                  : _addAgent,
            ),
        ],
      ),
      body: SegmentedTabsView(
        onChanged: (value) => setState(() => _tab = value),
        labels: [
          l10n.ai_models,
          l10n.ai_gpu,
          l10n.ai_mcp,
          l10n.ai_accounts,
          l10n.ai_agents,
        ],
        children: [
          _ModelsTab(onTap: _showModelActions),
          const _GpuTab(),
          _McpTab(onTap: _showMcpActions),
          _AccountsTab(onTap: _showAccountActions),
          _AgentsTab(onTap: _showAgentActions),
        ],
      ),
    );
  }
}

class _ModelsTab extends ConsumerWidget {
  const _ModelsTab({required this.onTap});

  final ValueChanged<OllamaModelDto> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final models = ref.watch(ollamaModelsProvider);
    return AsyncStateView(
      value: models,
      onRetry: () => ref.invalidate(ollamaModelsProvider),
      loading: const SkeletonList(itemCount: 5),
      isEmpty: (data) => data.items.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.brain,
        title: l10n.ai_models_empty,
        message: l10n.ai_models_empty_hint,
      ),
      builder: (data) => ListView.separated(
        padding: EdgeInsets.all(context.pagePadding),
        itemCount: data.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
        itemBuilder: (context, index) {
          final model = data.items[index];
          return TonalCard(
            onTap: () => onTap(model),
            child: Row(
              children: [
                StatusDot(status: model.status.toLowerCase()),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.name, style: AppTextStyles.titleM),
                      Text(
                        [
                          if (model.size.isNotEmpty) model.size,
                          if (model.from.isNotEmpty) model.from,
                          if (model.status.isNotEmpty) model.status,
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
          );
        },
      ),
    );
  }
}

class _GpuTab extends ConsumerWidget {
  const _GpuTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final info = ref.watch(gpuInfoProvider);
    return AsyncStateView(
      value: info,
      onRetry: () => ref.invalidate(gpuInfoProvider),
      loading: const SkeletonList(itemCount: 3),
      isEmpty: (data) => data.devices.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.cpu,
        title: l10n.ai_gpu_empty,
        message: l10n.ai_gpu_empty_hint,
      ),
      builder: (data) => ListView(
        padding: EdgeInsets.all(context.pagePadding),
        children: [
          TonalCard(
            child: Wrap(
              spacing: AppTokens.s24,
              runSpacing: AppTokens.s8,
              children: [
                if (data.type.isNotEmpty)
                  Text('${l10n.websites_type}: ${data.type}'),
                if (data.cudaVersion.isNotEmpty)
                  Text('${l10n.ai_gpu_cuda}: ${data.cudaVersion}'),
                if (data.driverVersion.isNotEmpty)
                  Text('${l10n.ai_gpu_driver}: ${data.driverVersion}'),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          for (final device in data.devices) ...[
            _GpuCard(device: device),
            const SizedBox(height: AppTokens.s12),
          ],
        ],
      ),
    );
  }
}

class _GpuCard extends StatelessWidget {
  const _GpuCard({required this.device});

  final Map<String, dynamic> device;

  String _value(String key) => '${device[key] ?? ''}'.trim();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final names = [
      _value('productName'),
      _value('deviceName'),
      _value('deviceID'),
    ].where((item) => item.isNotEmpty).toList(growable: false);
    final name = names.isEmpty ? null : names.first;
    final memory = [
      _value('memUsed'),
      _value('memTotal'),
      _value('memory'),
      _value('memoryUsed'),
    ].where((item) => item.isNotEmpty).join(' / ');
    final util = [
      _value('gpuUtil'),
      _value('memoryUtil'),
    ].where((item) => item.isNotEmpty).join(' / ');
    final temp = _value('temperature');
    final processes = device['processes'];
    return TonalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name ?? l10n.ai_gpu,
            style: AppTextStyles.titleM,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTokens.s8),
          Wrap(
            spacing: AppTokens.s16,
            runSpacing: AppTokens.s4,
            children: [
              if (memory.isNotEmpty) Text('${l10n.ai_gpu_memory}: $memory'),
              if (util.isNotEmpty) Text('${l10n.ai_gpu_utilization}: $util'),
              if (temp.isNotEmpty) Text('${l10n.ai_gpu_temperature}: $temp'),
            ],
          ),
          if (processes is List && processes.isNotEmpty) ...[
            const SizedBox(height: AppTokens.s8),
            Text(
              l10n.ai_gpu_processes,
              style: AppTextStyles.caption.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            for (final item in processes.whereType<Map>())
              Text(
                [
                  '${item['pid'] ?? ''}',
                  '${item['processName'] ?? item['command'] ?? ''}',
                  '${item['usedMemory'] ?? item['memory'] ?? ''}',
                ].where((value) => value.trim().isNotEmpty).join(' · '),
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ],
      ),
    );
  }
}

class _McpTab extends ConsumerWidget {
  const _McpTab({required this.onTap});

  final ValueChanged<McpServerDto> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final servers = ref.watch(mcpServersProvider);
    return AsyncStateView(
      value: servers,
      onRetry: () => ref.invalidate(mcpServersProvider),
      loading: const SkeletonList(itemCount: 4),
      isEmpty: (data) => data.items.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.plug,
        title: l10n.ai_mcp_empty,
        message: l10n.ai_mcp_empty_hint,
      ),
      builder: (data) => ListView.separated(
        padding: EdgeInsets.all(context.pagePadding),
        itemCount: data.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
        itemBuilder: (context, index) {
          final server = data.items[index];
          final running = server.status.toLowerCase() == 'running';
          return TonalCard(
            onTap: () => onTap(server),
            child: Row(
              children: [
                StatusDot(status: server.status.toLowerCase()),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(server.name, style: AppTextStyles.titleM),
                      Text(
                        [
                          running ? l10n.ai_mcp_running : l10n.ai_mcp_stopped,
                          if (server.baseUrl.isNotEmpty)
                            server.baseUrl
                          else if (server.hostIP.isNotEmpty)
                            '${server.hostIP}:${server.port}'
                          else if (server.port > 0)
                            '${l10n.ai_mcp_port} ${server.port}',
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
          );
        },
      ),
    );
  }
}

class _AccountsTab extends ConsumerWidget {
  const _AccountsTab({required this.onTap});

  final ValueChanged<AiAccountDto> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(aiAccountsProvider);
    return AsyncStateView(
      value: accounts,
      onRetry: () => ref.invalidate(aiAccountsProvider),
      loading: const SkeletonList(itemCount: 4),
      isEmpty: (data) => data.items.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.key,
        title: l10n.ai_accounts_empty,
        message: l10n.ai_accounts_empty_hint,
      ),
      builder: (data) => ListView.separated(
        padding: EdgeInsets.all(context.pagePadding),
        itemCount: data.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
        itemBuilder: (context, index) {
          final account = data.items[index];
          return TonalCard(
            onTap: () => onTap(account),
            child: Row(
              children: [
                Icon(
                  account.verified
                      ? TablerIcons.shield_check
                      : TablerIcons.shield,
                  color: account.verified
                      ? context.appColors.success
                      : context.scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.name, style: AppTextStyles.titleM),
                      Text(
                        [
                          if (account.providerName.isNotEmpty)
                            account.providerName,
                          if (account.apiType.isNotEmpty) account.apiType,
                          if (account.models.isNotEmpty)
                            '${account.models.length} models',
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
                Text(
                  account.verified
                      ? l10n.ai_account_verified
                      : l10n.ai_account_unverified,
                  style: AppTextStyles.caption.copyWith(
                    color: account.verified
                        ? context.appColors.success
                        : context.scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AgentsTab extends ConsumerWidget {
  const _AgentsTab({required this.onTap});

  final ValueChanged<AiAgentDto> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final agents = ref.watch(aiAgentsProvider);
    return AsyncStateView(
      value: agents,
      onRetry: () => ref.invalidate(aiAgentsProvider),
      loading: const SkeletonList(itemCount: 4),
      isEmpty: (data) => data.items.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.robot,
        title: l10n.ai_agents_empty,
        message: l10n.ai_agents_empty_hint,
      ),
      builder: (data) => ListView.separated(
        padding: EdgeInsets.all(context.pagePadding),
        itemCount: data.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
        itemBuilder: (context, index) {
          final agent = data.items[index];
          return TonalCard(
            onTap: () => onTap(agent),
            child: Row(
              children: [
                StatusDot(status: agent.status.toLowerCase()),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(agent.name, style: AppTextStyles.titleM),
                      Text(
                        [
                          if (agent.providerName.isNotEmpty) agent.providerName,
                          if (agent.model.isNotEmpty) agent.model,
                          if (agent.websitePrimaryDomain.isNotEmpty)
                            agent.websitePrimaryDomain,
                          if (agent.webUIPort > 0) ':${agent.webUIPort}',
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
                if (agent.upgradable)
                  Icon(
                    TablerIcons.arrow_up_circle,
                    color: context.appColors.warning,
                    size: AppTokens.iconList,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
