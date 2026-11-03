import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/theme/tokens.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../providers/app_settings_provider.dart';
import '../../../common/formatters/value_labels.dart';

class AppSettingsPage extends ConsumerStatefulWidget {
  const AppSettingsPage({super.key});

  @override
  ConsumerState<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends ConsumerState<AppSettingsPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => _version = '${info.version}+${info.buildNumber}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = ref.watch(themeControllerProvider);
    final settings = ref.watch(appSettingsControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBarLarge(title: l10n.settings_title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          0,
          AppTokens.s16,
          AppTokens.s40,
        ),
        children: [
          SectionHeader(title: l10n.settings_appearance),
          TonalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settings_theme_mode, style: AppTextStyles.bodyM),
                const SizedBox(height: AppTokens.s8),
                SegmentedTabs(
                  labels: [
                    l10n.common_systemDefault,
                    l10n.settings_appearance_modeLight,
                    l10n.settings_appearance_modeDark,
                  ],
                  selectedIndex: theme.mode.index,
                  scrollable: false,
                  onChanged: (index) => ref
                      .read(themeControllerProvider.notifier)
                      .setMode(AppThemeMode.values[index]),
                ),
                const SizedBox(height: AppTokens.s20),
                Text(l10n.settings_accent, style: AppTextStyles.bodyM),
                const SizedBox(height: AppTokens.s8),
                Wrap(
                  spacing: AppTokens.s12,
                  runSpacing: AppTokens.s12,
                  children: [
                    for (final preset in AccentPreset.values)
                      _AccentSwatch(
                        color: preset.color,
                        selected: theme.accent == preset,
                        onTap: () => ref
                            .read(themeControllerProvider.notifier)
                            .setAccent(preset),
                      ),
                  ],
                ),
                const SizedBox(height: AppTokens.s8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settings_dynamic_color),
                  subtitle: Text(
                    l10n.settings_dynamic_color_hint,
                    style: AppTextStyles.bodyS.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                  value: theme.dynamicColor,
                  onChanged: (value) => ref
                      .read(themeControllerProvider.notifier)
                      .setDynamicColor(value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settings_oled),
                  value: theme.oled,
                  onChanged: (value) =>
                      ref.read(themeControllerProvider.notifier).setOled(value),
                ),
                const SizedBox(height: AppTokens.s8),
                Text(
                  '${l10n.settings_text_scale} ${theme.textScale.toStringAsFixed(2)}×',
                  style: AppTextStyles.bodyM,
                ),
                Slider(
                  value: theme.textScale,
                  min: 0.9,
                  max: 1.25,
                  divisions: 7,
                  label: '${theme.textScale.toStringAsFixed(2)}×',
                  onChanged: (value) => ref
                      .read(themeControllerProvider.notifier)
                      .setTextScale(value),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s24),
          SectionHeader(title: l10n.settings_interaction),
          SplitListGroup(
            children: [
              SwitchListTile(
                title: Text(l10n.settings_haptics),
                value: settings?.hapticsEnabled ?? true,
                onChanged: (value) => ref
                    .read(appSettingsControllerProvider.notifier)
                    .setHapticsEnabled(value),
              ),
              SwitchListTile(
                title: Text(l10n.settings_list_animations),
                value: settings?.listAnimationsEnabled ?? true,
                onChanged: (value) => ref
                    .read(appSettingsControllerProvider.notifier)
                    .setListAnimationsEnabled(value),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s24),
          SectionHeader(title: l10n.settings_security),
          SplitListGroup(
            children: [
              SwitchListTile(
                title: Text(l10n.settings_secure_screen),
                value: settings?.secureScreenEnabled ?? false,
                onChanged: (value) => ref
                    .read(appSettingsControllerProvider.notifier)
                    .setSecureScreenEnabled(value),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s24),
          SectionHeader(title: l10n.settings_about),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.info_circle),
                title: l10n.settings_version,
                subtitle: displayValue(context, _version),
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.license),
                title: l10n.settings_licenses,
                trailing: const Icon(TablerIcons.chevron_right),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'OneDash',
                  applicationVersion: _version,
                ),
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.shield_lock),
                title: l10n.settings_privacy,
                subtitle: 'GPL-3.0 · ${l10n.settings_localOnly}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final checkColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.rFull),
      child: SizedBox(
        width: AppTokens.minTapTarget,
        height: AppTokens.minTapTarget,
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? context.scheme.onSurface : Colors.transparent,
                width: 2,
              ),
            ),
            child: selected
                ? Icon(TablerIcons.check, size: 20, color: checkColor)
                : null,
          ),
        ),
      ),
    );
  }
}
