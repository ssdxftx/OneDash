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
                                    if (role.workspace.isNotEmpty)
                                      SelectionOption(
                                        label: l10n.ai_agent_markdown,
                                        value: 'markdown',
                                        icon: TablerIcons.file_text,
                                      ),
                                  ],
                                );
                                if (action == 'markdown') {
                                  await _editRoleMarkdown(agent, role);
                                  return;
                                }
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

  String _channelPluginLabel(
    AppLocalizations l10n,
    Map<String, dynamic>? status,
  ) {
    if (status == null || status['installed'] != true) {
      return l10n.ai_channel_notInstalled;
    }
    if (status['upgradable'] == true) {
      return l10n.ai_channel_upgradable('${status['latestVersion'] ?? ''}');
    }
    final version = '${status['currentVersion'] ?? ''}';
    return version.isEmpty
        ? l10n.ai_channel_installed
        : '${l10n.ai_channel_installed} · $version';
  }

  Future<void> _approvePairing(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    var type = 'feishu';
    final code = TextEditingController();
    final account = TextEditingController();
    final saved = await pushFormPage<bool>(
      context,
      StatefulBuilder(
        builder: (pageContext, setState) => SimpleFormPage(
          title: l10n.ai_channel_pairing,
          subtitle: agent.name,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: InputDecoration(labelText: l10n.ai_agent_type),
              items: [
                DropdownMenuItem(
                  value: 'feishu',
                  child: Text(l10n.ai_channel_feishu),
                ),
                DropdownMenuItem(
                  value: 'telegram',
                  child: Text(l10n.ai_channel_telegram),
                ),
                DropdownMenuItem(
                  value: 'discord',
                  child: Text(l10n.ai_channel_discord),
                ),
                DropdownMenuItem(
                  value: 'wecom',
                  child: Text(l10n.ai_channel_wecom),
                ),
                DropdownMenuItem(
                  value: 'qqbot',
                  child: Text(l10n.ai_channel_qqbot),
                ),
                DropdownMenuItem(
                  value: 'dingtalk',
                  child: Text(l10n.ai_channel_dingtalk),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => type = value);
              },
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: code, label: l10n.ai_channel_pairingCode),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: account,
              label: l10n.ai_channel_pairingAccount,
            ),
          ],
        ),
      ),
    );
    final pairingCode = code.text.trim();
    final accountId = account.text.trim();
    code.dispose();
    account.dispose();
    if (saved != true || !mounted || pairingCode.isEmpty) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      await repository.approveAgentChannelPairing(
        agentId: agent.id,
        type: type,
        pairingCode: pairingCode,
        accountId: accountId,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.ai_channel_pairingApproved);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showChannelPlugins(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    const types = ['feishu', 'qqbot', 'wecom', 'dingtalk', 'weixin'];
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final statuses = <String, Map<String, dynamic>>{};
      for (final type in types) {
        statuses[type] = await repository.checkAgentChannelPlugin(
          agentId: agent.id,
          type: type,
        );
      }
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.9,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setState) => SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.ai_channel_plugins, style: AppTextStyles.titleM),
                const SizedBox(height: AppTokens.s8),
                Expanded(
                  child: ListView(
                    children: [
                      for (final type in types)
                        ListTile(
                          dense: true,
                          leading: const Icon(TablerIcons.puzzle),
                          title: Text(type),
                          subtitle: Text(
                            _channelPluginLabel(l10n, statuses[type]),
                          ),
                          onTap: () async {
                            final installed =
                                statuses[type]?['installed'] == true;
                            final upgradable =
                                statuses[type]?['upgradable'] == true;
                            final action = await showSelectionMenu<String>(
                              context,
                              title: type,
                              options: [
                                if (!installed)
                                  SelectionOption(
                                    label: l10n.ai_channel_install,
                                    value: 'install',
                                    icon: TablerIcons.download,
                                  ),
                                if (upgradable)
                                  SelectionOption(
                                    label: l10n.ai_channel_upgrade,
                                    value: 'upgrade',
                                    icon: TablerIcons.arrow_up_circle,
                                  ),
                                if (installed)
                                  SelectionOption(
                                    label: l10n.ai_channel_uninstall,
                                    value: 'uninstall',
                                    icon: TablerIcons.trash,
                                    danger: true,
                                  ),
                              ],
                            );
                            if (action == null || !context.mounted) return;
                            final taskID = const Uuid().v4();
                            if (action == 'install') {
                              await repository.installAgentChannelPlugin(
                                agentId: agent.id,
                                type: type,
                                taskID: taskID,
                              );
                            } else if (action == 'upgrade') {
                              await repository.upgradeAgentChannelPlugin(
                                agentId: agent.id,
                                type: type,
                                taskID: taskID,
                              );
                            } else {
                              await repository.uninstallAgentChannelPlugin(
                                agentId: agent.id,
                                type: type,
                                taskID: taskID,
                              );
                            }
                            if (!context.mounted) return;
                            final latest = await repository
                                .checkAgentChannelPlugin(
                                  agentId: agent.id,
                                  type: type,
                                );
                            setState(() => statuses[type] = latest);
                          },
                        ),
                    ],
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
        SelectionOption(value: 'weixin', label: l10n.ai_channel_weixin),
      ],
    );
    if (channel == null || !mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final data = await repository.getChannelConfig(channel, agent.id);
      if (!mounted) return;
      final result = await pushFormPage<Map<String, dynamic>>(
        context,
        AiChannelConfigPage(channel: channel, initial: data),
      );
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
      var groupSessionScope = config.groupSessionScope;
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
                items: [
                  DropdownMenuItem(
                    value: 'true',
                    child: Text(l10n.ai_agent_mention_required),
                  ),
                  DropdownMenuItem(
                    value: 'false',
                    child: Text(l10n.ai_agent_mention_notRequired),
                  ),
                  DropdownMenuItem(
                    value: 'open',
                    child: Text(l10n.ai_agent_policy_open),
                  ),
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
                items: [
                  DropdownMenuItem(
                    value: 'open',
                    child: Text(l10n.ai_agent_policy_open),
                  ),
                  DropdownMenuItem(
                    value: 'allowlist',
                    child: Text(l10n.ai_agent_policy_allowlist),
                  ),
                  DropdownMenuItem(
                    value: 'disabled',
                    child: Text(l10n.ai_agent_policy_disabled),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => groupPolicy = value);
                },
              ),
              const SizedBox(height: AppTokens.s12),
              DropdownButtonFormField<String>(
                initialValue: groupSessionScope,
                decoration: InputDecoration(
                  labelText: l10n.ai_agent_group_session_scope,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'group',
                    child: Text(l10n.ai_agent_group_scope_group),
                  ),
                  DropdownMenuItem(
                    value: 'group_sender',
                    child: Text(l10n.ai_agent_group_scope_sender),
                  ),
                  DropdownMenuItem(
                    value: 'group_topic',
                    child: Text(l10n.ai_agent_group_scope_topic),
                  ),
                  DropdownMenuItem(
                    value: 'group_topic_sender',
                    child: Text(l10n.ai_agent_group_scope_topic_sender),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => groupSessionScope = value);
                },
              ),
              const SizedBox(height: AppTokens.s12),
              DropdownButtonFormField<String>(
                initialValue: connectionMode,
                decoration: InputDecoration(
                  labelText: l10n.ai_agent_connection_mode,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'websocket',
                    child: Text(l10n.ai_agent_connection_websocket),
                  ),
                  DropdownMenuItem(
                    value: 'webhook',
                    child: Text(l10n.ai_agent_connection_webhook),
                  ),
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
        'replyMode': config.replyMode,
        'streaming': streaming,
        'requireMention': requireMention,
        'groupPolicy': groupPolicy,
        'groupSessionScope': groupSessionScope,
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

  Future<void> _showAgentBatchMenu() async {
    final l10n = AppLocalizations.of(context);
    final value = await showSelectionMenu<String>(
      context,
      title: l10n.ai_agent_batch,
      options: [
        SelectionOption(
          label: l10n.ai_batch_operation,
          value: 'operate',
          icon: TablerIcons.stack_2,
        ),
        SelectionOption(
          label: l10n.ai_batch_install,
          value: 'install',
          icon: TablerIcons.download,
        ),
        SelectionOption(
          label: l10n.ai_batch_upgrade,
          value: 'upgrade',
          icon: TablerIcons.arrow_up_circle,
        ),
      ],
    );
    if (value == null || !mounted) return;
    if (value == 'install') {
      await _showAgentInstallBatch();
    } else if (value == 'upgrade') {
      await _showAgentUpgradeBatch();
    } else {
      await _showAgentBatch();
    }
  }

  Future<void> _showAgentInstallBatch() async {
    final l10n = AppLocalizations.of(context);
    var agentType = 'openclaw';
    var version = '';
    var versions = const <String>[];
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final detail = await repository.getAppDetail(agentType);
      versions = detail.versions;
      version = versions.isEmpty ? '' : versions.first;
    } catch (_) {
      versions = const [];
    }
    if (!mounted) return;
    final name = TextEditingController();
    final port = TextEditingController(text: '${_defaultAgentPort(agentType)}');
    final saved = await pushFormPage<bool>(
      context,
      StatefulBuilder(
        builder: (pageContext, setState) => SimpleFormPage(
          title: l10n.ai_batch_install,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            DropdownButtonFormField<String>(
              initialValue: agentType,
              decoration: InputDecoration(labelText: l10n.ai_agent_type),
              items: const [
                DropdownMenuItem(value: 'openclaw', child: Text('OpenClaw')),
                DropdownMenuItem(value: 'copaw', child: Text('QwenPaw')),
                DropdownMenuItem(
                  value: 'hermes-agent',
                  child: Text('Hermes Agent'),
                ),
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
                } catch (_) {}
              },
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: name, label: l10n.ai_batch_name),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: versions.contains(version) ? version : null,
              decoration: InputDecoration(labelText: l10n.ai_batch_version),
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
              label: l10n.ai_batch_port,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
    final body = <String, dynamic>{
      'name': name.text.trim(),
      'appVersion': version,
      'webUIPort': int.tryParse(port.text.trim()) ?? 0,
      'agentType': agentType,
      'taskID': const Uuid().v4(),
      'advanced': false,
      'allowPort': true,
      'pullImage': true,
    };
    name.dispose();
    port.dispose();
    if (saved != true || !mounted || version.isEmpty) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final results = await repository.batchInstallAgents(body);
      if (!mounted) return;
      final success = results.where((item) => item['success'] != false).length;
      final skipped = results.where((item) => item['skipped'] == true).length;
      AppToast.success(context, l10n.ai_batch_result(success, skipped));
      ref.invalidate(aiAgentsProvider);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showAgentUpgradeBatch() async {
    final l10n = AppLocalizations.of(context);
    var agentType = 'openclaw';
    var backup = true;
    var pullImage = true;
    var version = '';
    var versions = const <String>[];
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final detail = await repository.getAppDetail(agentType);
      versions = detail.versions;
      version = versions.isEmpty ? '' : versions.first;
    } catch (_) {
      versions = const [];
    }
    if (!mounted) return;
    final saved = await pushFormPage<bool>(
      context,
      StatefulBuilder(
        builder: (pageContext, setState) => SimpleFormPage(
          title: l10n.ai_batch_upgrade,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            DropdownButtonFormField<String>(
              initialValue: agentType,
              decoration: InputDecoration(labelText: l10n.ai_agent_type),
              items: const [
                DropdownMenuItem(value: 'openclaw', child: Text('OpenClaw')),
                DropdownMenuItem(value: 'copaw', child: Text('QwenPaw')),
                DropdownMenuItem(
                  value: 'hermes-agent',
                  child: Text('Hermes Agent'),
                ),
              ],
              onChanged: (value) async {
                if (value == null) return;
                setState(() {
                  agentType = value;
                  versions = const [];
                  version = '';
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
                } catch (_) {}
              },
            ),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: versions.contains(version) ? version : null,
              decoration: InputDecoration(labelText: l10n.ai_batch_version),
              items: [
                for (final item in versions)
                  DropdownMenuItem(value: item, child: Text(item)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => version = value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.ai_batch_backup),
              value: backup,
              onChanged: (value) => setState(() => backup = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.ai_batch_pullImage),
              value: pullImage,
              onChanged: (value) => setState(() => pullImage = value),
            ),
          ],
        ),
      ),
    );
    if (saved != true || !mounted || version.isEmpty) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final results = await repository.batchUpgradeAgents({
        'agentType': agentType,
        'targetVersion': version,
        'backup': backup,
        'pullImage': pullImage,
        'taskID': const Uuid().v4(),
      });
      if (!mounted) return;
      final success = results.where((item) => item['success'] == true).length;
      final skipped = results.where((item) => item['skipped'] == true).length;
      AppToast.success(context, l10n.ai_batch_result(success, skipped));
      ref.invalidate(aiAgentsProvider);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showAgentBatch() async {
    final l10n = AppLocalizations.of(context);
    var agentType = 'openclaw';
    var operate = 'restart';
    var forceDelete = false;
    final saved = await pushFormPage<bool>(
      context,
      StatefulBuilder(
        builder: (pageContext, setState) => SimpleFormPage(
          title: l10n.ai_agent_batch,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            DropdownButtonFormField<String>(
              initialValue: agentType,
              decoration: InputDecoration(labelText: l10n.ai_batch_type),
              items: const [
                DropdownMenuItem(value: 'openclaw', child: Text('OpenClaw')),
                DropdownMenuItem(value: 'copaw', child: Text('QwenPaw')),
                DropdownMenuItem(
                  value: 'hermes-agent',
                  child: Text('Hermes Agent'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => agentType = value);
              },
            ),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: operate,
              decoration: InputDecoration(labelText: l10n.ai_batch_operate),
              items: [
                DropdownMenuItem(
                  value: 'start',
                  child: Text(l10n.ai_batch_start),
                ),
                DropdownMenuItem(
                  value: 'stop',
                  child: Text(l10n.ai_batch_stop),
                ),
                DropdownMenuItem(
                  value: 'restart',
                  child: Text(l10n.ai_batch_restart),
                ),
                DropdownMenuItem(
                  value: 'delete',
                  child: Text(l10n.ai_batch_delete),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => operate = value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.ai_batch_force),
              value: forceDelete,
              onChanged: (value) => setState(() => forceDelete = value),
            ),
          ],
        ),
      ),
    );
    if (saved != true || !mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final results = await repository.batchOperateAgents({
        'agentType': agentType,
        'operate': operate,
        'forceDelete': forceDelete,
        'taskID': const Uuid().v4(),
      });
      if (!mounted) return;
      final success = results.where((item) => item['success'] == true).length;
      final skipped = results.where((item) => item['skipped'] == true).length;
      AppToast.success(context, l10n.ai_batch_result(success, skipped));
      ref.invalidate(aiAgentsProvider);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showAgentOverview(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final data = await repository.getAgentOverview(agent.id);
      if (!mounted) return;
      final snapshot = data['snapshot'] is Map
          ? Map<String, dynamic>.from(data['snapshot'] as Map)
          : const <String, dynamic>{};
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ai_agent_overview, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            SplitListGroup(
              children: [
                for (final entry in snapshot.entries)
                  SplitListTile(
                    leading: const Icon(TablerIcons.info_circle),
                    title: entry.key,
                    value: '${entry.value ?? ''}',
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

  Future<void> _showHermesSessions(AiAgentDto agent) async {
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final sessions = await repository.getHermesChatSessions(agent.id);
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) =>
            _HermesSessionsSheet(agentId: agent.id, initial: sessions),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showAgentPlugins(AiAgentDto agent) async {
    await showAppSheet<void>(
      context: context,
      builder: (_) => _AgentPluginsSheet(agentId: agent.id),
    );
  }

  Future<void> _showAgentSkills(AiAgentDto agent) async {
    await showAppSheet<void>(
      context: context,
      builder: (_) => _AgentSkillsSheet(agentId: agent.id),
    );
  }

  Future<void> _editAgentSecurity(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final origins = await repository.getAgentSecurity(agent.id);
      if (!mounted) return;
      final controller = TextEditingController(text: origins.join(','));
      final saved = await pushFormPage<bool>(
        context,
        Builder(
          builder: (pageContext) => SimpleFormPage(
            title: l10n.ai_agent_security,
            subtitle: agent.name,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              AppTextField(
                controller: controller,
                label: l10n.ai_agent_security_origins,
                helper: l10n.ai_agent_security_hint,
                maxLines: 3,
              ),
            ],
          ),
        ),
      );
      final items = controller.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
      controller.dispose();
      if (saved != true || !mounted) return;
      await repository.updateAgentSecurity(agent.id, items);
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editAgentConfigFile(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final content = await repository.getAgentConfigFile(agent.id);
      if (!mounted) return;
      final controller = TextEditingController(text: content);
      final saved = await pushFormPage<bool>(
        context,
        Builder(
          builder: (pageContext) => SimpleFormPage(
            title: l10n.ai_agent_config_file,
            subtitle: agent.name,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              AppTextField(
                controller: controller,
                label: l10n.ai_agent_config_file,
                helper: l10n.ai_agent_config_file_hint,
                maxLines: 16,
              ),
            ],
          ),
        ),
      );
      final value = controller.text;
      controller.dispose();
      if (saved != true || !mounted) return;
      await repository.updateAgentConfigFile(agent.id, value);
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editAgentOtherConfig(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final config = await repository.getAgentOtherConfig(agent.id);
      if (!mounted) return;
      final timezone = TextEditingController(
        text: '${config['userTimezone'] ?? ''}',
      );
      final npm = TextEditingController(text: '${config['npmRegistry'] ?? ''}');
      final username = TextEditingController(
        text: '${config['dashboardUsername'] ?? ''}',
      );
      final password = TextEditingController(
        text: '${config['dashboardPassword'] ?? ''}',
      );
      var browser = config['browserEnabled'] == true;
      final saved = await pushFormPage<bool>(
        context,
        StatefulBuilder(
          builder: (pageContext, setState) => SimpleFormPage(
            title: l10n.ai_agent_otherConfig,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              AppTextField(
                controller: timezone,
                label: l10n.ai_agent_otherTimezone,
                hint: 'Asia/Shanghai',
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: npm,
                label: l10n.ai_agent_otherNpm,
                hint: 'https://registry.npmjs.org',
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: username,
                label: l10n.ai_agent_otherUsername,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: password,
                label: l10n.ai_agent_otherPassword,
                obscure: true,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.ai_agent_otherBrowser),
                value: browser,
                onChanged: (value) => setState(() => browser = value),
              ),
            ],
          ),
        ),
      );
      final body = <String, dynamic>{
        'agentId': agent.id,
        'userTimezone': timezone.text.trim(),
        'browserEnabled': browser,
        'npmRegistry': npm.text.trim(),
        'dashboardUsername': username.text.trim(),
        'dashboardPassword': password.text,
      };
      timezone.dispose();
      npm.dispose();
      username.dispose();
      password.dispose();
      if (saved != true || !mounted) return;
      await repository.updateAgentOtherConfig(body);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _batchInstallSkill(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController();
    final path = TextEditingController();
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.ai_agent_batchSkill,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(controller: name, label: l10n.ai_agent_skillName),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: path,
              label: l10n.ai_agent_skillPackage,
              hint: '/opt/skills/example.zip',
            ),
          ],
        ),
      ),
    );
    final skillName = name.text.trim();
    final packagePath = path.text.trim();
    name.dispose();
    path.dispose();
    if (saved != true || !mounted) return;
    if (skillName.isEmpty || packagePath.isEmpty) {
      AppToast.warning(context, l10n.apps_required);
      return;
    }
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final result = await repository.batchInstallAgentSkill({
        'agentType': agent.agentType,
        'skillName': skillName,
        'packagePath': packagePath,
        'taskID': const Uuid().v4(),
      });
      if (!mounted) return;
      final failed = result.where((item) => item['success'] != true).length;
      if (failed > 0) {
        AppToast.warning(context, '$failed / ${result.length}');
      } else {
        AppToast.success(context, l10n.action_done);
      }
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _switchFeishuPlugin(AiAgentDto agent) async {
    final l10n = AppLocalizations.of(context);
    var streaming = true;
    var scope = 'group';
    var mention = 'true';
    final saved = await pushFormPage<bool>(
      context,
      StatefulBuilder(
        builder: (pageContext, setState) => SimpleFormPage(
          title: l10n.ai_agent_feishuSwitch,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.ai_agent_streaming),
              value: streaming,
              onChanged: (value) => setState(() => streaming = value),
            ),
            DropdownButtonFormField<String>(
              initialValue: scope,
              decoration: InputDecoration(labelText: l10n.ai_agent_groupScope),
              items: [
                for (final scopeValue in const [
                  'group',
                  'group_sender',
                  'group_topic',
                  'group_topic_sender',
                ])
                  DropdownMenuItem(value: scopeValue, child: Text(scopeValue)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => scope = value);
              },
            ),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: mention,
              decoration: InputDecoration(
                labelText: l10n.ai_agent_requireMention,
              ),
              items: const [
                DropdownMenuItem(value: 'true', child: Text('true')),
                DropdownMenuItem(value: 'false', child: Text('false')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => mention = value);
              },
            ),
          ],
        ),
      ),
    );
    if (saved != true || !mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      await repository.switchAgentFeishuPlugin({
        'agentId': agent.id,
        'taskID': const Uuid().v4(),
        'streaming': streaming,
        'groupSessionScope': scope,
        'requireMention': mention,
      });
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editRoleMarkdown(AiAgentDto agent, AiAgentRoleDto role) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final files = await repository.listAgentRoleMarkdownFiles(
        agentId: agent.id,
        workspace: role.workspace,
      );
      if (!mounted) return;
      if (files.isEmpty) {
        AppToast.warning(context, l10n.ai_agent_markdownEmpty);
        return;
      }
      final selected = await showSelectionMenu<Map<String, dynamic>>(
        context,
        title: l10n.ai_agent_markdown,
        options: [
          for (final file in files)
            SelectionOption(
              label: '${file['name'] ?? ''}',
              value: file,
              icon: TablerIcons.file_text,
            ),
        ],
      );
      if (selected == null || !mounted) return;
      final controller = TextEditingController(
        text: '${selected['content'] ?? ''}',
      );
      final saved = await pushFormPage<bool>(
        context,
        Builder(
          builder: (pageContext) => SimpleFormPage(
            title: '${selected['name'] ?? ''}',
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              AppTextField(
                controller: controller,
                label: l10n.ai_agent_markdownContent,
                maxLines: 20,
              ),
            ],
          ),
        ),
      );
      final content = controller.text;
      controller.dispose();
      if (saved != true || !mounted) return;
      await repository.updateAgentRoleMarkdownFile(
        agentId: agent.id,
        workspace: role.workspace,
        name: '${selected['name'] ?? ''}',
        content: content,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _confirmDeleteAgent(
    AiAgentDto agent,
    AiRepository repository,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final resources = await repository.checkAgentDelete(agent.id);
      if (!mounted) return;
      if (resources.isNotEmpty) {
        await showAppSheet<void>(
          context: context,
          builder: (sheetContext) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.ai_agent_deleteResources, style: AppTextStyles.titleL),
              const SizedBox(height: AppTokens.s12),
              for (final resource in resources)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${resource['name'] ?? ''}'),
                  subtitle: Text('${resource['type'] ?? ''}'),
                ),
            ],
          ),
        );
        if (!mounted) return;
      }
      final confirmed = await showConfirmSheet(
        context,
        title: l10n.action_delete,
        message: l10n.ai_agent_delete_confirm(agent.name),
        confirmLabel: l10n.action_delete,
        requireText: agent.name,
      );
      if (!confirmed || !mounted) return;
      await repository.deleteAgent(agent.id);
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
          label: l10n.ai_channel_plugins,
          value: 'channel_plugins',
          icon: TablerIcons.puzzle,
        ),
        SelectionOption(
          label: l10n.ai_channel_pairing,
          value: 'pairing',
          icon: TablerIcons.qrcode,
        ),
        SelectionOption(
          label: l10n.ai_agent_overview,
          value: 'overview',
          icon: TablerIcons.dashboard,
        ),
        if (agent.agentType == 'hermes-agent')
          SelectionOption(
            label: l10n.ai_agent_sessions,
            value: 'sessions',
            icon: TablerIcons.messages,
          ),
        SelectionOption(
          label: l10n.ai_agent_security,
          value: 'security',
          icon: TablerIcons.shield_lock,
        ),
        SelectionOption(
          label: l10n.ai_agent_config_file,
          value: 'config_file',
          icon: TablerIcons.file_code,
        ),
        SelectionOption(
          label: l10n.ai_agent_plugins,
          value: 'plugins',
          icon: TablerIcons.puzzle,
        ),
        SelectionOption(
          label: l10n.ai_agent_skills,
          value: 'skills',
          icon: TablerIcons.sparkles,
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
          label: l10n.ai_agent_otherConfig,
          value: 'other',
          icon: TablerIcons.settings,
        ),
        if (const {'openclaw', 'hermes-agent'}.contains(agent.agentType))
          SelectionOption(
            label: l10n.ai_agent_batchSkill,
            value: 'batch_skill',
            icon: TablerIcons.sparkles,
          ),
        if (agent.agentType == 'openclaw')
          SelectionOption(
            label: l10n.ai_agent_feishuSwitch,
            value: 'feishu_switch',
            icon: TablerIcons.switch_horizontal,
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
      } else if (value == 'channel_plugins') {
        await _showChannelPlugins(agent);
        return;
      } else if (value == 'pairing') {
        await _approvePairing(agent);
        return;
      } else if (value == 'overview') {
        await _showAgentOverview(agent);
        return;
      } else if (value == 'sessions') {
        await _showHermesSessions(agent);
        return;
      } else if (value == 'security') {
        await _editAgentSecurity(agent);
        return;
      } else if (value == 'config_file') {
        await _editAgentConfigFile(agent);
        return;
      } else if (value == 'plugins') {
        await _showAgentPlugins(agent);
        return;
      } else if (value == 'skills') {
        await _showAgentSkills(agent);
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
      } else if (value == 'other') {
        await _editAgentOtherConfig(agent);
        return;
      } else if (value == 'batch_skill') {
        await _batchInstallSkill(agent);
        return;
      } else if (value == 'feishu_switch') {
        await _switchFeishuPlugin(agent);
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
        await _confirmDeleteAgent(agent, repository);
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

class _AgentPluginsSheet extends ConsumerStatefulWidget {
  const _AgentPluginsSheet({required this.agentId});

  final int agentId;

  @override
  ConsumerState<_AgentPluginsSheet> createState() => _AgentPluginsSheetState();
}

class _AgentPluginsSheetState extends ConsumerState<_AgentPluginsSheet> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> _installed = const [];
  List<Map<String, dynamic>> _results = const [];
  bool _loading = true;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final items = await repository.listAgentPlugins(widget.agentId);
      if (!mounted) return;
      setState(() {
        _installed = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      showErrorToast(context, error);
    }
  }

  Future<void> _runSearch() async {
    final keyword = _search.text.trim();
    if (keyword.isEmpty) return;
    setState(() => _searching = true);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final items = await repository.searchAgentPlugins(
        agentId: widget.agentId,
        keyword: keyword,
      );
      if (!mounted) return;
      setState(() => _results = items);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _install(Map<String, dynamic> item) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      await repository.installAgentMarketPlugin(
        agentId: widget.agentId,
        package: '${item['package'] ?? ''}',
        version: '${item['version'] ?? ''}',
        taskID: const Uuid().v4(),
      );
      await _load();
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _toggle(Map<String, dynamic> item, bool enabled) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      await repository.operateAgentPlugin(
        agentId: widget.agentId,
        pluginId: '${item['id'] ?? ''}',
        operate: enabled ? 'enable' : 'disable',
        taskID: const Uuid().v4(),
      );
      await _load();
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ai_agent_plugins, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _search,
          hint: l10n.ai_plugin_searchHint,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _runSearch(),
          suffix: IconButton(
            icon: const Icon(TablerIcons.search),
            onPressed: _searching ? null : _runSearch,
          ),
        ),
        const SizedBox(height: AppTokens.s16),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              SectionHeader(title: l10n.ai_plugin_installed),
              if (_loading)
                const SkeletonList(itemCount: 2)
              else if (_installed.isEmpty)
                EmptyState(
                  icon: TablerIcons.puzzle,
                  title: l10n.ai_plugin_empty,
                  compact: true,
                )
              else
                SplitListGroup(
                  children: [
                    for (final item in _installed)
                      SplitListTile(
                        leading: const Icon(TablerIcons.puzzle),
                        title: '${item['name'] ?? item['id'] ?? ''}',
                        subtitle:
                            '${l10n.ai_plugin_version} ${item['version'] ?? ''}',
                        trailing: Switch(
                          value: item['enabled'] == true,
                          onChanged: (value) => _toggle(item, value),
                        ),
                      ),
                  ],
                ),
              if (_results.isNotEmpty) ...[
                const SizedBox(height: AppTokens.s16),
                SectionHeader(title: l10n.ai_plugin_market),
                SplitListGroup(
                  children: [
                    for (final item in _results)
                      SplitListTile(
                        leading: const Icon(TablerIcons.cloud_download),
                        title: '${item['name'] ?? item['pluginId'] ?? ''}',
                        subtitle: [
                          '${item['description'] ?? ''}',
                          if ('${item['version'] ?? ''}'.isNotEmpty)
                            '${l10n.ai_plugin_version} ${item['version']}',
                        ].where((value) => value.isNotEmpty).join(' · '),
                        trailing: TextButton(
                          onPressed: () => _install(item),
                          child: Text(l10n.ai_plugin_install),
                        ),
                      ),
                  ],
                ),
              ] else if (_search.text.trim().isNotEmpty && !_searching)
                EmptyState(
                  icon: TablerIcons.search_off,
                  title: l10n.ai_plugin_noResults,
                  compact: true,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AgentSkillsSheet extends ConsumerStatefulWidget {
  const _AgentSkillsSheet({required this.agentId});

  final int agentId;

  @override
  ConsumerState<_AgentSkillsSheet> createState() => _AgentSkillsSheetState();
}

class _AgentSkillsSheetState extends ConsumerState<_AgentSkillsSheet> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> _installed = const [];
  List<Map<String, dynamic>> _results = const [];
  String _source = 'official';
  bool _loading = true;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final items = await repository.listAgentSkills(widget.agentId);
      if (!mounted) return;
      setState(() {
        _installed = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      showErrorToast(context, error);
    }
  }

  Future<void> _runSearch() async {
    final keyword = _search.text.trim();
    if (keyword.isEmpty) return;
    setState(() => _searching = true);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final items = await repository.searchAgentSkills(
        agentId: widget.agentId,
        source: _source,
        keyword: keyword,
      );
      if (!mounted) return;
      setState(() => _results = items);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _install(Map<String, dynamic> item) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      await repository.installAgentSkill(
        agentId: widget.agentId,
        source: '${item['source'] ?? _source}',
        slug: '${item['slug'] ?? item['identifier'] ?? ''}',
        taskID: const Uuid().v4(),
      );
      await _load();
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _toggle(Map<String, dynamic> item, bool enabled) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      await repository.updateAgentSkill(
        agentId: widget.agentId,
        name: '${item['name'] ?? ''}',
        enabled: enabled,
      );
      await _load();
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _uninstall(Map<String, dynamic> item) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.ai_skill_uninstall,
      message: '${item['name'] ?? ''}',
      confirmLabel: l10n.action_delete,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      await repository.uninstallAgentSkill(
        agentId: widget.agentId,
        name: '${item['name'] ?? ''}',
      );
      await _load();
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ai_agent_skills, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s12),
        DropdownButtonFormField<String>(
          initialValue: _source,
          decoration: InputDecoration(labelText: l10n.ai_skill_source),
          items: [
            DropdownMenuItem(
              value: 'official',
              child: Text(l10n.ai_skill_sourceOfficial),
            ),
            DropdownMenuItem(
              value: 'clawhub-global',
              child: Text(l10n.ai_skill_sourceClawhubGlobal),
            ),
            DropdownMenuItem(
              value: 'clawhub-cn',
              child: Text(l10n.ai_skill_sourceClawhubCn),
            ),
            DropdownMenuItem(
              value: 'skillhub',
              child: Text(l10n.ai_skill_sourceSkillhub),
            ),
            DropdownMenuItem(
              value: 'skills-sh',
              child: Text(l10n.ai_skill_sourceSkillsSh),
            ),
            DropdownMenuItem(
              value: 'local-hub',
              child: Text(l10n.ai_skill_sourceLocalHub),
            ),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _source = value);
          },
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _search,
          hint: l10n.ai_skill_searchHint,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _runSearch(),
          suffix: IconButton(
            icon: const Icon(TablerIcons.search),
            onPressed: _searching ? null : _runSearch,
          ),
        ),
        const SizedBox(height: AppTokens.s16),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              SectionHeader(title: l10n.ai_skill_installed),
              if (_loading)
                const SkeletonList(itemCount: 2)
              else if (_installed.isEmpty)
                EmptyState(
                  icon: TablerIcons.sparkles,
                  title: l10n.ai_skill_empty,
                  compact: true,
                )
              else
                SplitListGroup(
                  children: [
                    for (final item in _installed)
                      SplitListTile(
                        leading: const Icon(TablerIcons.sparkles),
                        title: '${item['name'] ?? ''}',
                        subtitle: '${item['description'] ?? ''}',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: item['disabled'] != true,
                              onChanged: (value) => _toggle(item, value),
                            ),
                            if (item['uninstallable'] == true)
                              IconButton(
                                tooltip: l10n.ai_skill_uninstall,
                                icon: const Icon(TablerIcons.trash),
                                onPressed: () => _uninstall(item),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              if (_results.isNotEmpty) ...[
                const SizedBox(height: AppTokens.s16),
                SectionHeader(title: l10n.ai_skill_market),
                SplitListGroup(
                  children: [
                    for (final item in _results)
                      SplitListTile(
                        leading: const Icon(TablerIcons.cloud_download),
                        title: '${item['name'] ?? item['slug'] ?? ''}',
                        subtitle: [
                          '${item['description'] ?? item['summary'] ?? ''}',
                          '${item['source'] ?? ''}',
                        ].where((value) => value.isNotEmpty).join(' · '),
                        trailing: TextButton(
                          onPressed: () => _install(item),
                          child: Text(l10n.ai_skill_install),
                        ),
                      ),
                  ],
                ),
              ] else if (_search.text.trim().isNotEmpty && !_searching)
                EmptyState(
                  icon: TablerIcons.search_off,
                  title: l10n.ai_skill_noResults,
                  compact: true,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HermesSessionsSheet extends ConsumerStatefulWidget {
  const _HermesSessionsSheet({required this.agentId, required this.initial});

  final int agentId;
  final List<Map<String, dynamic>> initial;

  @override
  ConsumerState<_HermesSessionsSheet> createState() =>
      _HermesSessionsSheetState();
}

class _HermesSessionsSheetState extends ConsumerState<_HermesSessionsSheet> {
  late List<Map<String, dynamic>> _sessions = widget.initial;

  Future<void> _refresh() async {
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final sessions = await repository.getHermesChatSessions(widget.agentId);
      if (!mounted) return;
      setState(() => _sessions = sessions);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _rename(Map<String, dynamic> session) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: '${session['title'] ?? ''}');
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.ai_session_rename,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(controller: controller, label: l10n.ai_session_rename),
          ],
        ),
      ),
    );
    final title = controller.text.trim();
    controller.dispose();
    if (saved != true || title.isEmpty || !mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      await repository.renameHermesChatSession(
        agentId: widget.agentId,
        id: '${session['id'] ?? ''}',
        title: title,
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(Map<String, dynamic> session) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.ai_session_delete,
      message: '${session['title'] ?? ''}',
      confirmLabel: l10n.action_delete,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      await repository.deleteHermesChatSession(
        agentId: widget.agentId,
        id: '${session['id'] ?? ''}',
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ai_agent_sessions, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s16),
        if (_sessions.isEmpty)
          EmptyState(
            icon: TablerIcons.messages,
            title: l10n.ai_skill_empty,
            compact: true,
          )
        else
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final session in _sessions)
                  SplitListTile(
                    leading: const Icon(TablerIcons.message),
                    title: '${session['title'] ?? session['id'] ?? ''}',
                    subtitle: [
                      '${session['model'] ?? ''}',
                      '${session['messageCount'] ?? 0}',
                      '${session['lastActive'] ?? ''}',
                    ].where((value) => value.isNotEmpty).join(' · '),
                    onTap: () => _rename(session),
                    trailing: IconButton(
                      tooltip: l10n.ai_session_delete,
                      icon: const Icon(TablerIcons.trash),
                      onPressed: () => _delete(session),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
