part of 'ai_page.dart';

mixin _AiModelsActions on ConsumerState<AiPage> {
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

  Future<void> _editAiDomain() async {
    final l10n = AppLocalizations.of(context);
    try {
      final appRepository = await ref.read(appRepositoryProvider.future);
      final installed = await appRepository.searchInstalledApps(
        const AppInstalledSearchReq(page: 1, pageSize: 50, name: 'ollama'),
      );
      final app = installed.items.isEmpty ? null : installed.items.first;
      if (app == null) {
        if (!mounted) return;
        AppToast.warning(context, l10n.ai_domain_noApp);
        return;
      }
      final repository = await ref.read(aiRepositoryProvider.future);
      final data = await repository.getAiDomain(app.id);
      if (!mounted) return;
      final domain = TextEditingController(text: '${data['domain'] ?? ''}');
      final ssl = TextEditingController(text: '${data['sslID'] ?? 0}');
      final website = TextEditingController(text: '${data['websiteID'] ?? 0}');
      final ipList = switch (data['allowIPs']) {
        final List items => items.join(','),
        _ => '',
      };
      final ips = TextEditingController(text: ipList);
      final saved = await pushFormPage<bool>(
        context,
        Builder(
          builder: (pageContext) => SimpleFormPage(
            title: l10n.ai_domain,
            subtitle: app.displayName,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              AppTextField(controller: domain, label: l10n.ai_domain_name),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: ssl,
                label: l10n.ai_domain_ssl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: website,
                label: l10n.ai_domain_website,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: ips,
                label: l10n.ai_domain_ipList,
                helper: l10n.ai_domain_hint,
              ),
            ],
          ),
        ),
      );
      final body = <String, dynamic>{
        'domain': domain.text.trim(),
        'appInstallID': app.id,
        'sslID': int.tryParse(ssl.text.trim()) ?? 0,
        'websiteID': int.tryParse(website.text.trim()) ?? 0,
        'ipList': ips.text.trim(),
      };
      final isEmpty = domain.text.trim().isEmpty;
      domain.dispose();
      ssl.dispose();
      website.dispose();
      ips.dispose();
      if (saved != true || !mounted || isEmpty) return;
      final existing = '${data['domain'] ?? ''}'.trim();
      if (existing.isEmpty) {
        await repository.bindAiDomain(body);
      } else {
        await repository.updateAiDomain(body);
      }
      if (!mounted) return;
      AppToast.success(context, l10n.ai_domain_saved);
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
          label: l10n.ai_model_syncAccount,
          value: 'sync',
          icon: TablerIcons.refresh,
        ),
        SelectionOption(
          label: l10n.ai_model_recreate,
          value: 'recreate',
          icon: TablerIcons.repeat,
        ),
        SelectionOption(
          label: l10n.ai_domain,
          value: 'domain',
          icon: TablerIcons.world,
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
      } else if (value == 'domain') {
        await _editAiDomain();
        return;
      } else if (value == 'sync') {
        var baseUrlType = 'localhost';
        final baseUrl = TextEditingController();
        final saved = await pushFormPage<bool>(
          context,
          StatefulBuilder(
            builder: (pageContext, setState) => SimpleFormPage(
              title: l10n.ai_model_syncAccount,
              subtitle: model.name,
              onSave: () async => Navigator.of(pageContext).pop(true),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: baseUrlType,
                  decoration: InputDecoration(
                    labelText: l10n.ai_model_baseUrlType,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'container',
                      child: Text(l10n.ai_model_baseUrlContainer),
                    ),
                    DropdownMenuItem(
                      value: 'localhost',
                      child: Text(l10n.ai_model_baseUrlLocalhost),
                    ),
                    DropdownMenuItem(
                      value: 'systemIP',
                      child: Text(l10n.ai_model_baseUrlSystemIp),
                    ),
                    DropdownMenuItem(
                      value: 'custom',
                      child: Text(l10n.ai_model_baseUrlCustom),
                    ),
                  ],
                  onChanged: (next) {
                    if (next != null) setState(() => baseUrlType = next);
                  },
                ),
                const SizedBox(height: AppTokens.s12),
                AppTextField(controller: baseUrl, label: l10n.ai_model_baseUrl),
              ],
            ),
          ),
        );
        final url = baseUrl.text.trim();
        baseUrl.dispose();
        if (saved != true) return;
        await repository.syncOllamaAccount(
          id: model.id,
          baseUrlType: baseUrlType,
          baseUrl: url,
        );
      } else if (value == 'recreate') {
        await repository.recreateOllamaModel(model.name);
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
}
