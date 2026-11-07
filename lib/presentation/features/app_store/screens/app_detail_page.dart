import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/app/app_detail_dto.dart';
import '../../../../data/dto/app/app_installed_check_req.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_icon.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/simple_markdown.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/error_toast.dart';
import '../providers/app_store_provider.dart';
import '../widgets/app_install_sheet.dart';

/// Opens an app's detail as a sheet above the app store list.
Future<void> showAppDetailSheet(
  BuildContext context, {
  required int serverId,
  required String appId,
}) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.92,
    builder: (_) => _AppDetailSheet(serverId: serverId, appId: appId),
  );
}

class _AppDetailSheet extends ConsumerWidget {
  const _AppDetailSheet({required this.serverId, required this.appId});

  final int serverId;
  final String appId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(appDetailProvider(appId));
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: l10n.action_close,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(TablerIcons.x),
            ),
          ),
          Expanded(
            child: AsyncStateView(
              value: detail,
              onRetry: () => ref.invalidate(appDetailProvider(appId)),
              builder: (app) => _AppDetailBody(serverId: serverId, app: app),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppDetailBody extends ConsumerWidget {
  const _AppDetailBody({required this.serverId, required this.app});

  final int serverId;
  final AppDetailDto app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tags = app.tags
        .map((tag) => tag.name)
        .where((name) => name.trim().isNotEmpty)
        .toList(growable: false);
    final latest = app.versions.isEmpty ? '-' : app.versions.first;
    final links = <(String, IconData, String)>[
      if (app.website.trim().isNotEmpty)
        (l10n.app_detail_website, TablerIcons.world, app.website),
      if (app.github.trim().isNotEmpty)
        (l10n.app_detail_github, TablerIcons.brand_github, app.github),
      if (app.document.trim().isNotEmpty)
        (l10n.app_detail_docs, TablerIcons.book, app.document),
    ];
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        TonalCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIcon(
                name: app.name,
                icon: app.icon,
                size: 56,
                cacheKey: '$serverId:${app.key}',
                iconLoader: () => ref
                    .read(appRepositoryProvider.future)
                    .then((repository) => repository.getAppIcon(app.key)),
              ),
              const SizedBox(width: AppTokens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: AppTextStyles.titleM,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: AppTokens.s8),
                      Wrap(
                        spacing: AppTokens.s8,
                        runSpacing: AppTokens.s8,
                        children: [
                          for (final tag in tags)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTokens.s8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  AppTokens.rFull,
                                ),
                              ),
                              child: Text(tag, style: AppTextStyles.caption),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.s8),
              PrimaryButton(
                label: app.installed ? l10n.apps_installed : l10n.apps_install,
                icon: app.installed
                    ? TablerIcons.circle_check
                    : TablerIcons.download,
                expanded: false,
                onPressed: app.installed
                    ? null
                    : () => _installApp(context, ref, app),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.s16),
        SplitListGroup(
          children: [
            SplitListTile(title: l10n.appStore_appKey, value: app.key),
            SplitListTile(
              title: l10n.app_detail_arch,
              value: app.architectures.isEmpty ? '-' : app.architectures,
            ),
            SplitListTile(
              title: l10n.app_detail_gpu,
              value: app.gpuSupport ? l10n.common_yes : l10n.common_no,
            ),
            SplitListTile(title: l10n.app_detail_latestVersion, value: latest),
          ],
        ),
        if (links.isNotEmpty) ...[
          const SizedBox(height: AppTokens.s16),
          Wrap(
            spacing: AppTokens.s8,
            runSpacing: AppTokens.s8,
            children: [
              for (final link in links)
                SecondaryButton(
                  label: link.$1,
                  icon: link.$2,
                  expanded: false,
                  onPressed: () => _openUrl(context, link.$3),
                ),
            ],
          ),
        ],
        if (app.readMe.isNotEmpty) ...[
          const SizedBox(height: AppTokens.s24),
          SectionHeader(title: l10n.app_detail_intro),
          const SizedBox(height: AppTokens.s8),
          TonalCard(child: SimpleMarkdown(data: app.readMe)),
        ],
        const SizedBox(height: AppTokens.s24),
      ],
    );
  }
}

Future<void> _openUrl(BuildContext context, String url) async {
  if (url.trim().isEmpty) return;
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> _installApp(
  BuildContext context,
  WidgetRef ref,
  AppDetailDto app,
) async {
  final l10n = AppLocalizations.of(context);
  try {
    final repository = await ref.read(appRepositoryProvider.future);
    final check = await repository.checkAppInstalled(
      AppInstalledCheckReq(key: app.key, name: app.name),
    );
    if (!context.mounted) return;
    if (check.isExist) {
      AppToast.warning(context, l10n.apps_alreadyInstalled);
      return;
    }
  } catch (error) {
    if (!context.mounted) return;
    showErrorToast(context, error);
    return;
  }
  if (!context.mounted) return;
  await showAppInstallPage(context, app);
}

class AppDetailPage extends ConsumerWidget {
  const AppDetailPage({super.key, required this.serverId, required this.appId});

  final int serverId;
  final String appId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(appDetailProvider(appId));
    return Scaffold(
      appBar: AppBarLarge(title: detail.valueOrNull?.name ?? l10n.apps_title),
      body: AsyncStateView(
        value: detail,
        onRetry: () => ref.invalidate(appDetailProvider(appId)),
        builder: (app) => ListView(
          padding: EdgeInsets.all(context.pagePadding),
          children: [
            TonalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(app.name, style: AppTextStyles.titleL),
                  const SizedBox(height: AppTokens.s8),
                  Text(
                    app.shortDescZh.isEmpty ? app.description : app.shortDescZh,
                    style: AppTextStyles.bodyM.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s24),
            SplitListGroup(
              children: [
                SplitListTile(title: l10n.appStore_appKey, value: app.key),
                SplitListTile(title: l10n.panelSettings_type, value: app.type),
                SplitListTile(title: l10n.websites_website, value: app.website),
                SplitListTile(title: 'GitHub', value: app.github),
                SplitListTile(
                  title: l10n.appStore_installed,
                  value: app.installed ? l10n.common_yes : l10n.common_no,
                ),
              ],
            ),
            if (app.readMe.isNotEmpty) ...[
              const SizedBox(height: AppTokens.s24),
              TonalCard(child: SimpleMarkdown(data: app.readMe)),
            ],
            const SizedBox(height: AppTokens.s24),
            PrimaryButton(
              label: app.installed ? l10n.apps_installed : l10n.apps_install,
              icon: app.installed
                  ? TablerIcons.circle_check
                  : TablerIcons.download,
              onPressed: app.installed
                  ? null
                  : () => _install(context, ref, app),
            ),
            const SizedBox(height: AppTokens.s32),
          ],
        ),
      ),
    );
  }

  Future<void> _install(
    BuildContext context,
    WidgetRef ref,
    AppDetailDto app,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final check = await repository.checkAppInstalled(
        AppInstalledCheckReq(key: app.key, name: app.name),
      );
      if (!context.mounted) return;
      if (check.isExist) {
        AppToast.warning(context, l10n.apps_alreadyInstalled);
        return;
      }
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
      return;
    }
    if (!context.mounted) return;
    await showAppInstallPage(context, app);
  }
}
