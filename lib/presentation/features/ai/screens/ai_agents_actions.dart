part of 'ai_page.dart';

mixin _AiAgentsActions on ConsumerState<AiPage> {
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
      options: [
        SelectionOption(value: 'feishu', label: l10n.alert_method_feishu),
        const SelectionOption(value: 'telegram', label: 'Telegram'),
        const SelectionOption(value: 'discord', label: 'Discord'),
        SelectionOption(value: 'wecom', label: l10n.alert_method_wecom),
        SelectionOption(value: 'dingtalk', label: l10n.alert_method_dingtalk),
        SelectionOption(value: 'qqbot', label: l10n.ai_channel_qqBot),
        SelectionOption(value: 'weixin', label: l10n.ai_channel_weixin),
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
      options: [
        const SelectionOption(value: 'telegram', label: 'Telegram'),
        const SelectionOption(value: 'discord', label: 'Discord'),
        SelectionOption(value: 'wecom', label: l10n.alert_method_wecom),
        SelectionOption(value: 'dingtalk', label: l10n.alert_method_dingtalk),
        SelectionOption(value: 'qqbot', label: l10n.ai_channel_qqBot),
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
}
