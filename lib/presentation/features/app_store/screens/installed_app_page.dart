import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/components/app_toast.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../common/states/async_state_view.dart';
import '../providers/app_store_provider.dart';
import '../../../common/states/error_toast.dart';

class InstalledAppPage extends ConsumerWidget {
  const InstalledAppPage({
    super.key,
    required this.serverId,
    required this.installId,
    this.detailId,
  });

  final int serverId;
  final String installId;
  final int? detailId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = int.tryParse(installId) ?? 0;
    final info = ref.watch(installedInfoProvider(id));
    return Scaffold(
      appBar: AppBarLarge(
        title: info.valueOrNull?.name ?? l10n.apps_installed,
        actions: [
          AppIconButton(
            icon: TablerIcons.terminal_2,
            tooltip: l10n.containers_terminal,
            onPressed: () {
              final container = info.valueOrNull?.container;
              if (container == null || container.isEmpty) return;
              context.push(
                '/s/$serverId/terminal?container=${Uri.encodeComponent(container)}',
              );
            },
          ),
        ],
      ),
      body: AsyncStateView(
        value: info,
        onRetry: () => ref.invalidate(installedInfoProvider(id)),
        builder: (app) => ListView(
          padding: const EdgeInsets.all(AppTokens.s16),
          children: [
            TonalCard(
              child: Row(
                children: [
                  StatusDot(status: app.status.toLowerCase()),
                  const SizedBox(width: AppTokens.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.name, style: AppTextStyles.titleM),
                        Text(
                          '${app.version} · ${app.httpPort}',
                          style: AppTextStyles.bodyS.copyWith(
                            color: context.scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _operate(context, ref, id, 'start'),
                    icon: const Icon(TablerIcons.player_play),
                    label: Text(l10n.containers_start),
                  ),
                ),
                const SizedBox(width: AppTokens.s8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _operate(context, ref, id, 'stop'),
                    icon: const Icon(TablerIcons.player_stop),
                    label: Text(l10n.containers_stop),
                  ),
                ),
                const SizedBox(width: AppTokens.s8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _operate(context, ref, id, 'restart'),
                    icon: const Icon(TablerIcons.refresh),
                    label: Text(l10n.containers_restart),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s24),
            SplitListGroup(
              children: [
                SplitListTile(title: l10n.app_detail_key, subtitle: app.appKey),
                SplitListTile(
                  title: l10n.app_detail_container,
                  subtitle: app.container,
                ),
                SplitListTile(
                  title: l10n.app_detail_compose,
                  subtitle: app.composePath,
                ),
                if (app.message.isNotEmpty)
                  SplitListTile(
                    title: l10n.app_detail_message,
                    subtitle: app.message,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _operate(
    BuildContext context,
    WidgetRef ref,
    int installId,
    String operation,
  ) async {
    final detailId = this.detailId ?? 0;
    final l10n = AppLocalizations.of(context);
    if (detailId <= 0) {
      AppToast.warning(
        context,
        AppLocalizations.of(context).apps_detailMissing,
      );
      return;
    }
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      switch (operation) {
        case 'start':
          await repository.startInstalled(
            installId: installId,
            detailId: detailId,
          );
          break;
        case 'stop':
          await repository.stopInstalled(
            installId: installId,
            detailId: detailId,
          );
          break;
        case 'restart':
          await repository.restartInstalled(
            installId: installId,
            detailId: detailId,
          );
          break;
      }
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(installedInfoProvider(installId));
      ref.invalidate(installedAppsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}
