import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/common/page_result.dart';
import '../../../../data/dto/runtime/runtime_dto.dart';
import '../../../../data/repositories_impl/runtime_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

final _runtimesProvider = FutureProvider.autoDispose<PageResult<RuntimeDto>>((
  ref,
) async {
  final repository = await ref.watch(runtimeRepositoryProvider.future);
  return repository.searchRuntimes(const {'page': 1, 'pageSize': 100});
}, name: 'runtimesProvider');

class RuntimesPage extends ConsumerWidget {
  const RuntimesPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final runtimes = ref.watch(_runtimesProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.more_runtimes,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_runtimesProvider),
          ),
        ],
      ),
      body: AsyncStateView(
        value: runtimes,
        onRetry: () => ref.invalidate(_runtimesProvider),
        loading: const SkeletonList(itemCount: 8),
        isEmpty: (data) => data.items.isEmpty,
        empty: EmptyState(
          icon: TablerIcons.brand_docker,
          title: l10n.more_runtimes,
          message: l10n.state_empty,
        ),
        builder: (data) => ListView.builder(
          padding: const EdgeInsets.all(AppTokens.s16),
          itemCount: data.items.length,
          itemBuilder: (context, index) {
            final runtime = data.items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.s12),
              child: TonalCard(
                onTap: () => context.push(
                  '/s/$serverId/more/runtimes/${runtime.id}?type=${Uri.encodeComponent(runtime.type)}&name=${Uri.encodeComponent(runtime.name)}',
                ),
                onLongPress: () => _showActions(context, ref, runtime),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusDot(status: runtime.status.toLowerCase()),
                        const SizedBox(width: AppTokens.s8),
                        Expanded(
                          child: Text(
                            runtime.name,
                            style: AppTextStyles.titleM,
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
                            color: context.scheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppTokens.rXs),
                          ),
                          child: Text(
                            runtime.type,
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.s8),
                    Text(
                      '${runtime.image} · ${runtime.version}',
                      style: AppTextStyles.caption.copyWith(
                        color: context.scheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTokens.s4),
                    Text(
                      '${runtime.port.isEmpty ? '-' : runtime.port} · ${runtime.path}',
                      style: AppTextStyles.caption.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
    RuntimeDto runtime,
  ) async {
    final l10n = AppLocalizations.of(context);
    final running = runtime.status.toLowerCase() == 'running';
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(runtime.name, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s4),
          Text(
            '${runtime.type} · ${runtime.version}',
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.player_play),
                title: running ? l10n.containers_stop : l10n.containers_start,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _operate(
                    context,
                    ref,
                    runtime,
                    running ? 'stop' : 'start',
                  );
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.refresh),
                title: l10n.containers_restart,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _operate(context, ref, runtime, 'restart');
                },
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
        ],
      ),
    );
  }

  Future<void> _operate(
    BuildContext context,
    WidgetRef ref,
    RuntimeDto runtime,
    String operation,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      await repository.operateRuntime(runtime.id, operation);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_runtimesProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}
