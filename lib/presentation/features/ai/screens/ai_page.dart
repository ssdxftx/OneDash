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
import '../../../../domain/repositories/ai_repository.dart';
import 'ai_chat_page.dart';
import '../widgets/ai_channel_config_page.dart';
import '../../../../data/dto/app/app_installed_search_req.dart';
import '../../../../data/dto/website/website_search_req.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../log/screens/log_preview_page.dart';
import '../../../common/charts/area_chart.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/status_pill.dart';
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
    ref.invalidate(gpuGroupsProvider);
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
          _AgentsTab(onTap: _showAgentActions, onBatch: _showAgentBatchMenu),
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
          if (ref.watch(modelGpuDevicesProvider).valueOrNull?['devices']
              is List) ...[
            TonalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.ai_gpu_benchmark, style: AppTextStyles.titleM),
                  const SizedBox(height: AppTokens.s4),
                  Text(
                    ((ref.watch(modelGpuDevicesProvider).valueOrNull?['devices']
                                as List?) ??
                            const [])
                        .whereType<Map>()
                        .map((item) => '${item['name'] ?? item['id'] ?? ''}')
                        .where((value) => value.isNotEmpty)
                        .join(' · '),
                    style: AppTextStyles.caption.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s16),
          ],
          SecondaryButton(
            label: l10n.ai_gpu_benchmark,
            icon: TablerIcons.chart_bar,
            onPressed: () => _showBenchmark(context, ref),
          ),
          const SizedBox(height: AppTokens.s8),
          SecondaryButton(
            label: l10n.ai_gpuUsage,
            icon: TablerIcons.activity,
            onPressed: () => _showGpuUsage(context, ref),
          ),
          const SizedBox(height: AppTokens.s24),
          SectionHeader(
            title: l10n.ai_gpuGroups,
            trailing: AppIconButton(
              icon: TablerIcons.plus,
              tooltip: l10n.ai_gpuGroupAdd,
              onPressed: () => _editGpuGroup(context, ref),
            ),
          ),
          Consumer(
            builder: (context, ref, _) {
              final groups = ref.watch(gpuGroupsProvider);
              return AsyncStateView(
                value: groups,
                onRetry: () => ref.invalidate(gpuGroupsProvider),
                loading: const SkeletonList(itemCount: 2, itemHeight: 72),
                isEmpty: (items) => items.isEmpty,
                empty: EmptyState(
                  icon: TablerIcons.stack_2,
                  title: l10n.ai_gpuGroupsEmpty,
                  compact: true,
                ),
                builder: (items) => Column(
                  children: [
                    for (final group in items) ...[
                      TonalCard(
                        onTap: () => _showGpuGroupActions(context, ref, group),
                        child: Row(
                          children: [
                            const Icon(TablerIcons.stack_2),
                            const SizedBox(width: AppTokens.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${group['name'] ?? ''}',
                                    style: AppTextStyles.titleS,
                                  ),
                                  Text(
                                    _gpuGroupSummary(group),
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
                ),
              );
            },
          ),
          const SizedBox(height: AppTokens.s16),
          for (final device in data.devices) ...[
            _GpuCard(
              device: device,
              onMonitor: () => _showGpuMonitor(context, ref, device),
            ),
            const SizedBox(height: AppTokens.s12),
          ],
        ],
      ),
    );
  }

  Future<void> _showBenchmark(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final sources = await repository.getBenchmarkSources();
      if (!context.mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ai_gpu_benchmark, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            if (sources.isEmpty)
              EmptyState(
                icon: TablerIcons.chart_bar,
                title: l10n.ai_gpu_benchmarkEmpty,
                compact: true,
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final source in sources)
                      SplitListTile(
                        leading: const Icon(TablerIcons.chart_bar),
                        title: '${source['name'] ?? source['id'] ?? ''}',
                        subtitle: [
                          '${source['kind'] ?? ''}',
                          '${source['status'] ?? ''}',
                          '${source['baseUrl'] ?? source['endpoint'] ?? ''}',
                          if (source['models'] is List)
                            (source['models'] as List).join(', '),
                        ].where((value) => value.isNotEmpty).join(' · '),
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showGpuMonitor(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> device,
  ) async {
    await showAppSheet<void>(
      context: context,
      builder: (_) => _GpuMonitorSheet(device: device),
    );
  }

  String _gpuGroupSummary(Map<String, dynamic> group) {
    final gpu = group['gpu'] is Map
        ? Map<String, dynamic>.from(group['gpu'] as Map)
        : const <String, dynamic>{};
    final devices = (gpu['deviceIDs'] as List?) ?? const [];
    return [
      '${group['imageType'] ?? ''}',
      '${devices.length} GPU',
      if ('${group['description'] ?? ''}'.isNotEmpty) '${group['description']}',
    ].where((value) => value.isNotEmpty).join(' · ');
  }

  Future<void> _showGpuGroupActions(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> group,
  ) async {
    final l10n = AppLocalizations.of(context);
    final action = await showSelectionMenu<String>(
      context,
      title: '${group['name'] ?? ''}',
      options: [
        SelectionOption(
          label: l10n.action_edit,
          value: 'edit',
          icon: TablerIcons.edit,
        ),
        SelectionOption(
          label: l10n.action_delete,
          value: 'delete',
          icon: TablerIcons.trash,
          danger: true,
        ),
      ],
    );
    if (action == null || !context.mounted) return;
    if (action == 'edit') {
      await _editGpuGroup(context, ref, group: group);
      return;
    }
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: l10n.ai_gpuGroupDeleteConfirm('${group['name'] ?? ''}'),
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      await repository.deleteGpuGroup((group['id'] as num?)?.toInt() ?? 0);
      ref.invalidate(gpuGroupsProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editGpuGroup(
    BuildContext context,
    WidgetRef ref, {
    Map<String, dynamic>? group,
  }) async {
    final repository = await ref.read(aiRepositoryProvider.future);
    final devices = await repository.getModelGpuDevices();
    if (!context.mounted) return;
    final body = await pushFormPage<Map<String, dynamic>>(
      context,
      _GpuGroupFormPage(devices: devices, initial: group),
    );
    if (body == null || !context.mounted) return;
    try {
      await repository.saveGpuGroup(body);
      ref.invalidate(gpuGroupsProvider);
      if (!context.mounted) return;
      AppToast.success(context, AppLocalizations.of(context).action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showGpuUsage(BuildContext context, WidgetRef ref) async {
    final body = await pushFormPage<Map<String, dynamic>>(
      context,
      const _GpuUsageFormPage(),
    );
    if (body == null || !context.mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final result = await repository.loadModelGpuUsage(body);
      if (!context.mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => _GpuUsageResultSheet(result: result),
      );
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _GpuMonitorSheet extends ConsumerStatefulWidget {
  const _GpuMonitorSheet({required this.device});

  final Map<String, dynamic> device;

  @override
  ConsumerState<_GpuMonitorSheet> createState() => _GpuMonitorSheetState();
}

class _GpuMonitorSheetState extends ConsumerState<_GpuMonitorSheet> {
  int _hours = 1;
  late Future<Map<String, dynamic>> _future = _load();

  Future<Map<String, dynamic>> _load() async {
    final repository = await ref.read(aiRepositoryProvider.future);
    final end = DateTime.now();
    return repository.searchGpuMonitor(
      startTime: end.subtract(Duration(hours: _hours)),
      endTime: end,
      deviceID: '${widget.device['deviceID'] ?? ''}',
      productName:
          '${widget.device['productName'] ?? widget.device['deviceName'] ?? ''}',
      legacy: widget.device['legacy'] == true,
    );
  }

  List<double> _series(Map<String, dynamic> data, String key) {
    final raw = data[key];
    if (raw is! List) return const [];
    return raw
        .map((value) => value is num ? value.toDouble() : 0.0)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name =
        '${widget.device['productName'] ?? widget.device['deviceName'] ?? widget.device['deviceID'] ?? ''}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ai_gpu_monitor, style: AppTextStyles.titleL),
        if (name.isNotEmpty) Text(name, style: AppTextStyles.bodyS),
        const SizedBox(height: AppTokens.s12),
        AppFilterChips<int>(
          options: const [1, 6, 24],
          labelOf: (value) => switch (value) {
            1 => l10n.host_range1h,
            6 => l10n.host_range6h,
            _ => l10n.host_range24h,
          },
          selected: {_hours},
          onChanged: (selection) {
            if (selection.isEmpty) return;
            setState(() {
              _hours = selection.first;
              _future = _load();
            });
          },
        ),
        const SizedBox(height: AppTokens.s12),
        FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SkeletonList(itemCount: 2, itemHeight: 120);
            }
            if (snapshot.hasError) {
              return EmptyState(
                icon: TablerIcons.alert_circle,
                title: l10n.common_notAvailable,
                compact: true,
              );
            }
            final data = snapshot.data ?? const <String, dynamic>{};
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: l10n.ai_gpu_utilizationChart),
                AreaChart(seriesA: _series(data, 'gpuValue'), maxY: 100),
                const SizedBox(height: AppTokens.s16),
                SectionHeader(title: l10n.ai_gpu_memoryChart),
                AreaChart(
                  seriesA: _series(data, 'memoryActivity'),
                  colorA: context.appColors.warning,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _GpuGroupFormPage extends StatefulWidget {
  const _GpuGroupFormPage({required this.devices, this.initial});

  final Map<String, dynamic> devices;
  final Map<String, dynamic>? initial;

  @override
  State<_GpuGroupFormPage> createState() => _GpuGroupFormPageState();
}

class _GpuGroupFormPageState extends State<_GpuGroupFormPage> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _capabilities;
  late String _imageType;
  late Set<String> _deviceIds;

  Map<String, dynamic> get _gpu {
    final value = widget.initial?['gpu'];
    return value is Map ? Map<String, dynamic>.from(value) : const {};
  }

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: '${widget.initial?['name'] ?? ''}');
    _description = TextEditingController(
      text: '${widget.initial?['description'] ?? ''}',
    );
    _imageType = switch ('${widget.initial?['imageType'] ?? 'nvidia'}') {
      'intel' => 'intel',
      'ascend' => 'ascend',
      _ => 'nvidia',
    };
    _deviceIds = {
      for (final item in (_gpu['deviceIDs'] as List?) ?? const []) '$item',
    };
    final capabilities = (_gpu['capabilities'] as List?) ?? const ['gpu'];
    _capabilities = TextEditingController(
      text: capabilities.isEmpty ? 'gpu' : capabilities.join(','),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _capabilities.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _availableDevices {
    final raw = widget.devices['devices'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(Map<String, dynamic>.from)
        .where(
          (item) =>
              '${item['type'] ?? ''}' == _imageType &&
              item['available'] == true,
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SimpleFormPage(
      title: widget.initial == null
          ? l10n.ai_gpuGroupAdd
          : l10n.ai_gpuGroupEdit,
      onSave: _save,
      children: [
        AppTextField(controller: _name, label: l10n.ai_gpuGroupName),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _description,
          label: l10n.ai_gpuGroupDescription,
          maxLines: 3,
        ),
        const SizedBox(height: AppTokens.s12),
        DropdownButtonFormField<String>(
          initialValue: _imageType,
          decoration: InputDecoration(labelText: l10n.ai_gpuGroupImageType),
          items: [
            DropdownMenuItem(
              value: 'nvidia',
              child: Text(l10n.ai_gpuTypeNvidia),
            ),
            DropdownMenuItem(value: 'intel', child: Text(l10n.ai_gpuTypeIntel)),
            DropdownMenuItem(
              value: 'ascend',
              child: Text(l10n.ai_gpuTypeAscend),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _imageType = value;
              _deviceIds = {};
            });
          },
        ),
        const SizedBox(height: AppTokens.s12),
        SectionHeader(title: l10n.ai_gpuGroupDevices),
        if (_availableDevices.isEmpty)
          Text(
            l10n.ai_gpu_empty,
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          )
        else
          for (final device in _availableDevices)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _deviceIds.contains('${device['id']}'),
              title: Text('${device['name'] ?? device['id'] ?? ''}'),
              subtitle: Text(
                '${device['id'] ?? ''} · ${device['memoryTotal'] ?? ''}',
              ),
              onChanged: (value) {
                final id = '${device['id']}';
                setState(() {
                  if (value == true) {
                    _deviceIds.add(id);
                  } else {
                    _deviceIds.remove(id);
                  }
                });
              },
            ),
        if (_imageType == 'nvidia') ...[
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: _capabilities,
            label: l10n.ai_gpuGroupCapabilities,
            hint: 'gpu,utility,compute',
          ),
        ],
      ],
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty || _deviceIds.isEmpty) {
      AppToast.error(context, l10n.ai_gpuGroupDevices);
      return;
    }
    final capabilities = _capabilities.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (_imageType == 'nvidia' && !capabilities.contains('gpu')) {
      capabilities.insert(0, 'gpu');
    }
    Navigator.of(context).pop({
      if (widget.initial != null && widget.initial!['id'] != null)
        'id': widget.initial!['id'],
      'name': _name.text.trim(),
      'description': _description.text.trim(),
      'imageType': _imageType,
      'gpu': {
        'mode': 'devices',
        'enabled': true,
        'deviceIDs': _deviceIds.toList(growable: false),
        'capabilities': _imageType == 'nvidia' ? capabilities : <String>[],
      },
    });
  }
}

class _GpuUsageFormPage extends StatefulWidget {
  const _GpuUsageFormPage();

  @override
  State<_GpuUsageFormPage> createState() => _GpuUsageFormPageState();
}

class _GpuUsageFormPageState extends State<_GpuUsageFormPage> {
  final _compose = TextEditingController();
  final _env = TextEditingController();
  String _imageType = 'nvidia';

  @override
  void dispose() {
    _compose.dispose();
    _env.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SimpleFormPage(
      title: l10n.ai_gpuUsage,
      onSave: _save,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _imageType,
          decoration: InputDecoration(labelText: l10n.ai_gpuGroupImageType),
          items: [
            DropdownMenuItem(
              value: 'nvidia',
              child: Text(l10n.ai_gpuTypeNvidia),
            ),
            DropdownMenuItem(value: 'intel', child: Text(l10n.ai_gpuTypeIntel)),
            DropdownMenuItem(
              value: 'ascend',
              child: Text(l10n.ai_gpuTypeAscend),
            ),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _imageType = value);
          },
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _compose,
          label: l10n.ai_gpuUsageCompose,
          maxLines: 10,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: _env, label: l10n.ai_gpuUsageEnv, maxLines: 4),
      ],
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_compose.text.trim().isEmpty) {
      AppToast.error(context, l10n.ai_gpuUsageCompose);
      return;
    }
    Navigator.of(context).pop({
      'dockerCompose': _compose.text,
      'env': _env.text,
      'imageType': _imageType,
    });
  }
}

class _GpuUsageResultSheet extends StatelessWidget {
  const _GpuUsageResultSheet({required this.result});

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final warnings = (result['warnings'] as List?) ?? const [];
    final devices = (result['devices'] as List?) ?? const [];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ai_gpuUsageResult, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s12),
        if (warnings.isNotEmpty) ...[
          Text(l10n.ai_gpuUsageWarnings, style: AppTextStyles.titleS),
          for (final warning in warnings)
            Text('• $warning', style: AppTextStyles.bodyS),
          const SizedBox(height: AppTokens.s12),
        ],
        if (devices.isEmpty)
          EmptyState(
            icon: TablerIcons.cpu,
            title: l10n.ai_gpu_empty,
            compact: true,
          )
        else
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final item in devices.whereType<Map>())
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      item['possible'] == true
                          ? TablerIcons.check
                          : TablerIcons.x,
                    ),
                    title: Text('${item['name'] ?? item['id'] ?? ''}'),
                    subtitle: Text(
                      ((item['deployments'] as List?) ?? const [])
                          .whereType<Map>()
                          .map((deployment) => '${deployment['name'] ?? ''}')
                          .where((value) => value.isNotEmpty)
                          .join(' · '),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _GpuCard extends StatelessWidget {
  const _GpuCard({required this.device, required this.onMonitor});

  final Map<String, dynamic> device;
  final VoidCallback onMonitor;

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
          const SizedBox(height: AppTokens.s8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onMonitor,
              child: Text(l10n.ai_gpu_monitor),
            ),
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
    final counts = ref.watch(aiAccountCountsProvider).valueOrNull ?? const {};
    final providers =
        ref.watch(aiProvidersProvider).valueOrNull ?? const <AiProviderDto>[];
    final names = {
      for (final provider in providers) provider.provider: provider.displayName,
    };
    final countItems = counts.entries
        .where((entry) => entry.value > 0)
        .toList(growable: false);
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
      builder: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (countItems.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.pagePadding,
                AppTokens.s12,
                context.pagePadding,
                0,
              ),
              child: Wrap(
                spacing: AppTokens.s8,
                runSpacing: AppTokens.s8,
                children: [
                  for (final entry in countItems)
                    StatusPill(
                      label: l10n.ai_accountCountLabel(
                        names[entry.key]?.isNotEmpty == true
                            ? names[entry.key]!
                            : entry.key,
                        entry.value,
                      ),
                      tone: context.scheme.primary,
                    ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
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
          ),
        ],
      ),
    );
  }
}

class _AgentsTab extends ConsumerWidget {
  const _AgentsTab({required this.onTap, required this.onBatch});

  final ValueChanged<AiAgentDto> onTap;
  final VoidCallback onBatch;

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
      builder: (data) => Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.pagePadding,
              AppTokens.s12,
              context.pagePadding,
              0,
            ),
            child: SizedBox(
              width: double.infinity,
              child: SecondaryButton(
                label: l10n.ai_agent_batch,
                icon: TablerIcons.stack_2,
                onPressed: onBatch,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
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
                                if (agent.providerName.isNotEmpty)
                                  agent.providerName,
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
          ),
        ],
      ),
    );
  }
}
