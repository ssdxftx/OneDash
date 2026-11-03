import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/process_repository_impl.dart';
import '../../../../domain/entities/process_info.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

final _processesProvider = FutureProvider.autoDispose<List<ProcessInfo>>((
  ref,
) async {
  final repository = await ref.watch(processRepositoryProvider.future);
  return repository.listListening();
}, name: 'processesProvider');

class ProcessPage extends ConsumerWidget {
  const ProcessPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final processes = ref.watch(_processesProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.more_process,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_processesProvider),
          ),
        ],
      ),
      body: AsyncStateView(
        value: processes,
        onRetry: () => ref.invalidate(_processesProvider),
        loading: const SkeletonList(itemCount: 10, itemHeight: 56),
        isEmpty: (items) => items.isEmpty,
        empty: EmptyState(
          icon: TablerIcons.cpu,
          title: l10n.process_emptyTitle,
          message: l10n.process_emptyMessage,
        ),
        builder: (items) => ListView.builder(
          padding: const EdgeInsets.all(AppTokens.pagePadding),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.s8),
              child: TonalCard(
                onLongPress: () => _showActions(context, ref, item),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppTokens.rSm),
                      ),
                      child: Text(
                        '${item.pid}',
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppTokens.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name.isEmpty ? 'PID ${item.pid}' : item.name,
                            style: AppTextStyles.titleS,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${item.address.isEmpty ? '-' : item.address}:${item.port.isEmpty ? '-' : item.port} · ${item.protocol}',
                            style: AppTextStyles.caption.copyWith(
                              color: context.scheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(item.user, style: AppTextStyles.caption),
                    IconButton(
                      tooltip: l10n.action_more,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        TablerIcons.dots,
                        size: AppTokens.iconList,
                      ),
                      onPressed: () => _showActions(context, ref, item),
                    ),
                  ],
                ),
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
    ProcessInfo item,
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
            'PID ${item.pid} · ${item.user}',
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.trash),
                title: l10n.process_stopTitle,
                danger: true,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final confirmed = await showConfirmSheet(
                    context,
                    title: l10n.process_stopTitle,
                    message: l10n.process_stopContent(item.pid),
                    confirmLabel: l10n.process_stopAction,
                  );
                  if (!confirmed) return;
                  try {
                    final repository = await ref.read(
                      processRepositoryProvider.future,
                    );
                    await repository.stopProcess(item.pid);
                    if (!context.mounted) return;
                    AppToast.success(context, l10n.action_done);
                    ref.invalidate(_processesProvider);
                  } catch (error) {
                    if (!context.mounted) return;
                    showErrorToast(context, error);
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
