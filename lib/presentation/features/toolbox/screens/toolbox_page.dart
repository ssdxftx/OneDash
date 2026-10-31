import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/repositories_impl/toolbox_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';

class ToolboxData {
  const ToolboxData({
    required this.device,
    required this.fail2ban,
    required this.ftp,
    required this.clam,
  });

  final Map<String, dynamic> device;
  final Map<String, dynamic> fail2ban;
  final Map<String, dynamic> ftp;
  final Map<String, dynamic> clam;
}

final _toolboxProvider = FutureProvider.autoDispose<ToolboxData>((ref) async {
  final repository = await ref.watch(toolboxRepositoryProvider.future);
  final device = await repository.getDeviceBase();
  Future<Map<String, dynamic>> optional(
    Future<Map<String, dynamic>> future,
  ) async {
    try {
      return await future;
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  final results = await Future.wait([
    optional(repository.getFail2banBase()),
    optional(repository.getFtpBase()),
    optional(repository.getClamBase()),
  ]);
  return ToolboxData(
    device: device,
    fail2ban: results[0],
    ftp: results[1],
    clam: results[2],
  );
}, name: 'toolboxProvider');

class ToolboxPage extends ConsumerWidget {
  const ToolboxPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(_toolboxProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.toolbox_title,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_toolboxProvider),
          ),
        ],
      ),
      body: AsyncStateView(
        value: data,
        onRetry: () => ref.invalidate(_toolboxProvider),
        loading: const SkeletonList(itemCount: 8),
        builder: (value) => ListView(
          padding: const EdgeInsets.all(AppTokens.s16),
          children: [
            SectionHeader(title: l10n.toolbox_quickSettings),
            SplitListGroup(
              children: [
                _info(l10n.toolbox_hostname, value.device['hostname']),
                _info(l10n.toolbox_systemUser, value.device['user']),
                _info(l10n.toolbox_timeZone, value.device['timeZone']),
                _info(l10n.toolbox_localTime, value.device['localTime']),
                _info(
                  'DNS',
                  ((value.device['dns'] as List?) ?? const [])
                      .map((item) => '$item')
                      .join(', '),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s24),
            SectionHeader(title: l10n.toolbox_cacheClean),
            SplitListGroup(
              children: [
                _info(l10n.toolbox_cleanSource, l10n.toolbox_cleanSourceValue),
                _info(l10n.toolbox_cleanAction, l10n.toolbox_cleanActionValue),
                SplitListTile(
                  leading: const Icon(TablerIcons.scan),
                  title: l10n.toolbox_scan,
                  trailing: const Icon(TablerIcons.chevron_right),
                  onTap: () => _scan(context, ref),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s24),
            const SectionHeader(title: 'Fail2ban'),
            SplitListGroup(
              children: [
                _boolInfo(
                  l10n.toolbox_installed,
                  value.fail2ban['isExist'],
                  l10n,
                ),
                _boolInfo(
                  l10n.toolbox_running,
                  value.fail2ban['isActive'],
                  l10n,
                ),
                _boolInfo(
                  l10n.toolbox_enabled,
                  value.fail2ban['isEnable'],
                  l10n,
                ),
                _info(l10n.toolbox_version, value.fail2ban['version']),
                _info(l10n.toolbox_port, value.fail2ban['port']),
              ],
            ),
            const SizedBox(height: AppTokens.s24),
            const SectionHeader(title: 'FTP'),
            SplitListGroup(
              children: [
                _boolInfo(l10n.toolbox_installed, value.ftp['isExist'], l10n),
                _boolInfo(l10n.toolbox_running, value.ftp['isActive'], l10n),
              ],
            ),
            const SizedBox(height: AppTokens.s24),
            SectionHeader(title: l10n.toolbox_virusScan),
            SplitListGroup(
              children: [
                _boolInfo('ClamAV', value.clam['isExist'], l10n),
                _boolInfo(
                  l10n.toolbox_clamAvRunning,
                  value.clam['isActive'],
                  l10n,
                ),
                _boolInfo('FreshClam', value.clam['freshIsExist'], l10n),
                _boolInfo(
                  l10n.toolbox_freshClamRunning,
                  value.clam['freshIsActive'],
                  l10n,
                ),
                _info(l10n.toolbox_version, value.clam['version']),
                _info(l10n.toolbox_virusDatabase, value.clam['freshVersion']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, Object? value) {
    final text = value?.toString().trim() ?? '';
    return SplitListTile(title: label, subtitle: text.isEmpty ? '-' : text);
  }

  Widget _boolInfo(String label, Object? value, AppLocalizations l10n) {
    return _info(label, value == true ? l10n.common_yes : l10n.common_no);
  }

  Future<void> _scan(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      final data = await repository.scanClean();
      if (!context.mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.8,
        builder: (context) => _CleanScanSheet(data: data),
      );
    } catch (error) {
      if (!context.mounted) return;
      AppToast.error(context, '${l10n.toolbox_scanFailed}: $error');
    }
  }
}

class _CleanScanSheet extends StatelessWidget {
  const _CleanScanSheet({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groups = data.entries
        .map(
          (entry) =>
              MapEntry(entry.key, (entry.value as List?) ?? const <dynamic>[]),
        )
        .where((entry) => entry.value.isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.toolbox_cacheClean, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s16),
        if (groups.isEmpty)
          EmptyState(
            icon: TablerIcons.check,
            title: l10n.toolbox_noCleanItems,
            compact: true,
          )
        else
          for (final group in groups) ...[
            SectionHeader(title: _groupName(group.key, l10n)),
            SplitListGroup(
              children: [
                for (final item in group.value.whereType<Map>())
                  SplitListTile(
                    title:
                        '${item['label'] ?? item['name'] ?? item['path'] ?? '-'}',
                    subtitle: formatBytes(item['size']),
                  ),
              ],
            ),
            const SizedBox(height: AppTokens.s16),
          ],
      ],
    );
  }

  String _groupName(String key, AppLocalizations l10n) {
    return switch (key) {
      'systemClean' => l10n.toolbox_cleanGroupSystem,
      'backupClean' => l10n.toolbox_cleanGroupBackup,
      'uploadClean' => l10n.toolbox_cleanGroupUpload,
      'downloadClean' => l10n.toolbox_cleanGroupDownload,
      'systemLogClean' => l10n.toolbox_cleanGroupSystemLog,
      'containerClean' => l10n.toolbox_cleanGroupContainer,
      _ => key,
    };
  }
}
