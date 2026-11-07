part of 'ai_page.dart';

mixin _AiMcpActions on ConsumerState<AiPage> {
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
}
