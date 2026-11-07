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
}
