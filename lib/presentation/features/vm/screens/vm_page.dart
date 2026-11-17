import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/repositories_impl/vm_repository_impl.dart';
import '../../../../domain/repositories/vm_repository.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_bar_actions.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../widgets/vm_resources_sheet.dart';

final vmEnvironmentProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final repository = await ref.watch(vmRepositoryProvider.future);
  return repository.checkEnvironment();
}, name: 'vmEnvironmentProvider');

final vmListProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final repository = await ref.watch(vmRepositoryProvider.future);
  return repository.searchVms();
}, name: 'vmListProvider');

final vmNetworksProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final repository = await ref.watch(vmRepositoryProvider.future);
      return repository.listNetworks();
    }, name: 'vmNetworksProvider');

Future<void> _showOrphans(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  try {
    final repository = await ref.read(vmRepositoryProvider.future);
    final items = await repository.scanOrphans();
    if (!context.mounted) return;
    if (items.isEmpty) {
      AppToast.success(context, l10n.vm_orphansEmpty);
      return;
    }
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.vm_orphans,
      message: l10n.vm_cleanConfirm(items.length),
      confirmLabel: l10n.vm_orphansClean,
    );
    if (!confirmed || !context.mounted) return;
    await repository.cleanOrphans(items);
    if (!context.mounted) return;
    AppToast.success(context, l10n.action_done);
  } catch (error) {
    if (!context.mounted) return;
    showErrorToast(context, error);
  }
}

class VmPage extends ConsumerWidget {
  const VmPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final environment = ref.watch(vmEnvironmentProvider);
    final ready = environment.valueOrNull?['ready'] == true;
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.vm_title,
        subtitle: l10n.vm_subtitle,
        actions: [
          AppBarActions(
            actions: [
              AppBarAction(
                icon: TablerIcons.refresh,
                tooltip: l10n.action_refresh,
                onPressed: () {
                  ref.invalidate(vmEnvironmentProvider);
                  ref.invalidate(vmListProvider);
                },
              ),
              if (ready)
                AppBarAction(
                  icon: TablerIcons.trash,
                  tooltip: l10n.vm_orphansScan,
                  onPressed: () => _showOrphans(context, ref),
                ),
              if (ready)
                AppBarAction(
                  icon: TablerIcons.stack_2,
                  tooltip: l10n.vm_resources,
                  onPressed: () => showVmResourcesSheet(context),
                ),
              if (ready)
                AppBarAction(
                  icon: TablerIcons.arrows_exchange,
                  tooltip: l10n.vm_sync,
                  onPressed: () async {
                    try {
                      final repository = await ref.read(
                        vmRepositoryProvider.future,
                      );
                      await repository.syncVms();
                      if (!context.mounted) return;
                      ref.invalidate(vmListProvider);
                    } catch (error) {
                      if (!context.mounted) return;
                      showErrorToast(context, error);
                    }
                  },
                ),
              if (ready)
                AppBarAction(
                  icon: TablerIcons.plus,
                  tooltip: l10n.vm_create,
                  onPressed: () => _createVm(context, ref),
                ),
            ],
          ),
        ],
      ),
      body: AsyncStateView(
        value: environment,
        onRetry: () => ref.invalidate(vmEnvironmentProvider),
        loading: const SkeletonList(itemCount: 5),
        builder: (env) {
          if (env['ready'] != true) {
            return _EnvironmentView(environment: env);
          }
          return _VmList(serverId: serverId);
        },
      ),
    );
  }

  Future<void> _createVm(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    List<Map<String, dynamic>> networks = const [];
    List<Map<String, dynamic>> templates = const [];
    List<Map<String, dynamic>> storages = const [];
    try {
      final repository = await ref.read(vmRepositoryProvider.future);
      networks = await repository.listNetworks();
      templates = await repository.listTemplates();
      storages = await repository.listStorages();
    } catch (_) {
      networks = const [];
    }
    if (!context.mounted) return;
    final names = networks
        .map((item) => '${item['name'] ?? ''}')
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    final storageNames = storages
        .map((item) => '${item['name'] ?? ''}')
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    final templateNames = templates
        .map((item) => '${item['name'] ?? ''}')
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    final name = TextEditingController();
    final cpu = TextEditingController(text: '2');
    final memory = TextEditingController(text: '2048');
    final disk = TextEditingController(text: '20');
    final description = TextEditingController();
    var network = names.isEmpty ? '' : names.first;
    var storagePool = storageNames.isEmpty ? '' : storageNames.first;
    var template = '';
    var osType = 'linux';
    var startAfter = true;
    final saved = await pushFormPage<bool>(
      context,
      StatefulBuilder(
        builder: (pageContext, setState) => SimpleFormPage(
          title: l10n.vm_create,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(controller: name, label: l10n.vm_name),
            const SizedBox(height: AppTokens.s12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: cpu,
                    label: l10n.vm_cpu,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: AppTextField(
                    controller: memory,
                    label: l10n.vm_memory,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: disk,
              label: l10n.vm_disk,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: names.contains(network) ? network : null,
              decoration: InputDecoration(labelText: l10n.vm_network),
              items: [
                for (final item in names)
                  DropdownMenuItem(value: item, child: Text(item)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => network = value);
              },
            ),
            const SizedBox(height: AppTokens.s12),
            if (storageNames.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: storagePool,
                decoration: InputDecoration(labelText: l10n.vm_storagePool),
                items: [
                  for (final item in storageNames)
                    DropdownMenuItem(value: item, child: Text(item)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => storagePool = value);
                },
              ),
            if (storageNames.isNotEmpty) const SizedBox(height: AppTokens.s12),
            if (templateNames.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: template.isEmpty ? null : template,
                decoration: InputDecoration(labelText: l10n.vm_template),
                items: [
                  for (final item in templateNames)
                    DropdownMenuItem(value: item, child: Text(item)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => template = value);
                },
              ),
            if (templateNames.isNotEmpty) const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: osType,
              decoration: InputDecoration(labelText: l10n.vm_osType),
              items: [
                DropdownMenuItem(value: 'linux', child: Text(l10n.vm_osLinux)),
                DropdownMenuItem(
                  value: 'windows',
                  child: Text(l10n.vm_osWindows),
                ),
                DropdownMenuItem(value: 'other', child: Text(l10n.vm_osOther)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => osType = value);
              },
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: description,
              label: l10n.vm_description,
              maxLines: 3,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.vm_startAfterCreate),
              value: startAfter,
              onChanged: (value) => setState(() => startAfter = value),
            ),
          ],
        ),
      ),
    );
    final body = <String, dynamic>{
      'taskID': const Uuid().v4(),
      'name': name.text.trim(),
      'cpu': int.tryParse(cpu.text.trim()) ?? 0,
      'memory': int.tryParse(memory.text.trim()) ?? 0,
      'diskSize': int.tryParse(disk.text.trim()) ?? 0,
      'osType': osType,
      'network': network,
      'bootOrder': 'cdrom,hd',
      'storagePool': storagePool,
      'templateID':
          templates
              .where((item) => '${item['name'] ?? ''}' == template)
              .map((item) => (item['id'] as num?)?.toInt() ?? 0)
              .firstOrNull ??
          0,
      'startAfterCreate': startAfter,
      'autoStart': false,
      'description': description.text.trim(),
    };
    name.dispose();
    cpu.dispose();
    memory.dispose();
    disk.dispose();
    description.dispose();
    if (saved != true || !context.mounted || network.isEmpty) return;
    try {
      final repository = await ref.read(vmRepositoryProvider.future);
      await repository.createVm(body);
      if (!context.mounted) return;
      ref.invalidate(vmListProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _EnvironmentView extends ConsumerWidget {
  const _EnvironmentView({required this.environment});

  final Map<String, dynamic> environment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = [
      (
        l10n.vm_arch,
        '${environment['arch'] ?? ''}',
        environment['archSupported'] == true,
      ),
      (l10n.vm_kvm, '', environment['kvmExist'] == true),
      (l10n.vm_libvirt, '', environment['libvirtActive'] == true),
      (l10n.vm_storage, '', environment['storageExist'] == true),
    ];
    return ListView(
      padding: EdgeInsets.all(context.pagePadding),
      children: [
        TonalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.vm_envNotReady, style: AppTextStyles.titleM),
              const SizedBox(height: AppTokens.s8),
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.s4),
                  child: Row(
                    children: [
                      Icon(
                        item.$3
                            ? TablerIcons.circle_check
                            : TablerIcons.circle_x,
                        size: AppTokens.iconList,
                        color: item.$3
                            ? context.appColors.success
                            : context.scheme.error,
                      ),
                      const SizedBox(width: AppTokens.s8),
                      Text(item.$1, style: AppTextStyles.bodyM),
                      if (item.$2.isNotEmpty) ...[
                        const SizedBox(width: AppTokens.s8),
                        Text(
                          item.$2,
                          style: AppTextStyles.caption.copyWith(
                            color: context.scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.s16),
        PrimaryButton(
          label: l10n.vm_enable,
          icon: TablerIcons.power,
          onPressed: () async {
            try {
              final repository = await ref.read(vmRepositoryProvider.future);
              await repository.enableEnvironment();
              if (!context.mounted) return;
              ref.invalidate(vmEnvironmentProvider);
              AppToast.success(context, l10n.vm_enabled);
            } catch (error) {
              if (!context.mounted) return;
              showErrorToast(context, error);
            }
          },
        ),
      ],
    );
  }
}

class _VmList extends ConsumerWidget {
  const _VmList({required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final vms = ref.watch(vmListProvider);
    return AsyncStateView(
      value: vms,
      onRetry: () => ref.invalidate(vmListProvider),
      loading: const SkeletonList(itemCount: 5),
      isEmpty: (data) => (data['items'] as List?)?.isEmpty ?? true,
      empty: EmptyState(
        icon: TablerIcons.device_desktop,
        title: l10n.vm_empty,
        message: l10n.vm_emptyHint,
      ),
      builder: (data) {
        final items = (data['items'] as List? ?? const [])
            .whereType<Map>()
            .map((item) => item.cast<String, dynamic>())
            .toList(growable: false);
        final limit = (data['limit'] as num?)?.toInt() ?? 0;
        return ListView(
          padding: EdgeInsets.all(context.pagePadding),
          children: [
            if (limit > 0) ...[
              Text(
                l10n.vm_limit('$limit'),
                style: AppTextStyles.caption.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTokens.s12),
            ],
            for (final vm in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.s12),
                child: _VmCard(serverId: serverId, vm: vm),
              ),
          ],
        );
      },
    );
  }
}

class _VmCard extends ConsumerWidget {
  const _VmCard({required this.serverId, required this.vm});

  final int serverId;
  final Map<String, dynamic> vm;

  String get name => '${vm['name'] ?? ''}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = '${vm['status'] ?? ''}';
    return TonalCard(
      onTap: () => _showActions(context, ref),
      child: Row(
        children: [
          Icon(
            TablerIcons.device_desktop,
            size: AppTokens.iconList,
            color: status == 'running'
                ? context.appColors.success
                : context.scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleM),
                Text(
                  [
                    status,
                    '${vm['cpu'] ?? 0} vCPU',
                    formatBytes(
                      ((vm['memory'] as num?)?.toInt() ?? 0) * 1024 * 1024,
                    ),
                    '${vm['diskSize'] ?? 0} GB',
                    if ('${vm['network'] ?? ''}'.isNotEmpty) '${vm['network']}',
                  ].join(' · '),
                  style: AppTextStyles.caption.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final value = await showSelectionMenu<String>(
      context,
      title: name,
      options: [
        SelectionOption(
          label: l10n.vm_start,
          value: 'start',
          icon: TablerIcons.player_play,
        ),
        SelectionOption(
          label: l10n.vm_shutdown,
          value: 'shutdown',
          icon: TablerIcons.power,
        ),
        SelectionOption(
          label: l10n.vm_reboot,
          value: 'reboot',
          icon: TablerIcons.refresh,
        ),
        SelectionOption(
          label: l10n.vm_suspend,
          value: 'suspend',
          icon: TablerIcons.player_pause,
        ),
        SelectionOption(
          label: l10n.vm_resume,
          value: 'resume',
          icon: TablerIcons.player_play,
        ),
        SelectionOption(
          label: l10n.vm_destroy,
          value: 'destroy',
          icon: TablerIcons.player_stop,
        ),
        SelectionOption(
          label: l10n.vm_update,
          value: 'update',
          icon: TablerIcons.edit,
        ),
        SelectionOption(
          label: l10n.vm_rename,
          value: 'rename',
          icon: TablerIcons.forms,
        ),
        SelectionOption(
          label: l10n.vm_resizeDisk,
          value: 'resize',
          icon: TablerIcons.resize,
        ),
        SelectionOption(
          label: l10n.vm_healthCheck,
          value: 'health',
          icon: TablerIcons.stethoscope,
        ),
        SelectionOption(
          label: l10n.vm_stats,
          value: 'stats',
          icon: TablerIcons.chart_line,
        ),
        SelectionOption(
          label: l10n.vm_console,
          value: 'console',
          icon: TablerIcons.device_desktop,
        ),
        SelectionOption(
          label: l10n.vm_snapshots,
          value: 'snapshots',
          icon: TablerIcons.camera,
        ),
        SelectionOption(
          label: l10n.vm_delete,
          value: 'delete',
          icon: TablerIcons.trash,
          danger: true,
        ),
      ],
    );
    if (value == null || !context.mounted) return;
    try {
      final repository = await ref.read(vmRepositoryProvider.future);
      if (!context.mounted) return;
      if (value == 'console') {
        await context.push(
          '/s/$serverId/more/vms/console?name=${Uri.encodeComponent(name)}',
        );
        return;
      }
      if (value == 'stats') {
        await _showStats(context, repository);
      } else if (value == 'resize') {
        await _resizeDisk(context, repository);
      } else if (value == 'health') {
        await _showHealth(context, repository);
      } else if (value == 'snapshots') {
        await _showSnapshots(context, ref, repository);
      } else if (value == 'update') {
        await _update(context, ref, repository);
      } else if (value == 'rename') {
        await _rename(context, ref, repository);
      } else if (value == 'delete') {
        await _delete(context, ref, repository);
      } else {
        if (value == 'destroy') {
          final confirmed = await showConfirmSheet(
            context,
            title: l10n.vm_destroy,
            message: l10n.vm_forceStopConfirm(name),
            confirmLabel: l10n.vm_destroy,
            danger: true,
          );
          if (!confirmed || !context.mounted) return;
        }
        await repository.operateVm(name, value);
        if (!context.mounted) return;
        ref.invalidate(vmListProvider);
      }
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _resizeDisk(
    BuildContext context,
    VmRepository repository,
  ) async {
    final l10n = AppLocalizations.of(context);
    Map<String, dynamic> detail = const {};
    try {
      detail = await repository.getVm(name);
    } catch (_) {
      detail = const {};
    }
    if (!context.mounted) return;
    final target = TextEditingController(
      text: '${detail['diskTarget'] ?? 'vda'}',
    );
    final size = TextEditingController(text: '${detail['diskSize'] ?? ''}');
    final confirmed = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.vm_resizeDisk,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(controller: target, label: l10n.vm_diskTarget),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: size,
              label: l10n.vm_diskSizeNew,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
    final targetValue = target.text.trim();
    final sizeValue = int.tryParse(size.text.trim()) ?? 0;
    target.dispose();
    size.dispose();
    if (confirmed != true || targetValue.isEmpty || sizeValue <= 0) return;
    if (!context.mounted) return;
    try {
      await repository.resizeDisk(
        name: name,
        target: targetValue,
        sizeGiB: sizeValue,
        taskID: const Uuid().v4(),
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showHealth(
    BuildContext context,
    VmRepository repository,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final result = await repository.healthCheck(name);
      if (!context.mounted) return;
      final items = (result['items'] as List?) ?? const [];
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.vm_healthCheck, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s8),
            Text(
              '${l10n.vm_healthPass}: ${result['pass'] ?? 0} · '
              '${l10n.vm_healthWarn}: ${result['warn'] ?? 0} · '
              '${l10n.vm_healthFail}: ${result['fail'] ?? 0}',
              style: AppTextStyles.bodyS.copyWith(
                color: sheetContext.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.s12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final item in items.whereType<Map>())
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(switch ('${item['level']}') {
                        'fail' => TablerIcons.x,
                        'warn' => TablerIcons.alert_triangle,
                        _ => TablerIcons.check,
                      }),
                      title: Text('${item['check'] ?? ''}'),
                      subtitle: Text(
                        [
                          if ('${item['reason'] ?? ''}'.isNotEmpty)
                            '${item['reason']}',
                          if ('${item['detail'] ?? ''}'.isNotEmpty)
                            '${item['detail']}',
                        ].join(' · '),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _update(
    BuildContext context,
    WidgetRef ref,
    VmRepository repository,
  ) async {
    final l10n = AppLocalizations.of(context);
    final detail = await repository.getVm(name);
    if (!context.mounted) return;
    List<Map<String, dynamic>> networks = const [];
    try {
      networks = await repository.listNetworks();
    } catch (_) {
      networks = const [];
    }
    if (!context.mounted) return;
    final netNames = networks
        .map((item) => '${item['name'] ?? ''}')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    final cpu = TextEditingController(text: '${detail['cpu'] ?? 1}');
    final memory = TextEditingController(text: '${detail['memory'] ?? 1024}');
    final description = TextEditingController(
      text: '${detail['description'] ?? ''}',
    );
    var network = '${detail['network'] ?? ''}';
    var autoStart = detail['autoStart'] == true;
    final saved = await pushFormPage<bool>(
      context,
      StatefulBuilder(
        builder: (pageContext, setState) => SimpleFormPage(
          title: l10n.vm_update,
          subtitle: name,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(
              controller: cpu,
              label: l10n.vm_cpu,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: memory,
              label: l10n.vm_memory,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: netNames.contains(network) ? network : null,
              decoration: InputDecoration(labelText: l10n.vm_network),
              items: [
                for (final item in netNames)
                  DropdownMenuItem(value: item, child: Text(item)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => network = value);
              },
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: description,
              label: l10n.vm_description,
              maxLines: 3,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.vm_autoStart),
              value: autoStart,
              onChanged: (value) => setState(() => autoStart = value),
            ),
          ],
        ),
      ),
    );
    final body = <String, dynamic>{
      'taskID': const Uuid().v4(),
      'name': name,
      'cpu': int.tryParse(cpu.text.trim()) ?? 0,
      'memory': int.tryParse(memory.text.trim()) ?? 0,
      'network': network,
      'bootOrder': '${detail['bootOrder'] ?? 'cdrom,hd'}',
      'autoStart': autoStart,
      'description': description.text.trim(),
    };
    cpu.dispose();
    memory.dispose();
    description.dispose();
    if (saved != true || !context.mounted || network.isEmpty) return;
    await repository.updateVm(body);
    if (!context.mounted) return;
    ref.invalidate(vmListProvider);
    AppToast.success(context, l10n.action_done);
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    VmRepository repository,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: name);
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.vm_rename,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(controller: controller, label: l10n.vm_newName),
          ],
        ),
      ),
    );
    final newName = controller.text.trim();
    controller.dispose();
    if (saved != true ||
        !context.mounted ||
        newName.isEmpty ||
        newName == name) {
      return;
    }
    await repository.renameVm(
      name: name,
      newName: newName,
      taskID: const Uuid().v4(),
    );
    if (!context.mounted) return;
    ref.invalidate(vmListProvider);
    AppToast.success(context, l10n.action_done);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    VmRepository repository,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.vm_delete,
      message: l10n.vm_confirmDelete(name),
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !context.mounted) return;
    await repository.deleteVm(
      id: (vm['id'] as num?)?.toInt() ?? 0,
      taskID: const Uuid().v4(),
    );
    if (!context.mounted) return;
    ref.invalidate(vmListProvider);
    AppToast.success(context, l10n.action_done);
  }

  Future<void> _showStats(BuildContext context, VmRepository repository) async {
    final l10n = AppLocalizations.of(context);
    final stats = await repository.getVmStats(name);
    if (!context.mounted) return;
    final memory = switch (stats['memory']) {
      final Map value => value.cast<String, dynamic>(),
      _ => const <String, dynamic>{},
    };
    final disk = switch (stats['disk']) {
      final Map value => value.cast<String, dynamic>(),
      _ => const <String, dynamic>{},
    };
    final network = switch (stats['network']) {
      final Map value => value.cast<String, dynamic>(),
      _ => const <String, dynamic>{},
    };
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.vm_stats, style: AppTextStyles.titleM),
          const SizedBox(height: AppTokens.s12),
          Text('${stats['status'] ?? ''}', style: AppTextStyles.bodyM),
          const SizedBox(height: AppTokens.s8),
          Text(
            '${l10n.vm_statsCpu} ${stats['cpuTime'] ?? 0} · '
            '${stats['vcpu'] ?? 0} vCPU',
            style: AppTextStyles.bodyS,
          ),
          const SizedBox(height: AppTokens.s4),
          Text(
            '${l10n.vm_statsMemory} '
            '${formatBytes((memory['rssKiB'] as num?)?.toInt() ?? 0)}',
            style: AppTextStyles.bodyS,
          ),
          const SizedBox(height: AppTokens.s4),
          Text(
            '${l10n.vm_statsDisk} ${disk['readBytes'] ?? 0}/'
            '${disk['writeBytes'] ?? 0}',
            style: AppTextStyles.bodyS,
          ),
          const SizedBox(height: AppTokens.s4),
          Text(
            '${l10n.vm_statsNetwork} ${network['rxBytes'] ?? 0}/'
            '${network['txBytes'] ?? 0}',
            style: AppTextStyles.bodyS,
          ),
        ],
      ),
    );
  }

  Future<void> _showSnapshots(
    BuildContext context,
    WidgetRef ref,
    VmRepository repository,
  ) async {
    final l10n = AppLocalizations.of(context);
    final items = List<Map<String, dynamic>>.of(
      await repository.listSnapshots(name),
    );
    if (!context.mounted) return;
    await showAppSheet<void>(
      context: context,
      maxHeightFactor: 0.9,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.vm_snapshots, style: AppTextStyles.titleM),
                  ),
                  IconButton(
                    tooltip: l10n.vm_snapshotCreate,
                    icon: const Icon(TablerIcons.plus),
                    onPressed: () async {
                      final created = await _createSnapshot(
                        context,
                        repository,
                      );
                      if (!created) return;
                      final latest = await repository.listSnapshots(name);
                      setState(() {
                        items
                          ..clear()
                          ..addAll(latest);
                      });
                    },
                  ),
                  IconButton(
                    tooltip: l10n.action_close,
                    icon: const Icon(TablerIcons.x),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(child: Text(l10n.vm_snapshotEmpty))
                    : ListView(
                        children: [
                          for (final item in items)
                            ListTile(
                              dense: true,
                              title: Text('${item['name'] ?? ''}'),
                              subtitle: Text(
                                '${item['description'] ?? ''} ${item['state'] ?? ''}',
                              ),
                              onTap: () async {
                                final action = await showSelectionMenu<String>(
                                  context,
                                  title: '${item['name'] ?? ''}',
                                  options: [
                                    SelectionOption(
                                      label: l10n.vm_snapshotRecover,
                                      value: 'recover',
                                      icon: TablerIcons.restore,
                                    ),
                                    SelectionOption(
                                      label: l10n.vm_snapshotDelete,
                                      value: 'delete',
                                      icon: TablerIcons.trash,
                                      danger: true,
                                    ),
                                  ],
                                );
                                if (action == null || !context.mounted) return;
                                final snapshotName = '${item['name'] ?? ''}';
                                final confirmed = await showConfirmSheet(
                                  context,
                                  title: action == 'recover'
                                      ? l10n.vm_snapshotRecover
                                      : l10n.vm_snapshotDelete,
                                  message: action == 'recover'
                                      ? l10n.vm_snapshotRecoverConfirm(
                                          snapshotName,
                                        )
                                      : l10n.vm_snapshotDeleteConfirm(
                                          snapshotName,
                                        ),
                                  confirmLabel: action == 'recover'
                                      ? l10n.vm_snapshotRecover
                                      : l10n.action_delete,
                                  danger: action != 'recover',
                                );
                                if (!confirmed || !context.mounted) return;
                                try {
                                  if (action == 'recover') {
                                    await repository.recoverSnapshot(
                                      name: name,
                                      snapshotName: snapshotName,
                                      taskID: const Uuid().v4(),
                                    );
                                  } else {
                                    await repository.deleteSnapshot(
                                      name: name,
                                      snapshotName: snapshotName,
                                      taskID: const Uuid().v4(),
                                    );
                                  }
                                  if (!context.mounted) return;
                                  final latest = await repository.listSnapshots(
                                    name,
                                  );
                                  if (!context.mounted) return;
                                  setState(() {
                                    items
                                      ..clear()
                                      ..addAll(latest);
                                  });
                                } catch (error) {
                                  if (!context.mounted) return;
                                  showErrorToast(context, error);
                                }
                              },
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _createSnapshot(
    BuildContext context,
    VmRepository repository,
  ) async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final description = TextEditingController();
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.vm_snapshotCreate,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(
              controller: nameController,
              label: l10n.vm_snapshotName,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: description, label: l10n.vm_description),
          ],
        ),
      ),
    );
    final snapshotName = nameController.text.trim();
    final desc = description.text.trim();
    nameController.dispose();
    description.dispose();
    if (saved != true || !context.mounted || snapshotName.isEmpty) return false;
    await repository.createSnapshot(
      name: name,
      snapshotName: snapshotName,
      description: desc,
      taskID: const Uuid().v4(),
    );
    return true;
  }
}
