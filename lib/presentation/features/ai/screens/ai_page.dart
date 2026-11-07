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

class AiPage extends ConsumerStatefulWidget {
  const AiPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<AiPage> createState() => _AiPageState();
}

class _AiPageState extends ConsumerState<AiPage> {
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

  Future<void> _addModel() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.ai_model_add,
          saveLabel: l10n.action_create,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(
              controller: controller,
              label: l10n.ai_model_name,
              hint: 'llama3',
            ),
          ],
        ),
      ),
    );
    final name = controller.text.trim();
    controller.dispose();
    if (saved != true || !mounted || name.isEmpty) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      await repository.createOllamaModel(name);
      if (!mounted) return;
      ref.invalidate(ollamaModelsProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  List<Map<String, dynamic>> _parseEnv(String raw) {
    return [
      for (final line in raw.split('\n'))
        if (line.trim().isNotEmpty && line.contains('='))
          {
            'key': line.substring(0, line.indexOf('=')).trim(),
            'value': line.substring(line.indexOf('=') + 1).trim(),
          },
    ];
  }

  List<Map<String, dynamic>> _parseVolumes(String raw) {
    return [
      for (final line in raw.split('\n'))
        if (line.trim().isNotEmpty && line.contains(':'))
          {
            'source': line.substring(0, line.indexOf(':')).trim(),
            'target': line.substring(line.indexOf(':') + 1).trim(),
          },
    ];
  }

  Future<void> _editMcp([McpServerDto? server]) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController(text: server?.name ?? '');
    final command = TextEditingController(text: server?.command ?? '');
    final container = TextEditingController(text: server?.containerName ?? '');
    final port = TextEditingController(
      text: '${server?.port == null || server!.port == 0 ? 8000 : server.port}',
    );
    final url = TextEditingController(text: server?.url ?? '');
    final ssePath = TextEditingController(text: server?.ssePath ?? '');
    final env = TextEditingController(
      text: (server?.environments ?? const [])
          .map((item) => '${item['key'] ?? ''}=${item['value'] ?? ''}')
          .join('\n'),
    );
    final volumes = TextEditingController(
      text: (server?.volumes ?? const [])
          .map((item) => '${item['source'] ?? ''}:${item['target'] ?? ''}')
          .join('\n'),
    );
    String type = server?.type.isNotEmpty == true ? server!.type : 'npx';
    String protocol = server?.protocol.isNotEmpty == true
        ? server!.protocol
        : 'http://';
    String transport = server?.outputTransport.isNotEmpty == true
        ? server!.outputTransport
        : 'sse';
    final saved = await pushFormPage<bool>(
      context,
      StatefulBuilder(
        builder: (pageContext, setState) => SimpleFormPage(
          title: server == null ? l10n.ai_mcp_add : l10n.action_edit,
          saveLabel: server == null ? l10n.action_create : l10n.action_save,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(controller: name, label: l10n.ai_mcp_name),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: InputDecoration(labelText: l10n.ai_mcp_type),
              items: const [
                DropdownMenuItem(value: 'npx', child: Text('npx')),
                DropdownMenuItem(value: 'uvx', child: Text('uvx')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => type = value);
              },
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: command,
              label: l10n.ai_mcp_command,
              maxLines: 3,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: container, label: l10n.ai_mcp_container),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: port,
              label: l10n.ai_mcp_port,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: protocol,
              decoration: InputDecoration(labelText: l10n.ai_mcp_protocol),
              items: const [
                DropdownMenuItem(value: 'http://', child: Text('http://')),
                DropdownMenuItem(value: 'https://', child: Text('https://')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => protocol = value);
              },
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: url, label: l10n.ai_mcp_url),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: transport,
              decoration: InputDecoration(labelText: l10n.ai_mcp_transport),
              items: const [
                DropdownMenuItem(value: 'sse', child: Text('SSE')),
                DropdownMenuItem(
                  value: 'streamableHttp',
                  child: Text('Streamable HTTP'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => transport = value);
              },
            ),
            if (transport == 'sse') ...[
              const SizedBox(height: AppTokens.s12),
              AppTextField(controller: ssePath, label: l10n.ai_mcp_sse_path),
            ],
            const SizedBox(height: AppTokens.s16),
            AppTextField(
              controller: env,
              label: l10n.ai_mcp_environments,
              helper: l10n.ai_mcp_env_hint,
              maxLines: 4,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: volumes,
              label: l10n.ai_mcp_volumes,
              helper: l10n.ai_mcp_volume_hint,
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
    final body = <String, dynamic>{
      if (server != null) 'id': server.id,
      'name': name.text.trim(),
      'type': type,
      'command': command.text.trim(),
      'containerName': container.text.trim(),
      'port': int.tryParse(port.text.trim()) ?? 0,
      'protocol': protocol,
      'baseUrl': '$protocol${url.text.trim()}',
      'url': url.text.trim(),
      'outputTransport': transport,
      'ssePath': ssePath.text.trim(),
      'environments': _parseEnv(env.text),
      'volumes': _parseVolumes(volumes.text),
      if (server == null) 'taskID': const Uuid().v4(),
    };
    name.dispose();
    command.dispose();
    container.dispose();
    port.dispose();
    url.dispose();
    ssePath.dispose();
    env.dispose();
    volumes.dispose();
    if (saved != true || !mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      if (server == null) {
        await repository.createMcpServer(body);
      } else {
        await repository.updateMcpServer(body);
      }
      if (!mounted) return;
      ref.invalidate(mcpServersProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showModelActions(OllamaModelDto model) async {
    final l10n = AppLocalizations.of(context);
    final value = await showSelectionMenu<String>(
      context,
      title: model.name,
      options: [
        SelectionOption(
          label: l10n.ai_model_load,
          value: 'load',
          icon: TablerIcons.player_play,
        ),
        SelectionOption(
          label: l10n.ai_model_unload,
          value: 'close',
          icon: TablerIcons.player_pause,
        ),
        SelectionOption(
          label: l10n.action_delete,
          value: 'delete',
          icon: TablerIcons.trash,
          danger: true,
        ),
      ],
    );
    if (value == null || !mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      if (!mounted) return;
      if (value == 'delete') {
        final confirmed = await showConfirmSheet(
          context,
          title: l10n.action_delete,
          message: model.name,
          confirmLabel: l10n.action_delete,
        );
        if (!confirmed) return;
        await repository.deleteOllamaModels([model.id]);
      } else if (value == 'load') {
        await repository.loadOllamaModel(model.name);
      } else {
        await repository.closeOllamaModel(model.name);
      }
      if (!mounted) return;
      ref.invalidate(ollamaModelsProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showMcpDetail(McpServerDto server) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final detail = await repository.getMcpServer(server.id);
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.9,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(detail.name, style: AppTextStyles.titleL)),
                IconButton(
                  tooltip: l10n.action_close,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const Icon(TablerIcons.x),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s12),
            SplitListGroup(
              children: [
                SplitListTile(
                  title: l10n.ai_model_status,
                  value: detail.status,
                ),
                SplitListTile(title: l10n.ai_mcp_type, value: detail.type),
                SplitListTile(
                  title: l10n.ai_mcp_command,
                  value: detail.command,
                ),
                SplitListTile(
                  title: l10n.ai_mcp_container,
                  value: detail.containerName,
                ),
                SplitListTile(title: l10n.ai_mcp_port, value: '${detail.port}'),
                SplitListTile(
                  title: l10n.ai_mcp_transport,
                  value: detail.outputTransport,
                ),
                if (detail.ssePath.isNotEmpty)
                  SplitListTile(
                    title: l10n.ai_mcp_sse_path,
                    value: detail.ssePath,
                  ),
                if (detail.streamableHttpPath.isNotEmpty)
                  SplitListTile(
                    title: 'Streamable HTTP',
                    value: detail.streamableHttpPath,
                  ),
                if (detail.baseUrl.isNotEmpty)
                  SplitListTile(title: l10n.ai_mcp_url, value: detail.baseUrl),
                if (detail.gatewayImage.isNotEmpty)
                  SplitListTile(
                    title: 'Gateway image',
                    value: detail.gatewayImage,
                  ),
                if (detail.environments.isNotEmpty)
                  SplitListTile(
                    title: l10n.ai_mcp_environments,
                    value: detail.environments
                        .map((item) => '${item['key'] ?? ''}')
                        .join(', '),
                  ),
                if (detail.volumes.isNotEmpty)
                  SplitListTile(
                    title: l10n.ai_mcp_volumes,
                    value: detail.volumes
                        .map(
                          (item) =>
                              '${item['source'] ?? ''}:${item['target'] ?? ''}',
                        )
                        .join('\n'),
                  ),
                if (detail.message.isNotEmpty)
                  SplitListTile(
                    title: l10n.error_details,
                    value: detail.message,
                  ),
              ],
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _bindMcpDomain() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final current = await repository.getMcpDomain();
      if (!mounted) return;
      final domain = TextEditingController(text: current.domain);
      final sslId = TextEditingController(
        text: current.sslID == 0 ? '' : '${current.sslID}',
      );
      final ipList = TextEditingController(text: current.allowIPs.join(','));
      final saved = await pushFormPage<bool>(
        context,
        Builder(
          builder: (pageContext) => SimpleFormPage(
            title: current.domain.isEmpty
                ? l10n.ai_mcp_bind_domain
                : l10n.ai_mcp_update_domain,
            saveLabel: l10n.action_save,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              AppTextField(controller: domain, label: l10n.ai_mcp_domain),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: sslId,
                label: l10n.ai_mcp_ssl_id,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: ipList,
                label: l10n.ai_mcp_ip_list,
                helper: '192.168.1.1,10.0.0.0/8',
              ),
              if (current.connUrl.isNotEmpty) ...[
                const SizedBox(height: AppTokens.s12),
                InputDecorator(
                  decoration: InputDecoration(labelText: l10n.ai_mcp_conn_url),
                  child: Text(current.connUrl),
                ),
              ],
            ],
          ),
        ),
      );
      final name = domain.text.trim();
      final ssl = int.tryParse(sslId.text.trim()) ?? 0;
      final ips = ipList.text.trim();
      domain.dispose();
      sslId.dispose();
      ipList.dispose();
      if (saved != true || !mounted || name.isEmpty) return;
      if (current.domain.isEmpty) {
        await repository.bindMcpDomain(domain: name, sslID: ssl, ipList: ips);
      } else {
        await repository.updateMcpDomain(
          websiteID: current.websiteID,
          sslID: ssl,
          ipList: ips,
        );
      }
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editAccount([AiAccountDto? account]) async {
    final l10n = AppLocalizations.of(context);
    List<AiProviderDto> providers;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      providers = await repository.getProviders();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
      return;
    }
    if (!mounted) return;
    if (providers.isEmpty) {
      AppToast.warning(context, l10n.ai_accounts_empty);
      return;
    }
    if (!mounted) return;
    var provider = providers.firstWhere(
      (item) => item.provider == account?.provider,
      orElse: () => providers.first,
    );
    var apiType = provider.apiTypes.firstWhere(
      (item) => item.apiType == account?.apiType,
      orElse: () => provider.apiTypes.isEmpty
          ? const AiProviderApiDto(
              apiType: '',
              baseUrl: '',
              defaultAuthMode: '',
              authModes: [],
              models: [],
            )
          : provider.apiTypes.first,
    );
    final name = TextEditingController(text: account?.name ?? '');
    final baseUrl = TextEditingController(
      text: account?.baseUrl.isNotEmpty == true
          ? account!.baseUrl
          : (apiType.baseUrl.isNotEmpty ? apiType.baseUrl : provider.baseUrl),
    );
    final apiKey = TextEditingController(text: account?.apiKey ?? '');
    final remark = TextEditingController(text: account?.remark ?? '');
    var verifyModel = account?.verifyModel ?? '';
    var rememberKey = account?.rememberApiKey ?? true;
    var validate = account?.validateAvailability ?? true;
    final saved = await pushFormPage<bool>(
      context,
      StatefulBuilder(
        builder: (pageContext, setState) => SimpleFormPage(
          title: account == null ? l10n.ai_account_add : l10n.ai_account_edit,
          saveLabel: account == null ? l10n.action_create : l10n.action_save,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            DropdownButtonFormField<String>(
              initialValue: provider.provider,
              decoration: InputDecoration(labelText: l10n.ai_account_provider),
              items: [
                for (final item in providers)
                  DropdownMenuItem(
                    value: item.provider,
                    child: Text(item.displayName),
                  ),
              ],
              onChanged: account != null
                  ? null
                  : (value) {
                      final next = providers.firstWhere(
                        (item) => item.provider == value,
                      );
                      setState(() {
                        provider = next;
                        apiType = next.apiTypes.isEmpty
                            ? apiType
                            : next.apiTypes.first;
                        baseUrl.text = apiType.baseUrl.isNotEmpty
                            ? apiType.baseUrl
                            : next.baseUrl;
                        verifyModel = '';
                      });
                    },
            ),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue:
                  provider.apiTypes.any(
                    (item) => item.apiType == apiType.apiType,
                  )
                  ? apiType.apiType
                  : null,
              decoration: InputDecoration(labelText: l10n.ai_account_api_type),
              items: [
                for (final item in provider.apiTypes)
                  DropdownMenuItem(
                    value: item.apiType,
                    child: Text(item.apiType),
                  ),
              ],
              onChanged: (value) {
                final next = provider.apiTypes.firstWhere(
                  (item) => item.apiType == value,
                  orElse: () => apiType,
                );
                setState(() {
                  apiType = next;
                  if (next.baseUrl.isNotEmpty) baseUrl.text = next.baseUrl;
                  verifyModel = '';
                });
              },
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: name, label: l10n.ai_account_name),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: baseUrl, label: l10n.ai_account_base_url),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: apiKey,
              label: l10n.ai_account_api_key,
              obscure: true,
            ),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: apiType.models.any((item) => item.id == verifyModel)
                  ? verifyModel
                  : null,
              decoration: InputDecoration(
                labelText: l10n.ai_account_verify_model,
              ),
              items: [
                for (final item in apiType.models)
                  DropdownMenuItem(value: item.id, child: Text(item.name)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => verifyModel = value);
              },
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: remark, label: l10n.ai_account_remark),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.ai_account_remember_key),
              value: rememberKey,
              onChanged: (value) => setState(() => rememberKey = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.ai_account_validate),
              value: validate,
              onChanged: (value) => setState(() => validate = value),
            ),
          ],
        ),
      ),
    );
    final body = <String, dynamic>{
      if (account != null) 'id': account.id,
      'provider': provider.provider,
      'name': name.text.trim(),
      'apiKey': apiKey.text.trim(),
      'rememberApiKey': rememberKey,
      'baseURL': baseUrl.text.trim(),
      'apiType': apiType.apiType,
      'authMode': apiType.defaultAuthMode,
      'verifyModel': verifyModel,
      'validateAvailability': validate,
      'remark': remark.text.trim(),
      if (account != null) 'syncAgents': false,
    };
    name.dispose();
    baseUrl.dispose();
    apiKey.dispose();
    remark.dispose();
    if (saved != true || !mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      if (account == null) {
        await repository.createAccount(body);
      } else {
        await repository.updateAccount(body);
      }
      if (!mounted) return;
      ref.invalidate(aiAccountsProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showAccountActions(AiAccountDto account) async {
    final l10n = AppLocalizations.of(context);
    final value = await showSelectionMenu<String>(
      context,
      title: account.name,
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
    if (value == null || !mounted) return;
    if (value == 'edit') {
      await _editAccount(account);
      return;
    }
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: account.name,
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      await repository.deleteAccount(account.id);
      if (!mounted) return;
      ref.invalidate(aiAccountsProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  int _defaultAgentPort(String type) {
    return switch (type) {
      'copaw' || 'octop' => 8088,
      'hermes-agent' => 9119,
      'deepseek-harness' => 10443,
      _ => 18789,
    };
  }

  Future<void> _addAgent() async {
    final l10n = AppLocalizations.of(context);
    var agentType = 'openclaw';
    var versions = const <String>[];
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final detail = await repository.getAppDetail(agentType);
      versions = detail.versions;
    } catch (_) {
      versions = const [];
    }
    if (!mounted) return;
    var version = versions.isEmpty ? '' : versions.first;
    final name = TextEditingController();
    final remark = TextEditingController();
    final accessHost = TextEditingController();
    final username = TextEditingController(text: 'admin');
    final password = TextEditingController(
      text: const Uuid().v4().replaceAll('-', '').substring(0, 12),
    );
    final port = TextEditingController(text: '${_defaultAgentPort(agentType)}');
    final saved = await pushFormPage<bool>(
      context,
      StatefulBuilder(
        builder: (pageContext, setState) => SimpleFormPage(
          title: l10n.ai_agent_add,
          saveLabel: l10n.action_create,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            DropdownButtonFormField<String>(
              initialValue: agentType,
              decoration: InputDecoration(labelText: l10n.ai_agent_type),
              items: const [
                DropdownMenuItem(value: 'openclaw', child: Text('OpenClaw')),
                DropdownMenuItem(
                  value: 'hermes-agent',
                  child: Text('Hermes Agent'),
                ),
                DropdownMenuItem(value: 'copaw', child: Text('QwenPaw')),
                DropdownMenuItem(
                  value: 'deepseek-harness',
                  child: Text('DeepSeek Harness'),
                ),
                DropdownMenuItem(value: 'octop', child: Text('Octop')),
              ],
              onChanged: (value) async {
                if (value == null) return;
                setState(() {
                  agentType = value;
                  versions = const [];
                  version = '';
                  port.text = '${_defaultAgentPort(value)}';
                });
                try {
                  final repository = await ref.read(
                    appRepositoryProvider.future,
                  );
                  final detail = await repository.getAppDetail(value);
                  if (!mounted || agentType != value) return;
                  setState(() {
                    versions = detail.versions;
                    version = versions.isEmpty ? '' : versions.first;
                  });
                } catch (_) {
                  // Keep the form usable; the server reports missing versions.
                }
              },
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: name, label: l10n.ai_account_name),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: remark, label: l10n.ai_agent_remark),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: versions.contains(version) ? version : null,
              decoration: InputDecoration(labelText: l10n.ai_agent_version),
              items: [
                for (final item in versions)
                  DropdownMenuItem(value: item, child: Text(item)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => version = value);
              },
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: port,
              label: l10n.ai_agent_port,
              keyboardType: TextInputType.number,
            ),
            if (agentType == 'deepseek-harness') ...[
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: accessHost,
                label: l10n.ai_agent_access_host,
              ),
            ],
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: username, label: l10n.ai_agent_username),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: password,
              label: l10n.ai_agent_password,
              obscure: true,
            ),
          ],
        ),
      ),
    );
    final body = <String, dynamic>{
      'name': name.text.trim(),
      'remark': remark.text.trim(),
      'agentType': agentType,
      'appVersion': version,
      'webUIPort': int.tryParse(port.text.trim()) ?? 0,
      'accessHost': accessHost.text.trim(),
      'dashboardUsername': username.text.trim(),
      'dashboardPassword': password.text,
      'taskID': const Uuid().v4(),
      'advanced': false,
      'containerName': '',
      'allowPort': true,
      'specifyIP': '',
      'restartPolicy': 'unless-stopped',
      'cpuQuota': 0,
      'memoryLimit': 0,
      'memoryUnit': 'M',
      'pullImage': true,
      'editCompose': false,
      'dockerCompose': '',
    };
    name.dispose();
    remark.dispose();
    accessHost.dispose();
    username.dispose();
    password.dispose();
    port.dispose();
    if (saved != true || !mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      await repository.createAgent(body);
      if (!mounted) return;
      ref.invalidate(aiAgentsProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editAgentModel(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final config = await repository.getAgentModelConfig(agent.id);
      final accounts = await repository.searchAccounts();
      if (!mounted) return;
      if (accounts.items.isEmpty) {
        AppToast.warning(context, l10n.ai_accounts_empty);
        return;
      }
      var account = accounts.items.firstWhere(
        (item) => item.id == config.accountId,
        orElse: () => accounts.items.first,
      );
      var model = account.models.any((item) => item.id == config.model)
          ? config.model
          : (account.models.isEmpty ? '' : account.models.first.id);
      final fallbacks = TextEditingController(text: config.fallbacks.join(','));
      final saved = await pushFormPage<bool>(
        context,
        StatefulBuilder(
          builder: (pageContext, setState) => SimpleFormPage(
            title: l10n.ai_agent_model_config,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              DropdownButtonFormField<int>(
                initialValue: account.id,
                decoration: InputDecoration(labelText: l10n.ai_accounts),
                items: [
                  for (final item in accounts.items)
                    DropdownMenuItem(value: item.id, child: Text(item.name)),
                ],
                onChanged: (value) {
                  final next = accounts.items.firstWhere(
                    (item) => item.id == value,
                  );
                  setState(() {
                    account = next;
                    model = next.models.isEmpty ? '' : next.models.first.id;
                  });
                },
              ),
              const SizedBox(height: AppTokens.s12),
              DropdownButtonFormField<String>(
                initialValue: account.models.any((item) => item.id == model)
                    ? model
                    : null,
                decoration: InputDecoration(labelText: l10n.ai_agent_model),
                items: [
                  for (final item in account.models)
                    DropdownMenuItem(value: item.id, child: Text(item.name)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => model = value);
                },
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: fallbacks,
                label: l10n.ai_agent_fallbacks,
                helper: 'model-a,model-b',
              ),
            ],
          ),
        ),
      );
      final fallbackList = fallbacks.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
      fallbacks.dispose();
      if (saved != true || !mounted || model.isEmpty) return;
      await repository.updateAgentModelConfig(
        agentId: agent.id,
        accountId: account.id,
        model: model,
        fallbacks: fallbackList,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<bool> _createAgentRole(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final channels = await repository.getAgentChannels(agent.id);
      if (!mounted) return false;
      final name = TextEditingController();
      final model = TextEditingController();
      final accountId = TextEditingController();
      var channel = '';
      final saved = await pushFormPage<bool>(
        context,
        StatefulBuilder(
          builder: (pageContext, setState) => SimpleFormPage(
            title: l10n.ai_agent_role_add,
            saveLabel: l10n.action_create,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              AppTextField(controller: name, label: l10n.ai_agent_role_name),
              const SizedBox(height: AppTokens.s12),
              AppTextField(controller: model, label: l10n.ai_agent_model),
              const SizedBox(height: AppTokens.s12),
              DropdownButtonFormField<String>(
                initialValue: channel.isEmpty ? null : channel,
                decoration: InputDecoration(
                  labelText: l10n.ai_agent_binding_channel,
                ),
                items: [
                  for (final item in channels)
                    DropdownMenuItem(value: item.name, child: Text(item.name)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => channel = value);
                },
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: accountId,
                label: l10n.ai_agent_account_id,
              ),
            ],
          ),
        ),
      );
      final roleName = name.text.trim();
      final roleModel = model.text.trim();
      final boundAccount = accountId.text.trim();
      name.dispose();
      model.dispose();
      accountId.dispose();
      if (saved != true || !mounted || roleName.isEmpty) return false;
      await repository.createAgentRole(
        agentId: agent.id,
        name: roleName,
        model: roleModel,
        bindings: [
          if (channel.isNotEmpty && boundAccount.isNotEmpty)
            {'channel': channel, 'accountId': boundAccount},
        ],
      );
      return true;
    } catch (error) {
      if (!mounted) return false;
      showErrorToast(context, error);
      return false;
    }
  }

  Future<bool> _editRoleBinding(
    AiAgentDto agent,
    AiAgentRoleDto role,
    String action,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final channels = await repository.getAgentChannels(agent.id);
      if (!mounted) return false;
      if (channels.isEmpty) {
        AppToast.warning(context, l10n.ai_agent_channels_empty);
        return false;
      }
      var channel = channels.first.name;
      final account = TextEditingController();
      final saved = await pushFormPage<bool>(
        context,
        StatefulBuilder(
          builder: (pageContext, setState) => SimpleFormPage(
            title: action == 'bind'
                ? l10n.ai_agent_bind_channel
                : l10n.ai_agent_unbind_channel,
            saveLabel: l10n.action_save,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              DropdownButtonFormField<String>(
                initialValue: channel,
                decoration: InputDecoration(
                  labelText: l10n.ai_agent_binding_channel,
                ),
                items: [
                  for (final item in channels)
                    DropdownMenuItem(value: item.name, child: Text(item.name)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => channel = value);
                },
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: account,
                label: l10n.ai_agent_account_id,
              ),
            ],
          ),
        ),
      );
      final accountId = account.text.trim();
      account.dispose();
      if (saved != true || !mounted) return false;
      if (action == 'bind') {
        await repository.bindAgentRole(
          agentId: agent.id,
          roleId: role.id,
          channel: channel,
          accountId: accountId,
        );
      } else {
        await repository.unbindAgentRole(
          agentId: agent.id,
          roleId: role.id,
          channel: channel,
          accountId: accountId,
        );
      }
      return true;
    } catch (error) {
      if (!mounted) return false;
      showErrorToast(context, error);
      return false;
    }
  }

  Future<void> _showAgentRoles(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final roles = await repository.getAgentRoles(agent.id);
      if (!mounted) return;
      final items = List<AiAgentRoleDto>.of(roles);
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.9,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setState) => SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.ai_agent_roles,
                        style: AppTextStyles.titleM,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.ai_agent_role_add,
                      onPressed: () async {
                        final created = await _createAgentRole(agent);
                        if (!created) return;
                        final latest = await repository.getAgentRoles(agent.id);
                        setState(() {
                          items
                            ..clear()
                            ..addAll(latest);
                        });
                      },
                      icon: const Icon(TablerIcons.plus),
                    ),
                    IconButton(
                      tooltip: l10n.action_close,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(TablerIcons.x),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s8),
                Expanded(
                  child: items.isEmpty
                      ? Center(child: Text(l10n.ai_agent_roles_empty))
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppTokens.s8),
                          itemBuilder: (context, index) {
                            final role = items[index];
                            return TonalCard(
                              onTap: () async {
                                final action = await showSelectionMenu<String>(
                                  context,
                                  title: role.name.isEmpty
                                      ? role.id
                                      : role.name,
                                  options: [
                                    SelectionOption(
                                      label: l10n.ai_agent_bind_channel,
                                      value: 'bind',
                                      icon: TablerIcons.link,
                                    ),
                                    SelectionOption(
                                      label: l10n.ai_agent_unbind_channel,
                                      value: 'unbind',
                                      icon: TablerIcons.unlink,
                                    ),
                                  ],
                                );
                                if (action == null || !context.mounted) return;
                                final changed = await _editRoleBinding(
                                  agent,
                                  role,
                                  action,
                                );
                                if (!changed || !context.mounted) return;
                                final latest = await repository.getAgentRoles(
                                  agent.id,
                                );
                                if (!mounted) return;
                                setState(() {
                                  items
                                    ..clear()
                                    ..addAll(latest);
                                });
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          role.name.isEmpty
                                              ? role.id
                                              : role.name,
                                          style: AppTextStyles.titleM,
                                        ),
                                        Text(
                                          [
                                            if (role.workspace.isNotEmpty)
                                              role.workspace,
                                            if (role.model.isNotEmpty)
                                              role.model,
                                            if (role.bindings.isNotEmpty)
                                              '${role.bindings.length} bindings',
                                          ].join(' · '),
                                          style: AppTextStyles.caption.copyWith(
                                            color:
                                                context.scheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: l10n.action_delete,
                                    icon: Icon(
                                      TablerIcons.trash,
                                      color: context.appColors.danger,
                                    ),
                                    onPressed: () async {
                                      final confirmed = await showConfirmSheet(
                                        context,
                                        title: l10n.action_delete,
                                        message: l10n
                                            .ai_agent_delete_role_confirm(
                                              role.name.isEmpty
                                                  ? role.id
                                                  : role.name,
                                            ),
                                        confirmLabel: l10n.action_delete,
                                      );
                                      if (!confirmed) return;
                                      await repository.deleteAgentRole(
                                        agent.id,
                                        role.id,
                                      );
                                      setState(() => items.removeAt(index));
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showAgentChannels(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final channels = await repository.getAgentChannels(agent.id);
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.ai_agent_channels,
                    style: AppTextStyles.titleM,
                  ),
                ),
                IconButton(
                  tooltip: l10n.action_close,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const Icon(TablerIcons.x),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s8),
            if (channels.isEmpty)
              Text(l10n.ai_agent_channels_empty)
            else
              for (final channel in channels)
                ListTile(
                  dense: true,
                  leading: Icon(
                    channel.bound ? TablerIcons.link : TablerIcons.unlink,
                  ),
                  title: Text(
                    channel.name.isEmpty
                        ? channel.accountIds.join(',')
                        : channel.name,
                  ),
                  subtitle: Text(
                    channel.bound ? l10n.ai_agent_bound : l10n.ai_agent_unbound,
                  ),
                ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _removeChannelConfig(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    final channel = await showSelectionMenu<String>(
      context,
      title: l10n.ai_agent_channel_delete,
      options: const [
        SelectionOption(value: 'feishu', label: 'Feishu'),
        SelectionOption(value: 'telegram', label: 'Telegram'),
        SelectionOption(value: 'discord', label: 'Discord'),
        SelectionOption(value: 'wecom', label: 'WeCom'),
        SelectionOption(value: 'dingtalk', label: 'DingTalk'),
        SelectionOption(value: 'qqbot', label: 'QQ Bot'),
        SelectionOption(value: 'weixin', label: 'Weixin'),
      ],
    );
    if (channel == null || !mounted) return;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.ai_agent_channel_delete,
      message: l10n.ai_agent_channel_delete_confirm(channel),
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      await repository.deleteChannelConfig(agent.id, channel);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editChannelConfig(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    final channel = await showSelectionMenu<String>(
      context,
      title: l10n.ai_agent_channel_config,
      options: const [
        SelectionOption(value: 'telegram', label: 'Telegram'),
        SelectionOption(value: 'discord', label: 'Discord'),
        SelectionOption(value: 'wecom', label: 'WeCom'),
        SelectionOption(value: 'dingtalk', label: 'DingTalk'),
        SelectionOption(value: 'qqbot', label: 'QQ Bot'),
      ],
    );
    if (channel == null || !mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final data = await repository.getChannelConfig(channel, agent.id);
      if (!mounted) return;
      final controller = TextEditingController(
        text: const JsonEncoder.withIndent('  ').convert(data),
      );
      String? error;
      final result = await pushFormPage<Map<String, dynamic>>(
        context,
        StatefulBuilder(
          builder: (pageContext, setState) => SimpleFormPage(
            title: '${l10n.ai_agent_channel_config} · $channel',
            onSave: () async {
              try {
                final decoded = jsonDecode(controller.text);
                if (decoded is! Map) {
                  throw const FormatException();
                }
                Navigator.of(
                  pageContext,
                ).pop(Map<String, dynamic>.from(decoded));
              } catch (_) {
                setState(() => error = l10n.ai_agent_channel_json_invalid);
              }
            },
            children: [
              AppTextField(
                controller: controller,
                label: l10n.ai_agent_channel_json,
                helper: l10n.ai_agent_channel_json_hint,
                maxLines: 14,
              ),
              if (error != null)
                Text(
                  error!,
                  style: AppTextStyles.bodyS.copyWith(
                    color: pageContext.scheme.error,
                  ),
                ),
            ],
          ),
        ),
      );
      controller.dispose();
      if (result == null || !mounted) return;
      await repository.updateChannelConfig(channel, {
        ...result,
        'agentId': agent.id,
      });
      if (!mounted) return;
      AppToast.success(context, l10n.ai_agent_channel_saved);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _loginWeixin(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    final taskID = const Uuid().v4();
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      await repository.loginWeixinChannel(agent.id, taskID);
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.92,
        builder: (sheetContext) => SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.ai_agent_weixin_login,
                          style: AppTextStyles.titleM,
                        ),
                        Text(
                          l10n.ai_agent_weixin_login_hint,
                          style: AppTextStyles.caption.copyWith(
                            color: sheetContext.scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.action_close,
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(TablerIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.s8),
              Expanded(
                child: LogPreviewPage(
                  title: l10n.ai_agent_weixin_login,
                  embedded: true,
                  sources: [
                    LogSourceOption(
                      label: l10n.ai_agent_weixin_login,
                      load: () async {
                        final appRepository = await ref.read(
                          appRepositoryProvider.future,
                        );
                        final log = await appRepository.readTaskLog(taskID);
                        return log.lines;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editFeishuConfig(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final config = await repository.getFeishuConfig(agent.id);
      if (!mounted) return;
      var enabled = config.enabled;
      var threadSession = config.threadSession;
      var streaming = config.streaming;
      var requireMention = config.requireMention;
      var groupPolicy = config.groupPolicy;
      var connectionMode = config.connectionMode;
      final saved = await pushFormPage<bool>(
        context,
        StatefulBuilder(
          builder: (pageContext, setState) => SimpleFormPage(
            title: l10n.ai_agent_feishu,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.ai_agent_channel_enabled),
                value: enabled,
                onChanged: (value) => setState(() => enabled = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.ai_agent_thread_session),
                value: threadSession,
                onChanged: (value) => setState(() => threadSession = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.ai_agent_streaming),
                value: streaming,
                onChanged: (value) => setState(() => streaming = value),
              ),
              const SizedBox(height: AppTokens.s12),
              DropdownButtonFormField<String>(
                initialValue: requireMention,
                decoration: InputDecoration(
                  labelText: l10n.ai_agent_require_mention,
                ),
                items: const [
                  DropdownMenuItem(value: 'true', child: Text('true')),
                  DropdownMenuItem(value: 'false', child: Text('false')),
                  DropdownMenuItem(value: 'open', child: Text('open')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => requireMention = value);
                },
              ),
              const SizedBox(height: AppTokens.s12),
              DropdownButtonFormField<String>(
                initialValue: groupPolicy,
                decoration: InputDecoration(
                  labelText: l10n.ai_agent_group_policy,
                ),
                items: const [
                  DropdownMenuItem(value: 'open', child: Text('open')),
                  DropdownMenuItem(
                    value: 'allowlist',
                    child: Text('allowlist'),
                  ),
                  DropdownMenuItem(value: 'disabled', child: Text('disabled')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => groupPolicy = value);
                },
              ),
              const SizedBox(height: AppTokens.s12),
              DropdownButtonFormField<String>(
                initialValue: connectionMode,
                decoration: InputDecoration(
                  labelText: l10n.ai_agent_connection_mode,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'websocket',
                    child: Text('websocket'),
                  ),
                  DropdownMenuItem(value: 'webhook', child: Text('webhook')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => connectionMode = value);
                },
              ),
              if (config.bots.isNotEmpty) ...[
                const SizedBox(height: AppTokens.s16),
                Text(l10n.ai_agent_bots, style: AppTextStyles.titleS),
                for (final bot in config.bots)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(TablerIcons.robot),
                    title: Text(bot.name.isEmpty ? bot.accountId : bot.name),
                    subtitle: Text(bot.appId),
                    trailing: Text(
                      bot.enabled ? l10n.ai_agent_bound : l10n.ai_agent_unbound,
                    ),
                  ),
              ],
            ],
          ),
        ),
      );
      if (saved != true || !mounted) return;
      await repository.updateFeishuConfig({
        'agentId': agent.id,
        'enabled': enabled,
        'threadSession': threadSession,
        'streaming': streaming,
        'requireMention': requireMention,
        'groupPolicy': groupPolicy,
        'groupAllowFrom': config.groupAllowFrom,
        'domain': config.domain,
        'connectionMode': connectionMode,
        'bots': config.bots.map((bot) => bot.toJson()).toList(growable: false),
      });
      if (!mounted) return;
      AppToast.success(context, l10n.ai_agent_channel_saved);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _bindAgentWebsite(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      if (!mounted) return;
      if (agent.websiteId > 0) {
        final confirmed = await showConfirmSheet(
          context,
          title: l10n.ai_agent_unbind_website,
          message: agent.websitePrimaryDomain,
          confirmLabel: l10n.ai_agent_unbind_website,
        );
        if (!confirmed || !mounted) return;
        await repository.unbindAgentWebsite(agent.id);
      } else {
        final websiteRepository = await ref.read(
          websiteRepositoryProvider.future,
        );
        final page = await websiteRepository.searchWebsites(
          const WebsiteSearchReq(page: 1, pageSize: 100),
        );
        if (!mounted) return;
        if (page.items.isEmpty) {
          AppToast.warning(context, l10n.websites_empty_title);
          return;
        }
        final selected = await showSelectionMenu<int>(
          context,
          title: l10n.ai_agent_select_website,
          options: [
            for (final site in page.items)
              SelectionOption(
                label: site.primaryDomain,
                value: site.id,
                icon: TablerIcons.world,
              ),
          ],
        );
        if (selected == null || !mounted) return;
        await repository.bindAgentWebsite(agent.id, selected);
      }
      if (!mounted) return;
      ref.invalidate(aiAgentsProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showAgentActions(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    final value = await showSelectionMenu<String>(
      context,
      title: agent.name,
      options: [
        SelectionOption(
          label: l10n.ai_agent_model_config,
          value: 'model',
          icon: TablerIcons.brain,
        ),
        SelectionOption(
          label: agent.websiteId > 0
              ? l10n.ai_agent_unbind_website
              : l10n.ai_agent_bind_website,
          value: 'website',
          icon: TablerIcons.world,
        ),
        SelectionOption(
          label: l10n.ai_agent_roles,
          value: 'roles',
          icon: TablerIcons.users,
        ),
        SelectionOption(
          label: l10n.ai_agent_channels,
          value: 'channels',
          icon: TablerIcons.link,
        ),
        SelectionOption(
          label: l10n.ai_agent_feishu,
          value: 'feishu',
          icon: TablerIcons.send,
        ),
        SelectionOption(
          label: l10n.ai_agent_channel_config,
          value: 'channel',
          icon: TablerIcons.adjustments,
        ),
        SelectionOption(
          label: l10n.ai_agent_channel_delete,
          value: 'channel_delete',
          icon: TablerIcons.trash,
          danger: true,
        ),
        SelectionOption(
          label: l10n.ai_agent_weixin_login,
          value: 'weixin',
          icon: TablerIcons.qrcode,
        ),
        SelectionOption(
          label: l10n.ai_agent_token_reset,
          value: 'token',
          icon: TablerIcons.key,
        ),
        SelectionOption(
          label: l10n.ai_agent_remark,
          value: 'remark',
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
    if (value == null || !mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      if (!mounted) return;
      if (value == 'model') {
        await _editAgentModel(agent);
        return;
      } else if (value == 'website') {
        await _bindAgentWebsite(agent);
        return;
      } else if (value == 'roles') {
        await _showAgentRoles(agent);
        return;
      } else if (value == 'channels') {
        await _showAgentChannels(agent);
        return;
      } else if (value == 'feishu') {
        await _editFeishuConfig(agent);
        return;
      } else if (value == 'channel') {
        await _editChannelConfig(agent);
        return;
      } else if (value == 'channel_delete') {
        await _removeChannelConfig(agent);
        return;
      } else if (value == 'weixin') {
        await _loginWeixin(agent);
        return;
      } else if (value == 'token') {
        await repository.resetAgentToken(agent.id);
      } else if (value == 'remark') {
        final controller = TextEditingController(text: agent.remark);
        final saved = await pushFormPage<bool>(
          context,
          Builder(
            builder: (pageContext) => SimpleFormPage(
              title: l10n.ai_agent_remark,
              onSave: () async => Navigator.of(pageContext).pop(true),
              children: [
                AppTextField(
                  controller: controller,
                  label: l10n.ai_agent_remark,
                ),
              ],
            ),
          ),
        );
        final remark = controller.text.trim();
        controller.dispose();
        if (saved != true) return;
        await repository.updateAgentRemark(agent.id, remark);
      } else {
        final confirmed = await showConfirmSheet(
          context,
          title: l10n.action_delete,
          message: l10n.ai_agent_delete_confirm(agent.name),
          confirmLabel: l10n.action_delete,
          requireText: agent.name,
        );
        if (!confirmed) return;
        await repository.deleteAgent(agent.id);
      }
      if (!mounted) return;
      ref.invalidate(aiAgentsProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showMcpActions(McpServerDto server) async {
    final l10n = AppLocalizations.of(context);
    final value = await showSelectionMenu<String>(
      context,
      title: server.name,
      options: [
        SelectionOption(
          label: l10n.error_details,
          value: 'detail',
          icon: TablerIcons.info_circle,
        ),
        SelectionOption(
          label: l10n.ai_mcp_domain,
          value: 'domain',
          icon: TablerIcons.world,
        ),
        SelectionOption(
          label: l10n.ai_mcp_start,
          value: 'start',
          icon: TablerIcons.player_play,
        ),
        SelectionOption(
          label: l10n.ai_mcp_stop,
          value: 'stop',
          icon: TablerIcons.player_stop,
        ),
        SelectionOption(
          label: l10n.ai_mcp_restart,
          value: 'restart',
          icon: TablerIcons.refresh,
        ),
        SelectionOption(
          label: l10n.ai_mcp_test,
          value: 'test',
          icon: TablerIcons.plug_connected,
        ),
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
    if (value == null || !mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      if (!mounted) return;
      switch (value) {
        case 'detail':
          await _showMcpDetail(server);
          return;
        case 'domain':
          await _bindMcpDomain();
          return;
        case 'edit':
          await _editMcp(server);
          return;
        case 'delete':
          final confirmed = await showConfirmSheet(
            context,
            title: l10n.action_delete,
            message: l10n.ai_mcp_delete_confirm(server.name),
            confirmLabel: l10n.action_delete,
            requireText: server.name,
          );
          if (!confirmed) return;
          await repository.deleteMcpServer(server.id);
        case 'test':
          final result = await repository.testMcpServer(server.id);
          if (!mounted) return;
          final ok = result['success'] == true;
          final message = '${result['message'] ?? ''}'.trim();
          AppToast.show(
            context,
            message.isEmpty
                ? (ok
                      ? l10n.ai_mcp_connection_ok
                      : l10n.ai_mcp_connection_failed)
                : message,
            type: ok ? AppToastType.success : AppToastType.warning,
          );
          return;
        default:
          await repository.operateMcpServer(server.id, value);
      }
      if (!mounted) return;
      ref.invalidate(mcpServersProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
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
                          if (server.url.isNotEmpty)
                            '${server.protocol}${server.url}',
                          if (server.port > 0) ':${server.port}',
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
