import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/repositories_impl/setting_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

class PanelUpgradePage extends ConsumerStatefulWidget {
  const PanelUpgradePage({super.key});

  @override
  ConsumerState<PanelUpgradePage> createState() => _PanelUpgradePageState();
}

class _PanelUpgradePageState extends ConsumerState<PanelUpgradePage> {
  Map<String, dynamic> _info = const {};
  List<Map<String, dynamic>> _releases = const [];
  bool _loading = true;
  bool _loadFailed = false;
  bool _upgrading = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final results = await Future.wait([
        repository.getUpgradeInfo(),
        repository.getUpgradeReleases(),
      ]);
      if (!mounted) return;
      setState(() {
        _info = results[0] as Map<String, dynamic>;
        _releases = results[1] as List<Map<String, dynamic>>;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadFailed = true);
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _upgrade(String version) async {
    final l10n = AppLocalizations.of(context);
    if (version.isEmpty) return;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.panelSettings_upgradeTo(version),
      message: l10n.panelSettings_upgradeConfirm(version),
      confirmLabel: l10n.action_confirm,
      requireText: version,
    );
    if (!confirmed || !mounted) return;
    setState(() => _upgrading = true);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.upgradePanel(version);
      if (!mounted) return;
      AppToast.success(context, l10n.panelSettings_upgradeSubmitted);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _upgrading = false);
    }
  }

  Future<void> _showNotes(String version) async {
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final notes = await repository.getUpgradeNotes(version);
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.85,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(version, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s12),
            Flexible(
              child: SingleChildScrollView(
                child: SelectableText(notes, style: AppTextStyles.bodyS),
              ),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final newVersion = '${_info['newVersion'] ?? ''}';
    final latestVersion = '${_info['latestVersion'] ?? ''}';
    final testVersion = '${_info['testVersion'] ?? ''}';
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.panelSettings_panelUpgrade,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _loading || _upgrading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadFailed
          ? EmptyState(
              icon: TablerIcons.alert_triangle,
              title: l10n.panelSettings_loadFailed,
              actionLabel: l10n.action_retry,
              onAction: _load,
            )
          : ListView(
              padding: EdgeInsets.all(context.pagePadding),
              children: [
                SectionHeader(title: l10n.panelSettings_panelUpgrade),
                TonalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        newVersion.isEmpty
                            ? l10n.panelSettings_upToDate
                            : l10n.panelSettings_upgradeAvailable,
                        style: AppTextStyles.titleM,
                      ),
                      if (latestVersion.isNotEmpty) ...[
                        const SizedBox(height: AppTokens.s4),
                        Text(
                          '${l10n.panelSettings_latestVersion}: $latestVersion',
                          style: AppTextStyles.bodyS,
                        ),
                      ],
                      if (testVersion.isNotEmpty) ...[
                        const SizedBox(height: AppTokens.s4),
                        Text(
                          '${l10n.panelSettings_testVersion}: $testVersion',
                          style: AppTextStyles.bodyS,
                        ),
                      ],
                      if (newVersion.isNotEmpty) ...[
                        const SizedBox(height: AppTokens.s16),
                        PrimaryButton(
                          label: l10n.panelSettings_upgradeTo(newVersion),
                          icon: TablerIcons.rocket,
                          loading: _upgrading,
                          onPressed: () => _upgrade(newVersion),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.s24),
                SectionHeader(title: l10n.panelSettings_releaseNotesTitle),
                if (_releases.isEmpty)
                  EmptyState(
                    icon: TablerIcons.notes,
                    title: l10n.panelSettings_noReleaseNotes,
                    compact: true,
                  ),
                for (final release in _releases)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.s8),
                    child: TonalCard(
                      onTap: () => _showNotes('${release['version'] ?? ''}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${release['version'] ?? ''}',
                                  style: AppTextStyles.titleS,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  formatListTime(
                                    DateTime.tryParse(
                                      '${release['createdAt'] ?? ''}',
                                    ),
                                    l10n,
                                    fallback: '${release['createdAt'] ?? ''}',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption.copyWith(
                                    color: context.scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTokens.s4),
                          Text(
                            [
                              l10n.panelSettings_newCount(
                                '${release['newCount'] ?? 0}',
                              ),
                              l10n.panelSettings_fixCount(
                                '${release['fixCount'] ?? 0}',
                              ),
                              l10n.panelSettings_optimizationCount(
                                '${release['optimizationCount'] ?? 0}',
                              ),
                            ].join(' · '),
                            style: AppTextStyles.bodyS.copyWith(
                              color: context.scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
