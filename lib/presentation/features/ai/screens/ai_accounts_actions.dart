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
}
