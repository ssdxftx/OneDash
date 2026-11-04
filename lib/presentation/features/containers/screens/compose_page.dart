import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/container/container_compose_dto.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../widgets/container_log_page.dart';
import '../../../common/components/action_sheet.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/task_progress_sheet.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/formatters/enum_labels.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

final _composeProvider = FutureProvider.autoDispose<ContainerComposeSearchDto>((
  ref,
) {
  return ref
      .watch(containerRepositoryProvider.future)
      .then((repository) => repository.searchCompose());
}, name: 'composeProvider');

class ComposePage extends ConsumerWidget {
  const ComposePage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final compose = ref.watch(_composeProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.containers_compose,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_composeProvider),
          ),
          AppIconButton(
            icon: TablerIcons.folder,
            tooltip: l10n.containers_composeTemplates,
            onPressed: () => _showTemplates(context, ref),
          ),
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.containers_createCompose,
            onPressed: () => context.push('/s/$serverId/more/compose/form'),
          ),
        ],
      ),
      body: AsyncStateView(
        value: compose,
        onRetry: () => ref.invalidate(_composeProvider),
        loading: const SkeletonList(itemCount: 6),
        isEmpty: (data) => data.items.isEmpty,
        empty: EmptyState(
          icon: TablerIcons.stack_2,
          title: l10n.containers_empty_title,
          message: l10n.containers_empty_message,
        ),
        builder: (data) => ListView.builder(
          padding: EdgeInsets.all(context.pagePadding),
          itemCount: data.items.length,
          itemBuilder: (context, index) {
            final item = data.items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.s12),
              child: _ComposeCard(
                item: item,
                onTap: () => _showActions(context, ref, item),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showTemplates(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final result = await repository.searchTemplates();
      if (!context.mounted) return;
      final action = await showAppSheet<String>(
        context: context,
        maxHeightFactor: 0.9,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.containers_composeTemplates,
                    style: AppTextStyles.titleL,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.of(sheetContext).pop('import'),
                  icon: const Icon(TablerIcons.upload, size: 18),
                  label: Text(l10n.containers_importTemplates),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s8),
            if (result.items.isEmpty)
              EmptyState(
                compact: true,
                icon: TablerIcons.template,
                title: l10n.state_empty,
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final template in result.items)
                      ListTile(
                        leading: const Icon(TablerIcons.template),
                        title: Text(template.name),
                        subtitle: Text(template.description),
                        trailing: IconButton(
                          tooltip: l10n.action_delete,
                          icon: Icon(
                            TablerIcons.trash,
                            color: sheetContext.appColors.danger,
                          ),
                          onPressed: () => Navigator.of(
                            sheetContext,
                          ).pop('delete:${template.id}'),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
      if (action == null || !context.mounted) return;
      if (action == 'import') {
        await _importTemplates(context, ref);
      } else if (action.startsWith('delete:')) {
        final id = int.tryParse(action.substring(7));
        if (id == null) return;
        await repository.deleteTemplates([id]);
        if (!context.mounted) return;
        AppToast.success(context, l10n.action_done);
      }
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _importTemplates(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.containers_importTemplates,
          saveLabel: l10n.action_import,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [AppTextField(controller: controller, maxLines: 14)],
        ),
      ),
    );
    final raw = controller.text.trim();
    controller.dispose();
    if (saved != true || raw.isEmpty || !context.mounted) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        AppToast.warning(context, l10n.containers_templateJsonInvalid);
        return;
      }
      final templates = decoded
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
      if (templates.isEmpty) return;
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.batchImportTemplates(templates);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    ContainerComposeDto item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final running =
        item.runningCount >= item.containerCount && item.containerCount > 0;
    await showAppSheet<void>(
      context: context,
      maxHeightFactor: 0.85,
      builder: (sheetContext) => ActionSheetScaffold(
        infoCard: ActionSheetInfoCard(
          leading: Container(
            decoration: BoxDecoration(
              color: (running ? colors.success : colors.info).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(AppTokens.rMd),
            ),
            child: Icon(
              TablerIcons.stack_2,
              color: running ? colors.success : colors.info,
              size: AppTokens.iconNav,
            ),
          ),
          title: item.name,
          subtitle: item.path,
          trailing: ActionSheetStatusPill(
            label: '${item.runningCount}/${item.containerCount}',
            color: running ? colors.success : colors.info,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ActionSheetSection(
              title: l10n.containers_compose,
              icon: TablerIcons.settings,
              children: [
                ActionSheetRow(
                  icon: TablerIcons.edit,
                  iconColor: colors.chart2,
                  title: l10n.action_edit,
                  subtitle: l10n.containers_updateCompose,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/s/$serverId/more/compose/form', extra: item);
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.file_text,
                  iconColor: colors.info,
                  title: l10n.containers_composeLogs,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showLogs(context, ref, item);
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.trash,
                  iconColor: colors.warning,
                  title: l10n.containers_cleanComposeLogs,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _run(
                      context,
                      ref,
                      l10n.containers_cleanComposeLogs,
                      () async {
                        final repository = await ref.read(
                          containerRepositoryProvider.future,
                        );
                        await repository.cleanComposeLog(
                          name: item.name,
                          composePath: item.path,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            ActionSheetSection(
              title: l10n.containers_groupLifecycle,
              icon: TablerIcons.player_play,
              children: [
                for (final operation in [
                  ('up', l10n.containers_up, TablerIcons.player_play),
                  ('restart', l10n.action_restart, TablerIcons.refresh),
                  ('down', l10n.containers_down, TablerIcons.player_stop),
                  ('stop', l10n.containers_stop, TablerIcons.player_pause),
                  ('rebuild', l10n.containers_rebuild, TablerIcons.reload),
                ])
                  ActionSheetRow(
                    icon: operation.$3,
                    iconColor: operation.$1 == 'down'
                        ? colors.warning
                        : colors.info,
                    title: operation.$2,
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await _run(context, ref, operation.$2, () async {
                        final repository = await ref.read(
                          containerRepositoryProvider.future,
                        );
                        await repository.operateCompose(
                          name: item.name,
                          path: item.path,
                          operation: operation.$1,
                        );
                      });
                    },
                  ),
              ],
            ),
            ActionSheetSection(
              title: l10n.containers_groupDanger,
              icon: TablerIcons.alert_triangle,
              children: [
                ActionSheetRow(
                  icon: TablerIcons.trash,
                  iconColor: colors.danger,
                  title: l10n.action_delete,
                  danger: true,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final confirmed = await showConfirmSheet(
                      context,
                      title: l10n.containers_deleteCompose,
                      message: l10n.containers_deleteComposeConfirm(item.name),
                      confirmLabel: l10n.action_delete,
                      requireText: item.name,
                    );
                    if (!confirmed || !context.mounted) return;
                    await _run(context, ref, l10n.action_delete, () async {
                      final repository = await ref.read(
                        containerRepositoryProvider.future,
                      );
                      await repository.operateCompose(
                        name: item.name,
                        path: item.path,
                        operation: 'delete',
                      );
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    String title,
    Future<void> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final success = await TaskProgressSheet.run(
      context,
      title: title,
      task: (_) => action(),
    );
    if (!success || !context.mounted) return;
    AppToast.success(context, l10n.action_done);
    ref.invalidate(_composeProvider);
  }

  Future<void> _showLogs(
    BuildContext context,
    WidgetRef ref,
    ContainerComposeDto item,
  ) {
    return openComposeLogs(
      context,
      ref,
      composePath: item.path,
      subtitle: item.name,
    );
  }
}

class _ComposeCard extends StatelessWidget {
  const _ComposeCard({required this.item, required this.onTap});

  final ContainerComposeDto item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final running =
        item.runningCount >= item.containerCount && item.containerCount > 0;
    return TonalCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusDot(status: running ? 'running' : 'stopped'),
              const SizedBox(width: AppTokens.s8),
              Text(
                taskStatusLabel(running ? 'running' : 'stopped', l10n),
                style: AppTextStyles.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppTokens.s8),
              Expanded(
                child: Text(
                  item.name,
                  style: AppTextStyles.titleM,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${item.runningCount}/${item.containerCount}',
                style: AppTextStyles.bodyS.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s4),
          Text(
            item.path,
            style: AppTextStyles.bodyS.copyWith(
              color: scheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
