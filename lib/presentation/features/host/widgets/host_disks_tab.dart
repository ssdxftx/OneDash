import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/host/disk_dto.dart';
import '../../../../data/repositories_impl/host_repository_impl.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

class HostDisksTab extends ConsumerStatefulWidget {
  const HostDisksTab({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<HostDisksTab> createState() => _HostDisksTabState();
}

class _HostDisksTabState extends ConsumerState<HostDisksTab> {
  CompleteDiskDto _disks = const CompleteDiskDto();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      final disks = await repository.getDisks();
      if (!mounted) return;
      setState(() => _disks = disks);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _unmount(DiskBasicDto partition) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.host_diskUnmount,
      message: '${partition.device}\n${partition.mountPoint}',
      confirmLabel: l10n.host_diskUnmount,
      requireText: partition.mountPoint,
    );
    if (!confirmed) return;
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      await repository.unmountDisk(partition.mountPoint);
      if (!mounted) return;
      AppToast.success(context, l10n.host_diskActionDone);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _partition(DiskBasicDto disk) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.host_diskPartition,
      message: '${disk.device}\n${l10n.host_diskPartitionWarning}',
      confirmLabel: l10n.host_diskPartition,
      requireText: disk.device,
    );
    if (!confirmed || !mounted) return;
    final result = await _showDiskForm(
      device: disk.device,
      partition: true,
      filesystem: '',
    );
    if (result == null) return;
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      await repository.partitionDisk(result);
      if (!mounted) return;
      AppToast.success(context, l10n.host_diskActionDone);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _mount(DiskBasicDto partition) async {
    final result = await _showDiskForm(
      device: partition.device,
      partition: false,
      filesystem: partition.filesystem,
    );
    if (result == null || !mounted) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.host_diskMount,
      message: '${result.device}\n${result.mountPoint}',
      confirmLabel: l10n.host_diskMount,
      danger: false,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      await repository.mountDisk(
        DiskMountReq(
          device: result.device,
          filesystem: result.filesystem,
          mountPoint: result.mountPoint,
          autoMount: result.autoMount,
        ),
      );
      if (!mounted) return;
      AppToast.success(context, l10n.host_diskActionDone);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<DiskPartitionReq?> _showDiskForm({
    required String device,
    required bool partition,
    required String filesystem,
  }) {
    final l10n = AppLocalizations.of(context);
    final mountPoint = TextEditingController();
    final label = TextEditingController();
    var fs = filesystem.isEmpty ? 'ext4' : filesystem;
    var autoMount = true;
    var noFail = true;
    return showAppSheet<DiskPartitionReq>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              partition ? l10n.host_diskPartition : l10n.host_diskMount,
              style: AppTextStyles.titleL,
            ),
            const SizedBox(height: AppTokens.s8),
            Text(
              device,
              style: AppTextStyles.bodyS.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.s16),
            DropdownButtonFormField<String>(
              initialValue: fs,
              decoration: InputDecoration(labelText: l10n.host_diskFilesystem),
              items: const [
                DropdownMenuItem(value: 'ext4', child: Text('ext4')),
                DropdownMenuItem(value: 'xfs', child: Text('xfs')),
              ],
              onChanged: partition || filesystem.isEmpty
                  ? (value) {
                      if (value != null) setSheetState(() => fs = value);
                    }
                  : null,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: mountPoint,
              label: l10n.host_diskMountPointField,
              autofocus: true,
            ),
            if (partition) ...[
              const SizedBox(height: AppTokens.s12),
              AppTextField(controller: label, label: l10n.host_diskLabel),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.host_diskAutoMount),
              value: autoMount,
              onChanged: (value) => setSheetState(() => autoMount = value),
            ),
            if (autoMount)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.host_diskNoFail),
                value: noFail,
                onChanged: (value) => setSheetState(() => noFail = value),
              ),
            const SizedBox(height: AppTokens.s16),
            PrimaryButton(
              label: partition ? l10n.host_diskPartition : l10n.host_diskMount,
              onPressed: () {
                final path = mountPoint.text.trim();
                if (path.isEmpty) return;
                Navigator.of(sheetContext).pop(
                  DiskPartitionReq(
                    device: device,
                    filesystem: fs,
                    mountPoint: path,
                    label: label.text.trim(),
                    autoMount: autoMount,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      mountPoint.dispose();
      label.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_disks.isEmpty) {
      return EmptyState(
        icon: TablerIcons.device_desktop,
        title: l10n.host_disksEmptyTitle,
        message: l10n.state_empty,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.pagePadding),
        children: [
          if (_disks.systemDisks.isNotEmpty) ...[
            SectionHeader(title: l10n.host_diskSystem),
            for (final disk in _disks.systemDisks)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.s12),
                child: _diskCard(disk, system: true),
              ),
          ],
          if (_disks.disks.isNotEmpty) ...[
            SectionHeader(title: l10n.host_diskNormal),
            for (final disk in _disks.disks)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.s12),
                child: _diskCard(disk),
              ),
          ],
          if (_disks.unpartitionedDisks.isNotEmpty) ...[
            SectionHeader(title: l10n.host_diskUnpartitioned),
            for (final disk in _disks.unpartitionedDisks)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.s12),
                child: _unpartitionedCard(disk),
              ),
          ],
        ],
      ),
    );
  }

  Widget _unpartitionedCard(DiskBasicDto disk) {
    final l10n = AppLocalizations.of(context);
    return TonalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _diskHeader(disk),
          const SizedBox(height: AppTokens.s12),
          SizedBox(
            width: double.infinity,
            child: SecondaryButton(
              label: l10n.host_diskPartition,
              onPressed: () => _partition(disk),
            ),
          ),
        ],
      ),
    );
  }

  Widget _diskCard(DiskItemDto disk, {bool system = false}) {
    final l10n = AppLocalizations.of(context);
    final partitions = disk.partitions.isNotEmpty
        ? disk.partitions
        : (disk.info.mountPoint.isNotEmpty
              ? [disk.info]
              : const <DiskBasicDto>[]);
    return TonalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _diskHeader(disk.info),
          if (partitions.isEmpty) ...[
            const SizedBox(height: AppTokens.s8),
            Text(
              l10n.state_empty,
              style: AppTextStyles.bodyS.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ] else ...[
            const SizedBox(height: AppTokens.s8),
            Text(
              '${l10n.host_diskPartitions}: ${partitions.length}',
              style: AppTextStyles.bodyS.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.s8),
            for (var i = 0; i < partitions.length; i++) ...[
              if (i > 0) const Divider(height: AppTokens.s16),
              _partitionRow(partitions[i], system: system),
            ],
          ],
          if (system) ...[
            const SizedBox(height: AppTokens.s8),
            Text(
              l10n.host_diskSystemHint,
              style: AppTextStyles.bodyS.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _diskHeader(DiskBasicDto disk) {
    final scheme = context.scheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          TablerIcons.device_desktop,
          size: AppTokens.iconList,
          color: scheme.primary,
        ),
        const SizedBox(width: AppTokens.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(disk.device, style: AppTextStyles.titleM),
              const SizedBox(height: 2),
              Text(
                [
                  disk.size,
                  if (disk.diskType.isNotEmpty) disk.diskType,
                  if (disk.model.isNotEmpty) disk.model,
                ].join(' · '),
                style: AppTextStyles.bodyS.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _partitionRow(DiskBasicDto partition, {required bool system}) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final mounted = partition.mountPoint.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                partition.device.split('/').last,
                style: AppTextStyles.label,
              ),
            ),
            Text(
              partition.size,
              style: AppTextStyles.bodyS.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s8),
        LinearProgressIndicator(
          value: (partition.usePercent.clamp(0, 100)) / 100,
          minHeight: 4,
          borderRadius: BorderRadius.circular(AppTokens.rFull),
          backgroundColor: scheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(
            partition.usePercent >= 90
                ? context.appColors.danger
                : partition.usePercent >= 80
                ? context.appColors.warning
                : scheme.primary,
          ),
        ),
        const SizedBox(height: AppTokens.s4),
        Wrap(
          spacing: AppTokens.s12,
          runSpacing: AppTokens.s4,
          children: [
            if (partition.filesystem.isNotEmpty)
              _meta('${l10n.host_diskFilesystem}: ${partition.filesystem}'),
            if (partition.used.isNotEmpty)
              _meta('${l10n.host_diskUsed}: ${partition.used}'),
            if (partition.avail.isNotEmpty)
              _meta('${l10n.host_diskAvail}: ${partition.avail}'),
            _meta(
              '${l10n.host_diskMountPoint}: '
              '${mounted ? partition.mountPoint : l10n.host_diskUnmounted}',
            ),
          ],
        ),
        if (!system) ...[
          const SizedBox(height: AppTokens.s4),
          Align(
            alignment: Alignment.centerRight,
            child: mounted
                ? DangerButton(
                    label: l10n.host_diskUnmount,
                    filled: false,
                    expanded: false,
                    onPressed: () => _unmount(partition),
                  )
                : SecondaryButton(
                    label: l10n.host_diskMount,
                    expanded: false,
                    onPressed: () => _mount(partition),
                  ),
          ),
        ],
      ],
    );
  }

  Widget _meta(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyS.copyWith(
        color: context.scheme.onSurfaceVariant,
      ),
    );
  }
}
