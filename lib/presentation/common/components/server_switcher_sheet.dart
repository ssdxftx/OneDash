import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../states/error_mapper.dart';
import '../states/error_toast.dart';
import '../../../core/theme/tokens.dart';
import '../../features/servers/providers/servers_provider.dart';
import 'bottom_sheet_surface.dart';
import 'split_list_group.dart';
import 'skeleton.dart';
import '../states/error_state.dart';

Future<void> showServerSwitcher(
  BuildContext context,
  WidgetRef ref, {
  int? currentServerId,
}) {
  return showAppSheet<void>(
    context: context,
    builder: (context) => _ServerSwitcherBody(currentServerId: currentServerId),
  );
}

class _ServerSwitcherBody extends ConsumerWidget {
  const _ServerSwitcherBody({this.currentServerId});

  final int? currentServerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final servers = ref.watch(serversProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.servers_title, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s16),
        servers.when(
          loading: () => const SkeletonShimmer(
            child: Column(
              children: [
                SkeletonCard(height: 64),
                SkeletonCard(height: 64),
                SkeletonCard(height: 64),
              ],
            ),
          ),
          error: (error, _) => ErrorState(
            compact: true,
            data: mapError(error, l10n),
            onRetry: () => ref.invalidate(serversProvider),
          ),
          data: (items) => Column(
            children: [
              SplitListGroup(
                children: [
                  for (final server in items)
                    SplitListTile(
                      leading: const Icon(TablerIcons.server),
                      title: server.displayName,
                      subtitle: '${server.host}:${server.port}',
                      trailing: server.id == currentServerId
                          ? Icon(
                              TablerIcons.check,
                              color: Theme.of(context).colorScheme.primary,
                              size: AppTokens.iconList,
                            )
                          : const Icon(
                              TablerIcons.chevron_right,
                              size: AppTokens.iconList,
                            ),
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        final router = GoRouter.of(context);
                        try {
                          await ref
                              .read(serversProvider.notifier)
                              .touch(server.id);
                        } catch (error) {
                          if (!context.mounted) return;
                          showErrorToast(context, error);
                          return;
                        }
                        navigator.pop();
                        if (server.id != currentServerId) {
                          router.go('/s/${server.id}/overview');
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppTokens.s16),
              SplitListGroup(
                children: [
                  SplitListTile(
                    leading: const Icon(TablerIcons.plus),
                    title: l10n.servers_add,
                    onTap: () {
                      final navigator = Navigator.of(context);
                      final router = GoRouter.of(context);
                      navigator.pop();
                      router.push('/servers/add');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
