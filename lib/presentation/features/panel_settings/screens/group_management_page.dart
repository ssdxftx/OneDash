import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/setting/group_dto.dart';
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

final _groupTypeProvider = StateProvider.autoDispose<String>((ref) => 'script');

final _groupsProvider = FutureProvider.autoDispose<List<CoreGroupDto>>((
  ref,
) async {
  final type = ref.watch(_groupTypeProvider);
  final repository = await ref.watch(settingRepositoryProvider.future);
  return repository.searchGroups(type: type);
}, name: 'panelGroupManagementProvider');

class GroupManagementPage extends ConsumerWidget {
  const GroupManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final groups = ref.watch(_groupsProvider);
    final type = ref.watch(_groupTypeProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.panelSettings_groupManagement,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_groupsProvider),
          ),
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.group_add,
            onPressed: () => _edit(context, ref, type),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(context.pagePadding),
            child: DropdownButtonFormField<String>(
              initialValue: type,
              decoration: InputDecoration(labelText: l10n.files_permission),
              items: [
                DropdownMenuItem(
                  value: 'script',
                  child: Text(l10n.group_typeScript),
                ),
                DropdownMenuItem(
                  value: 'command',
                  child: Text(l10n.group_typeCommand),
                ),
                DropdownMenuItem(
                  value: 'cronjob',
                  child: Text(l10n.group_typeCronjob),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(_groupTypeProvider.notifier).state = value;
                }
              },
            ),
          ),
          Expanded(
            child: AsyncStateView(
              value: groups,
              onRetry: () => ref.invalidate(_groupsProvider),
              loading: const SkeletonList(itemCount: 6),
              isEmpty: (items) => items.isEmpty,
              empty: EmptyState(
                icon: TablerIcons.folder,
                title: l10n.group_empty,
              ),
              builder: (items) => ListView(
                padding: EdgeInsets.all(context.pagePadding),
                children: [
                  SplitListGroup(
                    children: [
                      for (final group in items)
                        SplitListTile(
                          leading: Icon(
                            group.isDefault
                                ? TablerIcons.folder_star
                                : TablerIcons.folder,
                          ),
                          title: group.name,
                          subtitle: group.isDefault
                              ? l10n.websites_groupSystemReserved
                              : null,
                          onTap: group.isDefault
                              ? null
                              : () => _edit(context, ref, type, group: group),
                          trailing: group.isDefault
                              ? null
                              : IconButton(
                                  tooltip: l10n.action_delete,
                                  icon: Icon(
                                    TablerIcons.trash,
                                    color: context.scheme.error,
                                  ),
                                  onPressed: () => _delete(context, ref, group),
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
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    CoreGroupDto group,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: group.name,
      confirmLabel: l10n.action_delete,
      danger: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.deleteGroup(group.id);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_groupsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    String type, {
    CoreGroupDto? group,
  }) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: group?.name ?? '');
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: group == null ? l10n.group_add : l10n.action_edit,
          saveLabel: l10n.action_save,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(controller: controller, label: l10n.group_name),
          ],
        ),
      ),
    );
    final name = controller.text.trim();
    controller.dispose();
    if (saved != true || name.isEmpty || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      if (group == null) {
        await repository.createGroup(name: name, type: type);
      } else {
        await repository.updateGroup(
          id: group.id,
          name: name,
          type: type,
          isDefault: group.isDefault,
        );
      }
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_groupsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}
