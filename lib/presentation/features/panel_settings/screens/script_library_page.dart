import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/setting/script_library_dto.dart';
import '../../../../data/repositories_impl/setting_repository_impl.dart';
import '../../server_detail/providers/active_server_provider.dart';
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

final _scriptsProvider = FutureProvider.autoDispose<List<ScriptLibraryDto>>((
  ref,
) async {
  final repository = await ref.watch(settingRepositoryProvider.future);
  final result = await repository.searchScripts(pageSize: 100);
  return result.items;
}, name: 'panelScriptLibraryProvider');

class ScriptLibraryPage extends ConsumerWidget {
  const ScriptLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scripts = ref.watch(_scriptsProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.panelSettings_scriptLibrary,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_scriptsProvider),
          ),
          AppIconButton(
            icon: TablerIcons.cloud_download,
            tooltip: l10n.scriptLibrary_sync,
            onPressed: () => _sync(context, ref),
          ),
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.scriptLibrary_add,
            onPressed: () => _edit(context, ref),
          ),
        ],
      ),
      body: AsyncStateView(
        value: scripts,
        onRetry: () => ref.invalidate(_scriptsProvider),
        loading: const SkeletonList(itemCount: 6),
        isEmpty: (items) => items.isEmpty,
        empty: EmptyState(
          icon: TablerIcons.file_code,
          title: l10n.scriptLibrary_empty,
        ),
        builder: (items) => ListView(
          padding: EdgeInsets.all(context.pagePadding),
          children: [
            SplitListGroup(
              children: [
                for (final item in items)
                  SplitListTile(
                    leading: Icon(
                      item.isSystem ? TablerIcons.lock : TablerIcons.file_code,
                    ),
                    title: item.name,
                    subtitle: item.description,
                    value: item.groupBelong.join(', '),
                    onTap: item.isSystem
                        ? null
                        : () => _edit(context, ref, script: item),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: l10n.scriptLibrary_run,
                          icon: const Icon(TablerIcons.player_play),
                          onPressed: () {
                            final serverId = ref.read(activeServerIdProvider);
                            context.push(
                              '/s/$serverId/terminal'
                              '?scriptId=${item.id}',
                            );
                          },
                        ),
                        if (!item.isSystem)
                          IconButton(
                            tooltip: l10n.action_delete,
                            icon: Icon(
                              TablerIcons.trash,
                              color: context.scheme.error,
                            ),
                            onPressed: () => _delete(context, ref, item),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.syncScripts(const Uuid().v4());
      if (!context.mounted) return;
      AppToast.success(context, l10n.scriptLibrary_syncStarted);
      ref.invalidate(_scriptsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ScriptLibraryDto script,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: script.name,
      confirmLabel: l10n.action_delete,
      danger: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.deleteScripts([script.id]);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_scriptsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    ScriptLibraryDto? script,
  }) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController(text: script?.name ?? '');
    final description = TextEditingController(text: script?.description ?? '');
    final content = TextEditingController(text: script?.script ?? '');
    var interactive = script?.isInteractive ?? false;
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => StatefulBuilder(
          builder: (context, setState) => SimpleFormPage(
            title: script == null ? l10n.scriptLibrary_add : l10n.action_edit,
            saveLabel: l10n.action_save,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              AppTextField(controller: name, label: l10n.scriptLibrary_name),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: description,
                label: l10n.scriptLibrary_description,
              ),
              const SizedBox(height: AppTokens.s12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.scriptLibrary_interactive),
                value: interactive,
                onChanged: (value) => setState(() => interactive = value),
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: content,
                label: l10n.scriptLibrary_content,
                maxLines: 14,
              ),
            ],
          ),
        ),
      ),
    );
    final data = {
      if (script != null) 'id': script.id,
      'name': name.text.trim(),
      'description': description.text.trim(),
      'script': content.text,
      'isInteractive': interactive,
      'groups': '',
    };
    name.dispose();
    description.dispose();
    content.dispose();
    if (saved != true || data['name'] == '' || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      if (script == null) {
        await repository.createScript(data);
      } else {
        await repository.updateScript(data);
      }
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_scriptsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}
