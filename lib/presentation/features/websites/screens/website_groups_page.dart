import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/website/website_group_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/sheet_title.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

final _groupsProvider = FutureProvider.autoDispose<List<WebsiteGroupDto>>((
  ref,
) async {
  final repository = await ref.watch(websiteRepositoryProvider.future);
  return repository.searchWebsiteGroups();
}, name: 'websiteGroupsProvider');

class WebsiteGroupsPage extends ConsumerWidget {
  const WebsiteGroupsPage({
    super.key,
    required this.serverId,
    this.embedded = false,
  });

  final int serverId;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final groups = ref.watch(_groupsProvider);
    final create = IconButton(
      tooltip: l10n.action_create,
      onPressed: () => _openEditor(context, ref),
      icon: const Icon(TablerIcons.plus),
    );
    final body = AsyncStateView(
      value: groups,
      onRetry: () => ref.invalidate(_groupsProvider),
      loading: const SkeletonList(itemCount: 4),
      builder: (items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: TablerIcons.folder,
            title: l10n.websites_groupEmpty,
            actionLabel: l10n.action_create,
            onAction: () => _openEditor(context, ref),
          );
        }
        return ListView(
          padding: EdgeInsets.all(context.pagePadding),
          children: [
            SplitListGroup(
              children: [
                for (final group in items)
                  WebsiteGroupTile(
                    group: group,
                    onEdit: () => _openEditor(context, ref, group: group),
                    onDelete: () => _delete(context, ref, group),
                  ),
              ],
            ),
          ],
        );
      },
    );
    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetTitle(
            title: l10n.websites_groupManagement,
            onClose: () => Navigator.of(context).pop(),
            actions: [create],
          ),
          const SizedBox(height: AppTokens.s8),
          Expanded(child: body),
        ],
      );
    }
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.websites_groupManagement,
        actions: [
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.action_create,
            onPressed: () => _openEditor(context, ref),
          ),
        ],
      ),
      body: body,
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    WebsiteGroupDto? group,
  }) async {
    final result = await showAppSheet<WebsiteGroupDto>(
      context: context,
      builder: (context) => _GroupEditorSheet(group: group),
    );
    if (result == null || !context.mounted) return;
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      if (group == null) {
        await repository.createWebsiteGroup(result);
        if (!context.mounted) return;
        AppToast.success(context, l10n.websites_groupCreated);
      } else {
        await repository.updateWebsiteGroup(result);
        if (!context.mounted) return;
        AppToast.success(context, l10n.websites_groupUpdated);
      }
      ref.invalidate(_groupsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WebsiteGroupDto group,
  ) async {
    if (group.isDefault) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.common_delete,
      message: l10n.websites_groupDeleteConfirm(group.name),
      confirmLabel: l10n.common_delete,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.deleteWebsiteGroup(group.id);
      if (!context.mounted) return;
      AppToast.success(context, l10n.websites_groupDeleted);
      ref.invalidate(_groupsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _GroupEditorSheet extends StatefulWidget {
  const _GroupEditorSheet({this.group});

  final WebsiteGroupDto? group;

  @override
  State<_GroupEditorSheet> createState() => _GroupEditorSheetState();
}

class _GroupEditorSheetState extends State<_GroupEditorSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.group?.name ?? '',
  );
  late bool _isDefault = widget.group?.isDefault ?? false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.websites_groupNameRequired);
      return;
    }
    Navigator.of(context).pop(
      WebsiteGroupDto(
        id: widget.group?.id ?? 0,
        name: name,
        type: 'website',
        isDefault: _isDefault,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.group == null
              ? l10n.websites_groupManagement
              : l10n.common_edit,
          style: AppTextStyles.titleL,
        ),
        const SizedBox(height: AppTokens.s16),
        AppTextField(
          controller: _name,
          label: l10n.websites_groupName,
          autofocus: true,
          errorText: _error,
          onSubmitted: (_) => _submit(),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l10n.websites_groupSetDefault,
            style: AppTextStyles.bodyM,
          ),
          value: _isDefault,
          onChanged: (value) => setState(() => _isDefault = value),
        ),
        const SizedBox(height: AppTokens.s16),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: l10n.action_cancel,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: PrimaryButton(label: l10n.action_save, onPressed: _submit),
            ),
          ],
        ),
      ],
    );
  }
}

class WebsiteGroupTile extends StatelessWidget {
  const WebsiteGroupTile({
    super.key,
    required this.group,
    required this.onEdit,
    required this.onDelete,
  });

  final WebsiteGroupDto group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SplitListTile(
      leading: Icon(
        group.isDefault ? TablerIcons.folder_star : TablerIcons.folder,
      ),
      title: group.name,
      subtitle: group.isDefault ? l10n.websites_groupSystemReserved : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.common_edit,
            onPressed: onEdit,
            icon: const Icon(TablerIcons.pencil),
          ),
          if (!group.isDefault)
            IconButton(
              tooltip: l10n.common_delete,
              onPressed: onDelete,
              icon: Icon(TablerIcons.trash, color: context.scheme.error),
            )
          else
            Padding(
              padding: const EdgeInsets.only(
                right: AppTokens.s16,
                left: AppTokens.s8,
              ),
              child: Icon(
                TablerIcons.lock,
                size: AppTokens.iconList,
                color: context.scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> showWebsiteGroupsSheet(
  BuildContext context, {
  required int serverId,
}) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.90,
    builder: (sheetContext) => SizedBox(
      height: MediaQuery.sizeOf(sheetContext).height * 0.70,
      child: WebsiteGroupsPage(serverId: serverId, embedded: true),
    ),
  );
}
