import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/website/website_template_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../../../common/formatters/value_labels.dart';

class WebsiteTemplatesPage extends ConsumerStatefulWidget {
  const WebsiteTemplatesPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<WebsiteTemplatesPage> createState() =>
      _WebsiteTemplatesPageState();
}

class _WebsiteTemplatesPageState extends ConsumerState<WebsiteTemplatesPage> {
  List<WebsiteTemplateDto> _templates = const [];
  bool _loading = true;
  String _type = '';

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final result = await repository.searchTemplates(type: _type);
      if (!mounted) return;
      setState(() => _templates = result.items);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openEditor([WebsiteTemplateDto? template]) async {
    if (template != null) {
      try {
        final repository = await ref.read(websiteRepositoryProvider.future);
        template = await repository.getTemplate(template.id);
      } catch (error) {
        if (!mounted) return;
        showErrorToast(context, error);
        return;
      }
      if (!mounted) return;
    }
    await showAppSheet<bool>(
      context: context,
      maxHeightFactor: 0.95,
      builder: (sheetContext) => _TemplateEditorSheet(template: template),
    );
    unawaited(_load());
  }

  Future<void> _delete(WebsiteTemplateDto template) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.websites_templateDelete,
      message: template.name,
      confirmLabel: l10n.action_delete,
      requireText: template.name,
    );
    if (!confirmed) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.deleteTemplate(template.id);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _generate(WebsiteTemplateDto template) async {
    await showAppSheet<bool>(
      context: context,
      maxHeightFactor: 0.95,
      builder: (sheetContext) => _TemplateOutputSheet(template: template),
    );
  }

  Future<void> _showOutputs() async {
    await showAppSheet<void>(
      context: context,
      maxHeightFactor: 0.95,
      builder: (sheetContext) => const _TemplateOutputsSheet(),
    );
  }

  String _typeLabel(AppLocalizations l10n, String type) {
    return type == 'multi'
        ? l10n.websites_templateMulti
        : l10n.websites_templateSingle;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.websites_templates,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _load,
          ),
          AppIconButton(
            icon: TablerIcons.folder,
            tooltip: l10n.websites_templateOutputs,
            onPressed: _showOutputs,
          ),
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.websites_templateAdd,
            onPressed: _openEditor,
          ),
        ],
      ),
      body: Column(
        children: [
          AppFilterChips<String>(
            options: const ['', 'single', 'multi'],
            labelOf: (value) => switch (value) {
              'single' => l10n.websites_templateSingle,
              'multi' => l10n.websites_templateMulti,
              _ => l10n.websites_all,
            },
            selected: {_type},
            onChanged: (selection) {
              if (selection.isEmpty) return;
              setState(() => _type = selection.first);
              unawaited(_load());
            },
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _templates.isEmpty
                ? EmptyState(
                    icon: TablerIcons.layout,
                    title: l10n.websites_templatesEmptyTitle,
                    message: l10n.websites_templateEmpty,
                    actionLabel: l10n.websites_templateAdd,
                    onAction: _openEditor,
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.all(AppTokens.pagePadding),
                      children: [
                        for (final template in _templates)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppTokens.s12,
                            ),
                            child: TonalCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          template.name,
                                          style: AppTextStyles.titleS,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppTokens.s8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: context
                                              .scheme
                                              .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            AppTokens.rFull,
                                          ),
                                        ),
                                        child: Text(
                                          _typeLabel(l10n, template.type),
                                          style: AppTextStyles.caption.copyWith(
                                            color:
                                                context.scheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        tooltip: l10n.action_more,
                                        icon: Icon(
                                          TablerIcons.dots_vertical,
                                          color:
                                              context.scheme.onSurfaceVariant,
                                        ),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _openEditor(template);
                                          } else if (value == 'delete') {
                                            _delete(template);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Text(l10n.action_edit),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text(
                                              l10n.websites_templateDelete,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (template.remark.isNotEmpty) ...[
                                    const SizedBox(height: AppTokens.s4),
                                    Text(
                                      template.remark,
                                      style: AppTextStyles.bodyS,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: AppTokens.s8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          l10n.websites_templateVariableCount(
                                            template.parsedVariables.length,
                                          ),
                                          style: AppTextStyles.bodyS.copyWith(
                                            color:
                                                context.scheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          textStyle: AppTextStyles.label,
                                        ),
                                        onPressed: () => _generate(template),
                                        icon: const Icon(
                                          TablerIcons.file_plus,
                                          size: AppTokens.iconList,
                                        ),
                                        label: Text(
                                          l10n.websites_templateGenerate,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _VariableDraft {
  _VariableDraft({WebsiteTemplateVariableDto? source})
    : key = TextEditingController(text: source?.key ?? ''),
      label = TextEditingController(text: source?.label ?? ''),
      defaultValue = TextEditingController(text: source?.defaultValue ?? ''),
      options = TextEditingController(text: source?.options ?? ''),
      type = source?.type ?? 'text',
      required = source?.required ?? false;

  final TextEditingController key;
  final TextEditingController label;
  final TextEditingController defaultValue;
  final TextEditingController options;
  String type;
  bool required;

  WebsiteTemplateVariableDto toDto() {
    return WebsiteTemplateVariableDto(
      key: key.text.trim(),
      label: label.text.trim(),
      type: type,
      defaultValue: defaultValue.text,
      options: options.text.trim(),
      required: required,
    );
  }

  void dispose() {
    key.dispose();
    label.dispose();
    defaultValue.dispose();
    options.dispose();
  }
}

class _TemplateEditorSheet extends ConsumerStatefulWidget {
  const _TemplateEditorSheet({this.template});

  final WebsiteTemplateDto? template;

  @override
  ConsumerState<_TemplateEditorSheet> createState() =>
      _TemplateEditorSheetState();
}

class _TemplateEditorSheetState extends ConsumerState<_TemplateEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _content;
  late final TextEditingController _remark;
  late String _type;
  late String _filePath;
  late List<_VariableDraft> _variables;
  bool _saving = false;
  bool _uploading = false;

  bool get _isEdit => widget.template != null;

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    _name = TextEditingController(text: template?.name ?? '');
    _content = TextEditingController(text: template?.content ?? '');
    _remark = TextEditingController(text: template?.remark ?? '');
    _type = template?.type ?? 'single';
    _filePath = template?.filePath ?? '';
    _variables = [
      for (final variable
          in template?.parsedVariables ?? const <WebsiteTemplateVariableDto>[])
        _VariableDraft(source: variable),
    ];
  }

  @override
  void dispose() {
    _name.dispose();
    _content.dispose();
    _remark.dispose();
    for (final variable in _variables) {
      variable.dispose();
    }
    super.dispose();
  }

  void _detectVariables() {
    final keys = <String>[];
    for (final match in RegExp(r'\{\{(\w+)\}\}').allMatches(_content.text)) {
      final key = match.group(1);
      if (key != null && !keys.contains(key)) keys.add(key);
    }
    setState(() {
      for (final key in keys) {
        if (_variables.any((variable) => variable.key.text.trim() == key)) {
          continue;
        }
        _variables.add(_VariableDraft()..key.text = key);
      }
    });
  }

  Future<void> _upload() async {
    final l10n = AppLocalizations.of(context);
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      withData: true,
    );
    final file = picked?.files.singleOrNull;
    if (!mounted || file == null || file.bytes == null) return;
    setState(() => _uploading = true);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final data = await repository.uploadTemplateZip(
        fileName: file.name,
        bytes: file.bytes!,
      );
      final path = '${data['filePath'] ?? ''}';
      final variables = data['variables'];
      setState(() {
        _filePath = path;
        if (variables is List) {
          for (final raw in variables) {
            final key = '$raw';
            if (key.isEmpty ||
                _variables.any((variable) => variable.key.text.trim() == key)) {
              continue;
            }
            _variables.add(_VariableDraft()..key.text = key);
          }
        }
      });
      if (!mounted) return;
      AppToast.success(context, l10n.websites_templateUploaded);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) return;
    if (_type == 'multi' && _filePath.isEmpty) return;
    setState(() => _saving = true);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final req = WebsiteTemplateReq(
        id: widget.template?.id,
        name: name,
        type: _type,
        content: _type == 'single' ? _content.text : '',
        filePath: _filePath,
        variables: [
          for (final variable in _variables)
            if (variable.key.text.trim().isNotEmpty) variable.toDto(),
        ],
        remark: _remark.text.trim(),
      );
      if (_isEdit) {
        await repository.updateTemplate(req);
      } else {
        await repository.createTemplate(req);
      }
      if (!mounted) return;
      AppToast.success(context, l10n.websites_templateSaved);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEdit ? l10n.websites_templateEdit : l10n.websites_templateAdd,
          style: AppTextStyles.titleL,
        ),
        const SizedBox(height: AppTokens.s16),
        AppTextField(controller: _name, label: l10n.websites_templateName),
        const SizedBox(height: AppTokens.s12),
        DropdownButtonFormField<String>(
          initialValue: _type,
          decoration: InputDecoration(labelText: l10n.websites_templateType),
          items: [
            DropdownMenuItem(
              value: 'single',
              child: Text(l10n.websites_templateSingle),
            ),
            DropdownMenuItem(
              value: 'multi',
              child: Text(l10n.websites_templateMulti),
            ),
          ],
          onChanged: _isEdit
              ? null
              : (value) {
                  if (value != null) setState(() => _type = value);
                },
        ),
        const SizedBox(height: AppTokens.s12),
        if (_type == 'single') ...[
          TextField(
            controller: _content,
            minLines: 8,
            maxLines: 14,
            style: AppTextStyles.bodyS.copyWith(fontFamily: 'monospace'),
            decoration: InputDecoration(
              labelText: l10n.websites_templateContent,
              hintText: '<html><body><h1>{{title}}</h1></body></html>',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppTokens.s8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _detectVariables,
              icon: const Icon(TablerIcons.braces, size: AppTokens.iconList),
              label: Text(l10n.websites_templateAutoDetect),
            ),
          ),
        ] else ...[
          TonalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.websites_templateFilePath,
                  style: AppTextStyles.bodyS.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTokens.s4),
                Text(
                  displayValue(context, _filePath),
                  style: AppTextStyles.bodyS,
                ),
                const SizedBox(height: AppTokens.s8),
                SecondaryButton(
                  label: l10n.websites_templateUpload,
                  icon: TablerIcons.upload,
                  loading: _uploading,
                  onPressed: _upload,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: _remark, label: l10n.websites_templateRemark),
        const SizedBox(height: AppTokens.s24),
        SectionHeader(
          title: l10n.websites_templateVariables,
          trailing: TextButton.icon(
            onPressed: () => setState(() => _variables.add(_VariableDraft())),
            icon: const Icon(TablerIcons.plus, size: AppTokens.iconList),
            label: Text(l10n.websites_templateAddVariable),
          ),
        ),
        if (_variables.isEmpty)
          Text(
            l10n.websites_templateNoVariables,
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          )
        else
          for (var i = 0; i < _variables.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.s12),
              child: TonalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${l10n.websites_templateVariables} ${i + 1}',
                            style: AppTextStyles.titleS,
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.action_delete,
                          icon: const Icon(TablerIcons.trash),
                          onPressed: () {
                            final removed = _variables.removeAt(i);
                            removed.dispose();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    AppTextField(
                      controller: _variables[i].key,
                      label: l10n.websites_templateVariableKey,
                    ),
                    const SizedBox(height: AppTokens.s8),
                    AppTextField(
                      controller: _variables[i].label,
                      label: l10n.websites_templateVariableLabel,
                    ),
                    const SizedBox(height: AppTokens.s8),
                    DropdownButtonFormField<String>(
                      initialValue: _variables[i].type,
                      decoration: InputDecoration(
                        labelText: l10n.websites_templateVariableType,
                      ),
                      items: [
                        for (final type in const [
                          'text',
                          'textarea',
                          'number',
                          'select',
                          'color',
                        ])
                          DropdownMenuItem(
                            value: type,
                            child: Text(_variableTypeLabel(l10n, type)),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _variables[i].type = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppTokens.s8),
                    AppTextField(
                      controller: _variables[i].defaultValue,
                      label: l10n.websites_templateVariableDefault,
                    ),
                    if (_variables[i].type == 'select') ...[
                      const SizedBox(height: AppTokens.s8),
                      AppTextField(
                        controller: _variables[i].options,
                        label: l10n.websites_templateVariableOptions,
                      ),
                    ],
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.websites_templateVariableRequired),
                      value: _variables[i].required,
                      onChanged: (value) =>
                          setState(() => _variables[i].required = value),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: AppTokens.s24),
        PrimaryButton(
          label: l10n.action_save,
          loading: _saving,
          onPressed: _save,
        ),
      ],
    );
  }
}

String _variableTypeLabel(AppLocalizations l10n, String type) {
  return switch (type) {
    'textarea' => l10n.websites_templateVariableTypeTextarea,
    'number' => l10n.websites_templateVariableTypeNumber,
    'select' => l10n.websites_templateVariableTypeSelect,
    'color' => l10n.websites_templateVariableTypeColor,
    _ => l10n.websites_templateVariableTypeText,
  };
}

class _TemplateOutputSheet extends ConsumerStatefulWidget {
  const _TemplateOutputSheet({required this.template});

  final WebsiteTemplateDto template;

  @override
  ConsumerState<_TemplateOutputSheet> createState() =>
      _TemplateOutputSheetState();
}

class _TemplateOutputSheetState extends ConsumerState<_TemplateOutputSheet> {
  late final TextEditingController _name;
  final _values = <String, TextEditingController>{};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.template.name);
    for (final variable in widget.template.parsedVariables) {
      _values[variable.key] = TextEditingController(
        text: variable.defaultValue,
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    for (final controller in _values.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.createTemplateOutput(
        templateID: widget.template.id,
        name: name,
        variableValues: {
          for (final entry in _values.entries) entry.key: entry.value.text,
        },
      );
      if (!mounted) return;
      AppToast.success(context, l10n.websites_templateOutputGenerated);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final variables = widget.template.parsedVariables;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.websites_templateGenerate, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s8),
        Text(
          widget.template.name,
          style: AppTextStyles.bodyS.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppTokens.s16),
        AppTextField(
          controller: _name,
          label: l10n.websites_templateOutputName,
        ),
        for (final variable in variables) ...[
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: _values[variable.key],
            label: variable.label.isEmpty ? variable.key : variable.label,
            keyboardType: variable.type == 'number'
                ? TextInputType.number
                : TextInputType.text,
          ),
        ],
        const SizedBox(height: AppTokens.s24),
        PrimaryButton(
          label: l10n.websites_templateGenerate,
          loading: _saving,
          onPressed: _generate,
        ),
      ],
    );
  }
}

class _TemplateOutputsSheet extends ConsumerStatefulWidget {
  const _TemplateOutputsSheet();

  @override
  ConsumerState<_TemplateOutputsSheet> createState() =>
      _TemplateOutputsSheetState();
}

class _TemplateOutputsSheetState extends ConsumerState<_TemplateOutputsSheet> {
  List<WebsiteTemplateOutputDto> _outputs = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final result = await repository.searchTemplateOutputs();
      if (!mounted) return;
      setState(() => _outputs = result.items);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(WebsiteTemplateOutputDto output) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.websites_templateOutputDelete,
      message: output.name,
      confirmLabel: l10n.action_delete,
      requireText: output.name,
    );
    if (!confirmed) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.deleteTemplateOutput(output.id);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
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
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.websites_templateOutputs,
                style: AppTextStyles.titleL,
              ),
            ),
            IconButton(
              tooltip: l10n.action_refresh,
              icon: const Icon(TablerIcons.refresh),
              onPressed: _load,
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s12),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_outputs.isEmpty)
          EmptyState(
            icon: TablerIcons.folder,
            title: l10n.websites_templateOutputsEmptyTitle,
            message: l10n.websites_templateOutputEmpty,
            compact: true,
          )
        else
          for (final output in _outputs)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.s8),
              child: TonalCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(output.name, style: AppTextStyles.titleS),
                          Text(
                            output.outputPath,
                            style: AppTextStyles.bodyS.copyWith(
                              color: context.scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.websites_templateOutputDelete,
                      icon: const Icon(TablerIcons.trash),
                      onPressed: () => _delete(output),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
