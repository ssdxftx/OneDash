import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/host/ssh_cert_dto.dart';
import '../../../../data/dto/host/ssh_info_dto.dart';
import '../../../../data/repositories_impl/host_repository_impl.dart';
import '../../../common/charts/area_chart.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../widgets/host_diagnostics_tab.dart';
import '../widgets/host_disks_tab.dart';

class HostPage extends ConsumerStatefulWidget {
  const HostPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<HostPage> createState() => _HostPageState();
}

class _MonitorSeries {
  const _MonitorSeries({
    this.cpu = const [],
    this.memory = const [],
    this.load = const [],
  });

  final List<double> cpu;
  final List<double> memory;
  final List<double> load;
}

class _HostPageState extends ConsumerState<HostPage> {
  int _hours = 1;
  Map<String, dynamic> _setting = const {};
  List<SshCertDto> _certs = const [];
  late Future<_MonitorSeries> _monitor;
  late Future<SshInfoDto> _ssh;

  @override
  void initState() {
    super.initState();
    _monitor = _loadMonitor();
    _ssh = _loadSsh();
    unawaited(_loadCerts());
  }

  Future<_MonitorSeries> _loadMonitor() async {
    final repository = await ref.read(
      hostRepositoryProvider(widget.serverId).future,
    );
    final settingFuture = repository.getMonitorSetting();
    final end = DateTime.now();
    final data = await repository.searchMonitor(
      param: 'all',
      startTime: end.subtract(Duration(hours: _hours)),
      endTime: end,
    );
    var cpu = const <double>[];
    var memory = const <double>[];
    var load = const <double>[];
    for (final item in data) {
      final values = item['value'];
      if (values is! List) continue;
      final param = '${item['param'] ?? ''}';
      if (param == 'base') {
        cpu = values
            .whereType<Map>()
            .map((row) => _double(row['cpu']))
            .toList(growable: false);
        memory = values
            .whereType<Map>()
            .map((row) => _double(row['memory']))
            .toList(growable: false);
      } else if (param == 'load') {
        load = values
            .whereType<Map>()
            .map((row) => _double(row['cpuLoad1']))
            .toList(growable: false);
      }
    }
    final setting = await settingFuture;
    if (mounted) setState(() => _setting = setting);
    return _MonitorSeries(cpu: cpu, memory: memory, load: load);
  }

  double _double(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  Future<SshInfoDto> _loadSsh() async {
    final repository = await ref.read(
      hostRepositoryProvider(widget.serverId).future,
    );
    return repository.getSshInfo();
  }

  Future<void> _loadCerts() async {
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      final certs = await repository.searchSshCerts();
      if (!mounted) return;
      setState(() => _certs = certs);
    } catch (_) {
      // Key management is optional for panels without root key access.
    }
  }

  void _refreshMonitor() {
    setState(() => _monitor = _loadMonitor());
  }

  void _refreshSsh() {
    setState(() => _ssh = _loadSsh());
    unawaited(_loadCerts());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.host_title,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () {
              _refreshMonitor();
              _refreshSsh();
            },
          ),
        ],
      ),
      body: SegmentedTabsView(
        labels: [
          l10n.host_monitor,
          l10n.host_ssh,
          l10n.host_disks,
          l10n.host_diagnostics,
        ],
        children: [
          _monitorTab(l10n),
          _sshTab(l10n),
          HostDisksTab(serverId: widget.serverId),
          HostDiagnosticsTab(serverId: widget.serverId),
        ],
      ),
    );
  }

  Widget _monitorTab(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        AppFilterChips<int>(
          options: const [1, 6, 24],
          labelOf: (value) => switch (value) {
            1 => l10n.host_range1h,
            6 => l10n.host_range6h,
            _ => l10n.host_range24h,
          },
          selected: {_hours},
          onChanged: (selection) {
            if (selection.isEmpty) return;
            setState(() {
              _hours = selection.first;
              _monitor = _loadMonitor();
            });
          },
        ),
        SplitListGroup(
          children: [
            SplitListTile(
              leading: const Icon(TablerIcons.settings),
              title: l10n.host_monitorSettings,
              subtitle:
                  '${_setting['monitorInterval'] ?? '-'}s · ${_setting['monitorStoreDays'] ?? '-'}d',
              trailing: const Icon(TablerIcons.chevron_right),
              onTap: _editMonitorSettings,
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s12),
        FutureBuilder<_MonitorSeries>(
          future: _monitor,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(describeError(snapshot.error!, l10n)));
            }
            final data = snapshot.data ?? const _MonitorSeries();
            if (data.cpu.isEmpty && data.memory.isEmpty && data.load.isEmpty) {
              return EmptyState(
                icon: TablerIcons.chart_line,
                title: l10n.host_monitor,
                message: l10n.host_monitorEmpty,
              );
            }
            return Column(
              children: [
                _chartCard(
                  l10n.host_cpu,
                  data.cpu,
                  maxY: 100,
                  placeholder: l10n.host_monitorEmpty,
                ),
                const SizedBox(height: AppTokens.s16),
                _chartCard(
                  l10n.host_memory,
                  data.memory,
                  maxY: 100,
                  placeholder: l10n.host_monitorEmpty,
                ),
                const SizedBox(height: AppTokens.s16),
                _chartCard(
                  l10n.host_load,
                  data.load,
                  placeholder: l10n.host_monitorEmpty,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _chartCard(
    String title,
    List<double> series, {
    double? maxY,
    required String placeholder,
  }) {
    return TonalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleM),
          const SizedBox(height: AppTokens.s16),
          SizedBox(
            height: 150,
            child: AreaChart(
              seriesA: series,
              maxY: maxY,
              placeholder: placeholder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sshTab(AppLocalizations l10n) {
    return FutureBuilder<SshInfoDto>(
      future: _ssh,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(describeError(snapshot.error!, l10n)));
        }
        final info = snapshot.data;
        if (info == null) {
          return EmptyState(
            icon: TablerIcons.terminal_2,
            title: l10n.host_ssh,
            message: l10n.state_empty,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(AppTokens.s16),
          children: [
            SplitListGroup(
              children: [
                SplitListTile(
                  title: l10n.host_sshStatus,
                  subtitle: info.isActive
                      ? l10n.databases_enabled
                      : l10n.databases_disabled,
                ),
                SplitListTile(
                  title: l10n.host_sshPort,
                  subtitle: info.port,
                  trailing: const Icon(TablerIcons.edit),
                  onTap: () => _editPort(info.port),
                ),
                SplitListTile(
                  title: l10n.host_rootLogin,
                  subtitle: info.permitRootLogin,
                  trailing: const Icon(TablerIcons.edit),
                  onTap: () => _editSsh(
                    'PermitRootLogin',
                    l10n.host_rootLogin,
                    info.permitRootLogin,
                  ),
                ),
                SplitListTile(
                  title: l10n.host_passwordAuth,
                  subtitle: info.passwordAuthentication,
                  trailing: const Icon(TablerIcons.edit),
                  onTap: () => _editSsh(
                    'PasswordAuthentication',
                    l10n.host_passwordAuth,
                    info.passwordAuthentication,
                  ),
                ),
                SplitListTile(
                  title: l10n.host_pubkeyAuth,
                  subtitle: info.pubkeyAuthentication,
                  trailing: const Icon(TablerIcons.edit),
                  onTap: () => _editSsh(
                    'PubkeyAuthentication',
                    l10n.host_pubkeyAuth,
                    info.pubkeyAuthentication,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s24),
            Row(
              children: [
                Expanded(
                  child: Text(l10n.host_sshKeys, style: AppTextStyles.titleM),
                ),
                TextButton.icon(
                  onPressed: _generateKey,
                  icon: const Icon(TablerIcons.plus, size: AppTokens.iconList),
                  label: Text(l10n.host_generateKey),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s8),
            if (_certs.isEmpty)
              Text(
                l10n.state_empty,
                style: AppTextStyles.bodyS.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
              )
            else
              SplitListGroup(
                children: [
                  for (final cert in _certs)
                    SplitListTile(
                      leading: const Icon(TablerIcons.key),
                      title: cert.name,
                      subtitle: cert.encryptionMode,
                      trailing: IconButton(
                        tooltip: l10n.host_deleteKey,
                        icon: const Icon(TablerIcons.trash),
                        onPressed: () => _deleteKey(cert),
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  Future<void> _generateKey() async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController();
    final passphrase = TextEditingController();
    var type = 'ed25519';
    final confirmed = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.host_generateKey, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            AppTextField(
              controller: name,
              label: l10n.host_keyName,
              autofocus: true,
            ),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: InputDecoration(labelText: l10n.host_keyType),
              items: const [
                DropdownMenuItem(value: 'ed25519', child: Text('ED25519')),
                DropdownMenuItem(value: 'rsa', child: Text('RSA')),
              ],
              onChanged: (value) {
                if (value != null) setSheetState(() => type = value);
              },
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: passphrase,
              label: l10n.host_keyPassphrase,
              obscure: true,
            ),
            const SizedBox(height: AppTokens.s24),
            PrimaryButton(
              label: l10n.action_create,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    );
    final keyName = name.text.trim();
    final pass = passphrase.text;
    name.dispose();
    passphrase.dispose();
    if (confirmed != true || keyName.isEmpty) return;
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      await repository.createSshCert(
        SshCertOperateReq(
          name: keyName,
          encryptionMode: type,
          mode: 'generate',
          passPhrase: pass,
        ),
      );
      if (!mounted) return;
      AppToast.success(context, l10n.host_keyGenerated);
      unawaited(_loadCerts());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _deleteKey(SshCertDto cert) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.host_deleteKey,
      message: cert.name,
      confirmLabel: l10n.action_delete,
      requireText: cert.name,
    );
    if (!confirmed) return;
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      await repository.deleteSshCert(cert.id);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_loadCerts());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editMonitorSettings() async {
    final l10n = AppLocalizations.of(context);
    final interval = TextEditingController(
      text: '${_setting['monitorInterval'] ?? '300'}',
    );
    final days = TextEditingController(
      text: '${_setting['monitorStoreDays'] ?? '7'}',
    );
    var enabled = '${_setting['monitorStatus'] ?? 'Enable'}' == 'Enable';
    final confirmed = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.host_monitorSettings, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.host_monitorEnabled),
              value: enabled,
              onChanged: (value) => setSheetState(() => enabled = value),
            ),
            AppTextField(
              controller: interval,
              label: l10n.host_monitorInterval,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: days,
              label: l10n.host_monitorStoreDays,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTokens.s24),
            PrimaryButton(
              label: l10n.action_save,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    );
    final intervalValue = interval.text.trim();
    final daysValue = days.text.trim();
    interval.dispose();
    days.dispose();
    if (confirmed != true) return;
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      await repository.updateMonitorSetting(
        'MonitorStatus',
        enabled ? 'Enable' : 'Disable',
      );
      if (intervalValue.isNotEmpty) {
        await repository.updateMonitorSetting('MonitorInterval', intervalValue);
      }
      if (daysValue.isNotEmpty) {
        await repository.updateMonitorSetting('MonitorStoreDays', daysValue);
      }
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      _refreshMonitor();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editPort(String current) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: current);
    final value = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.host_sshPort, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          const SizedBox(height: AppTokens.s24),
          PrimaryButton(
            label: l10n.action_save,
            onPressed: () => Navigator.of(sheetContext).pop(controller.text),
          ),
        ],
      ),
    );
    controller.dispose();
    final port = value?.trim() ?? '';
    if (port.isEmpty || port == current) return;
    await _saveSsh('Port', port);
  }

  Future<void> _editSsh(String key, String label, String current) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: current);
    final value = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(controller: controller, autofocus: true),
          const SizedBox(height: AppTokens.s24),
          PrimaryButton(
            label: l10n.action_save,
            onPressed: () => Navigator.of(sheetContext).pop(controller.text),
          ),
        ],
      ),
    );
    controller.dispose();
    final next = value?.trim() ?? '';
    if (next.isEmpty || next == current) return;
    await _saveSsh(key, next);
  }

  Future<void> _saveSsh(String key, String value) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      if (key == 'Port') {
        final reachable = await repository.checkLocalSshConnection();
        if (!mounted) return;
        if (!reachable) {
          AppToast.warning(context, l10n.host_sshCheckFailed);
          return;
        }
      }
      await repository.updateSsh(key, value);
      if (!mounted) return;
      AppToast.success(context, l10n.host_sshUpdated);
      _refreshSsh();
      if (key == 'Port') {
        final reachable = await repository.checkLocalSshConnection();
        if (!mounted) return;
        if (!reachable) {
          AppToast.warning(context, l10n.host_sshCheckAfterSave);
        }
      }
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }
}
