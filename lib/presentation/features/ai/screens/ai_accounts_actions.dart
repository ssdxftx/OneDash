part of 'ai_page.dart';

mixin _AiAccountsActions on ConsumerState<AiPage> {
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

  Future<bool> _editAccountModel(
    AiAccountDto account, {
    Map<String, dynamic>? model,
  }) async {
    final l10n = AppLocalizations.of(context);
    final idController = TextEditingController(text: '${model?['id'] ?? ''}');
    final nameController = TextEditingController(
      text: '${model?['name'] ?? ''}',
    );
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: model == null ? l10n.ai_model_add : l10n.action_edit,
          saveLabel: l10n.action_save,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(controller: idController, label: l10n.ai_model_id),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: nameController, label: l10n.ai_model_name),
          ],
        ),
      ),
    );
    final id = idController.text.trim();
    final name = nameController.text.trim();
    idController.dispose();
    nameController.dispose();
    if (saved != true || id.isEmpty || !mounted) return false;
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      if (model == null) {
        await repository.createAccountModel(
          accountId: account.id,
          id: id,
          name: name.isEmpty ? id : name,
        );
      } else {
        await repository.updateAccountModel(
          accountId: account.id,
          id: id,
          name: name.isEmpty ? id : name,
        );
      }
      return true;
    } catch (error) {
      if (!mounted) return false;
      showErrorToast(context, error);
      return false;
    }
  }

  Future<void> _manageModels(AiAccountDto account) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      var models = await repository.getAccountModels(account.id);
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.9,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> reload() async {
              final next = await repository.getAccountModels(account.id);
              if (sheetContext.mounted) {
                setSheetState(() => models = next);
              }
            }

            Future<void> add() async {
              if (await _editAccountModel(account)) {
                await reload();
              }
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.ai_account_models,
                        style: AppTextStyles.titleL,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: add,
                      icon: const Icon(TablerIcons.plus, size: 18),
                      label: Text(l10n.ai_model_add),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s8),
                if (models.isEmpty)
                  Text(l10n.state_empty, style: AppTextStyles.bodyM)
                else
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final model in models)
                          ListTile(
                            onTap: () async {
                              if (await _editAccountModel(
                                account,
                                model: model,
                              )) {
                                await reload();
                              }
                            },
                            leading: Icon(
                              model['isVerifyModel'] == true
                                  ? TablerIcons.shield_check
                                  : TablerIcons.cube,
                            ),
                            title: Text('${model['name'] ?? ''}'),
                            subtitle: Text('${model['id'] ?? ''}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: l10n.ai_model_verify,
                                  icon: const Icon(TablerIcons.shield_check),
                                  onPressed: () async {
                                    final recordId = (model['recordId'] as num?)
                                        ?.toInt();
                                    if (recordId == null) return;
                                    try {
                                      await repository.setAccountVerifyModel(
                                        accountId: account.id,
                                        recordId: recordId,
                                      );
                                      await reload();
                                    } catch (error) {
                                      if (!sheetContext.mounted) return;
                                      showErrorToast(sheetContext, error);
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: l10n.action_delete,
                                  icon: Icon(
                                    TablerIcons.trash,
                                    color: sheetContext.appColors.danger,
                                  ),
                                  onPressed: () async {
                                    final recordId = (model['recordId'] as num?)
                                        ?.toInt();
                                    if (recordId == null) return;
                                    try {
                                      await repository.deleteAccountModel(
                                        accountId: account.id,
                                        recordId: recordId,
                                      );
                                      await reload();
                                    } catch (error) {
                                      if (!sheetContext.mounted) return;
                                      showErrorToast(sheetContext, error);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      );
      ref.invalidate(aiAccountsProvider);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _discoverModels(AiAccountDto account) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final models = await repository.discoverAgentAccountModels(
        provider: account.provider,
        baseURL: account.baseUrl,
        apiKey: account.apiKey,
        apiType: account.apiType,
      );
      if (!mounted) return;
      if (models.isEmpty) {
        AppToast.warning(context, l10n.ai_account_discover_empty);
        return;
      }
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.9,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.ai_account_discover_result('${models.length}'),
              style: AppTextStyles.titleM,
            ),
            const SizedBox(height: AppTokens.s8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final model in models)
                    ListTile(
                      dense: true,
                      leading: const Icon(TablerIcons.cube),
                      title: Text('${model['name'] ?? model['id'] ?? ''}'),
                      subtitle: '${model['id'] ?? ''}'.isEmpty
                          ? null
                          : Text('${model['id']}'),
                    ),
                ],
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
          label: l10n.ai_account_models,
          value: 'models',
          icon: TablerIcons.list,
        ),
        SelectionOption(
          label: l10n.ai_account_discover,
          value: 'discover',
          icon: TablerIcons.search,
        ),
        SelectionOption(
          label: l10n.ai_account_verify,
          value: 'verify',
          icon: TablerIcons.shield_check,
        ),
        SelectionOption(
          label: l10n.ai_chat_title,
          value: 'chat',
          icon: TablerIcons.message_chatbot,
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
    if (value == 'chat') {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              AiChatPage(accountId: account.id, accountName: account.name),
        ),
      );
      return;
    }
    if (value == 'edit') {
      await _editAccount(account);
      return;
    }
    if (value == 'models') {
      await _manageModels(account);
      return;
    }
    if (value == 'discover') {
      await _discoverModels(account);
      return;
    }
    if (value == 'verify') {
      try {
        final repository = await ref.read(aiRepositoryProvider.future);
        await repository.verifyAccount(id: account.id);
        if (!mounted) return;
        AppToast.success(context, l10n.action_done);
        ref.invalidate(aiAccountsProvider);
      } catch (error) {
        if (!mounted) return;
        showErrorToast(context, error);
      }
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
}
