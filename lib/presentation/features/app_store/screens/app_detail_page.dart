import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/app/app_detail_dto.dart';
import '../../../../data/dto/app/app_installed_check_req.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/error_toast.dart';
import '../providers/app_store_provider.dart';
import '../widgets/app_install_sheet.dart';

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
          padding: const EdgeInsets.all(AppTokens.s16),
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
                  const SizedBox(height: AppTokens.s12),
                  Wrap(
                    spacing: AppTokens.s8,
                    runSpacing: AppTokens.s8,
                    children: [
                      for (final version in app.versions)
                        Chip(label: Text(version)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s24),
            SplitListGroup(
              children: [
                SplitListTile(title: l10n.appStore_appKey, subtitle: app.key),
                SplitListTile(
                  title: l10n.panelSettings_type,
                  subtitle: app.type,
                ),
                SplitListTile(
                  title: l10n.websites_website,
                  subtitle: app.website,
                ),
                SplitListTile(title: 'GitHub', subtitle: app.github),
                SplitListTile(
                  title: l10n.appStore_installed,
                  subtitle: app.installed ? l10n.common_yes : l10n.common_no,
                ),
              ],
            ),
            if (app.readMe.isNotEmpty) ...[
              const SizedBox(height: AppTokens.s24),
              TonalCard(child: Text(app.readMe, style: AppTextStyles.bodyS)),
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
    await showAppSheet<bool>(
      context: context,
      maxHeightFactor: 0.95,
      builder: (_) => AppInstallSheet(app: app),
    );
  }
}
