import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/app/app_catalog_dto.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/search_field.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../providers/app_store_provider.dart';

class AppStorePage extends ConsumerStatefulWidget {
  const AppStorePage({super.key, required this.serverId, this.initialTab = 0});

  final int serverId;
  final int initialTab;

  @override
  ConsumerState<AppStorePage> createState() => _AppStorePageState();
}

class _AppStorePageState extends ConsumerState<AppStorePage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.apps_title,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () {
              ref.invalidate(appCatalogProvider(_query));
              ref.invalidate(installedAppsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.s16,
              vertical: AppTokens.s8,
            ),
            child: SearchField(
              controller: _searchController,
              hint: l10n.apps_search_hint,
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
          ),
          Expanded(
            child: SegmentedTabsView(
              initialIndex: widget.initialTab,
              labels: [l10n.apps_title, l10n.apps_installed],
              children: [
                _CatalogTab(serverId: widget.serverId, query: _query),
                _InstalledTab(serverId: widget.serverId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogTab extends ConsumerWidget {
  const _CatalogTab({required this.serverId, required this.query});

  final int serverId;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(appCatalogProvider(query));
    return AsyncStateView(
      value: catalog,
      onRetry: () => ref.invalidate(appCatalogProvider(query)),
      loading: const SkeletonList(itemCount: 8),
      isEmpty: (data) => data.items.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.apps,
        title: l10n.apps_title,
        message: l10n.apps_search_hint,
      ),
      builder: (data) => GridView.builder(
        padding: const EdgeInsets.all(AppTokens.s16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppTokens.s12,
          crossAxisSpacing: AppTokens.s12,
          childAspectRatio: 1.45,
        ),
        itemCount: data.items.length,
        itemBuilder: (context, index) {
          final app = data.items[index];
          return _AppCard(
            app: app,
            onTap: () => context.push(
              '/s/$serverId/more/apps/${Uri.encodeComponent(app.key)}',
            ),
          );
        },
      ),
    );
  }
}

class _InstalledTab extends ConsumerWidget {
  const _InstalledTab({required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final installed = ref.watch(installedAppsProvider);
    return AsyncStateView(
      value: installed,
      onRetry: () => ref.invalidate(installedAppsProvider),
      loading: const SkeletonList(itemCount: 8),
      isEmpty: (data) => data.items.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.package,
        title: l10n.apps_installed,
        message: l10n.apps_search_hint,
      ),
      builder: (data) => ListView.builder(
        padding: const EdgeInsets.all(AppTokens.s16),
        itemCount: data.items.length,
        itemBuilder: (context, index) {
          final app = data.items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.s12),
            child: TonalCard(
              onTap: () =>
                  context.push('/s/$serverId/more/apps/installed/${app.id}'),
              child: Row(
                children: [
                  StatusDot(status: app.status.toLowerCase()),
                  const SizedBox(width: AppTokens.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.displayName,
                          style: AppTextStyles.titleM,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${app.version} · ${app.httpPort}',
                          style: AppTextStyles.bodyS.copyWith(
                            color: context.scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (app.canUpdate)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.s8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.warning.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(AppTokens.rXs),
                      ),
                      child: Text(
                        l10n.apps_update_available,
                        style: AppTextStyles.caption.copyWith(
                          color: context.appColors.warning,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({required this.app, required this.onTap});

  final AppCatalogDto app;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return TonalCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTokens.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppTokens.rSm),
                ),
                child: Center(
                  child: Text(
                    app.name.isEmpty ? '?' : app.name.substring(0, 1),
                    style: AppTextStyles.titleS.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.s8),
              Expanded(
                child: Text(
                  app.name,
                  style: AppTextStyles.titleS,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (app.installed)
                Icon(
                  TablerIcons.circle_check,
                  size: 16,
                  color: context.appColors.success,
                ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Text(
            app.description,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            app.versions.isEmpty ? '-' : app.versions.first,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
