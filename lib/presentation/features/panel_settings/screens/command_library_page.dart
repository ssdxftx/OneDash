import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/setting/command_library_dto.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';
import '../../../../data/repositories_impl/setting_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

final _commandsProvider = FutureProvider.autoDispose<List<CommandLibraryDto>>((
  ref,
) async {
  final repository = await ref.watch(settingRepositoryProvider.future);
  final result = await repository.searchCommands(pageSize: 100);
  return result.items;
}, name: 'panelCommandLibraryProvider');

class CommandLibraryPage extends ConsumerWidget {
  const CommandLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final commands = ref.watch(_commandsProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.panelSettings_commandLibrary,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_commandsProvider),
          ),
          AppIconButton(
            icon: TablerIcons.sitemap,
            tooltip: l10n.commandLibrary_tree,
            onPressed: () => _showTree(context, ref),
          ),
          AppIconButton(
            icon: TablerIcons.file_import,
            tooltip: l10n.commandLibrary_import,
            onPressed: () => _import(context, ref),
          ),
          AppIconButton(
            icon: TablerIcons.file_export,
            tooltip: l10n.commandLibrary_export,
            onPressed: () => _export(context, ref),
          ),
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.commandLibrary_add,
            onPressed: () => _edit(context, ref),
          ),
        ],
      ),
      body: AsyncStateView(
        value: commands,
        onRetry: () => ref.invalidate(_commandsProvider),
        loading: const SkeletonList(itemCount: 6),
        isEmpty: (items) => items.isEmpty,
        empty: EmptyState(
          icon: TablerIcons.terminal_2,
          title: l10n.commandLibrary_empty,
        ),
        builder: (items) => ListView(
          padding: EdgeInsets.all(context.pagePadding),
          children: [
            SplitListGroup(
              children: [
                for (final item in items)
                  SplitListTile(
                    leading: const Icon(TablerIcons.terminal_2),
                    title: item.name,
                    subtitle: item.command,
                    value: item.groupBelong,
                    onTap: () => _edit(context, ref, command: item),
                    trailing: IconButton(
                      tooltip: l10n.action_delete,
                      icon: Icon(
                        TablerIcons.trash,
                        color: context.scheme.error,
                      ),
                      onPressed: () => _delete(context, ref, item),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTree(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final tree = await repository.searchCommandTree();
      if (!context.mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.commandLibrary_tree, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final group in tree) ...[
                    Text(group.label, style: AppTextStyles.titleM),
                    const SizedBox(height: AppTokens.s8),
                    SplitListGroup(
                      children: [
                        for (final child in group.children)
                          SplitListTile(
                            leading: const Icon(TablerIcons.terminal_2),
                            title: child.label,
                            subtitle: child.value,
                            onTap: () async {
                              await Clipboard.setData(
                                ClipboardData(text: child.value),
                              );
                              if (!sheetContext.mounted) return;
                              AppToast.success(
                                sheetContext,
                                l10n.commandLibrary_copied,
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.s16),
                  ],
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

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        withData: true,
      );
      if (!context.mounted) return;
      final file = result?.files.firstOrNull;
      if (file == null) return;
      final bytes = file.bytes;
      if (bytes == null) return;
      final rows = _parseCsv(utf8.decode(bytes, allowMalformed: true));
      if (rows.length <= 1) {
        AppToast.warning(context, l10n.commandLibrary_importEmpty);
        return;
      }
      final items = <Map<String, dynamic>>[];
      for (final row in rows.skip(1)) {
        if (row.length < 2) continue;
        final name = row[0].trim();
        final command = row[1].trim();
        if (name.isEmpty || command.isEmpty) continue;
        items.add({
          'type': 'command',
          'groupID': 0,
          'groupBelong': '',
          'name': name,
          'command': command,
        });
      }
      if (items.isEmpty) {
        AppToast.warning(context, l10n.commandLibrary_importEmpty);
        return;
      }
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.importCommands(items);
      if (!context.mounted) return;
      AppToast.success(context, l10n.commandLibrary_imported);
      ref.invalidate(_commandsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final path = await repository.exportCommands();
      if (path.isEmpty) return;
      final fileRepository = await ref.read(fileRepositoryProvider.future);
      final tempDir = await getTemporaryDirectory();
      final name = path.split('/').last;
      final savePath =
          '${tempDir.path}/onedash_${DateTime.now().microsecondsSinceEpoch}_$name';
      await fileRepository.downloadFileTo(path: path, savePath: savePath);
      if (!context.mounted) return;
      await SharePlus.instance.share(
        ShareParams(files: [XFile(savePath, name: name)]),
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.commandLibrary_exported);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    CommandLibraryDto command,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: command.name,
      confirmLabel: l10n.action_delete,
      danger: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.deleteCommands(ids: [command.id]);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_commandsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    CommandLibraryDto? command,
  }) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController(text: command?.name ?? '');
    final content = TextEditingController(text: command?.command ?? '');
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: command == null ? l10n.commandLibrary_add : l10n.action_edit,
          saveLabel: l10n.action_save,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(controller: name, label: l10n.commandLibrary_name),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: content,
              label: l10n.commandLibrary_command,
              maxLines: 8,
            ),
          ],
        ),
      ),
    );
    final data = {
      if (command != null) 'id': command.id,
      'type': 'command',
      'groupID': command?.groupId ?? 0,
      'groupBelong': command?.groupBelong ?? '',
      'name': name.text.trim(),
      'command': content.text.trim(),
    };
    name.dispose();
    content.dispose();
    if (saved != true || data['name'] == '' || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      if (command == null) {
        await repository.createCommand(data);
      } else {
        await repository.updateCommand(data);
      }
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_commandsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

List<List<String>> _parseCsv(String text) {
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var quoted = false;
  for (var i = 0; i < text.length; i++) {
    final char = text[i];
    if (quoted) {
      if (char == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        field.write(char);
      }
      continue;
    }
    if (char == '"') {
      quoted = true;
    } else if (char == ',') {
      row.add(field.toString());
      field.clear();
    } else if (char == '\n') {
      row.add(field.toString());
      field.clear();
      rows.add(row);
      row = <String>[];
    } else if (char != '\r') {
      field.write(char);
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString());
    rows.add(row);
  }
  return rows;
}
