import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../providers/container_resources_provider.dart';

class ContainerVolumesPage extends ConsumerWidget {
  const ContainerVolumesPage({super.key, required this.serverId});

  final int serverId;

  Future<void> _remove(BuildContext context, WidgetRef ref, String name) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: l10n.containers_volumeDeleteConfirm(name),
      confirmLabel: l10n.action_delete,
      requireText: name,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.deleteVolumes([name]);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(containerVolumesProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final volumes = ref.watch(containerVolumesProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.containers_storageVolumes,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(containerVolumesProvider),
          ),
        ],
      ),
      body: AsyncStateView(
        value: volumes,
        onRetry: () => ref.invalidate(containerVolumesProvider),
        loading: const SkeletonList(itemCount: 5),
        isEmpty: (items) => items.isEmpty,
        empty: EmptyState(
          icon: TablerIcons.database,
          title: l10n.containers_volumesEmpty,
          message: l10n.containers_volumesEmptyHint,
        ),
        builder: (items) => ListView.separated(
          padding: EdgeInsets.all(context.pagePadding),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
          itemBuilder: (context, index) {
            final volume = items[index];
            return TonalCard(
              onLongPress: () => _remove(context, ref, volume.option),
              child: Row(
                children: [
                  Icon(
                    TablerIcons.database,
                    color: context.scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppTokens.s12),
                  Expanded(
                    child: Text(
                      volume.option,
                      style: AppTextStyles.titleM,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.action_delete,
                    icon: Icon(
                      TablerIcons.trash,
                      color: context.appColors.danger,
                    ),
                    onPressed: () => _remove(context, ref, volume.option),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
