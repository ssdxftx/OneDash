import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/container/container_compose_dto.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';

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
          padding: const EdgeInsets.all(AppTokens.s16),
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

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    ContainerComposeDto item,
  ) async {
    final l10n = AppLocalizations.of(context);
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s4),
          Text(
            item.path,
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              for (final operation in ['up', 'restart', 'down', 'stop'])
                SplitListTile(
                  leading: const Icon(TablerIcons.player_play),
                  title: operation,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    try {
                      final repository = await ref.read(
                        containerRepositoryProvider.future,
                      );
                      await repository.operateCompose(
                        name: item.name,
                        path: item.path,
                        operation: operation,
                      );
                      if (!context.mounted) return;
                      AppToast.success(context, l10n.action_done);
                      ref.invalidate(_composeProvider);
                    } catch (error) {
                      if (!context.mounted) return;
                      AppToast.error(context, '$error');
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
        ],
      ),
    );
  }
}

class _ComposeCard extends StatelessWidget {
  const _ComposeCard({required this.item, required this.onTap});

  final ContainerComposeDto item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
