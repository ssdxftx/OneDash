import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/repositories_impl/toolbox_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/error_toast.dart';
import '../../../common/formatters/value_labels.dart';

class ToolboxDevicePage extends ConsumerStatefulWidget {
  const ToolboxDevicePage({super.key});

  @override
  ConsumerState<ToolboxDevicePage> createState() => _ToolboxDevicePageState();
}

class _ToolboxDevicePageState extends ConsumerState<ToolboxDevicePage> {
  Map<String, dynamic> _base = const {};
  List<String> _zones = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      final results = await Future.wait([
        repository.getDeviceBase(),
        repository.getZoneOptions().catchError((_) => <String>[]),
      ]);
      if (!mounted) return;
      setState(() {
        _base = results[0] as Map<String, dynamic>;
        _zones = results[1] as List<String>;
      });
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final dns = ((_base['dns'] as List?) ?? const [])
        .map((item) => '$item')
        .join(', ');
    final swaps = (_base['swapDetails'] as List?) ?? const [];
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.toolbox_time,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _load,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(context.pagePadding),
        children: [
          SectionHeader(title: l10n.toolbox_timeSection),
          SplitListGroup(
            children: [
              SplitListTile(
                title: l10n.toolbox_timezone,
                subtitle: displayValue(context, _base['timeZone']?.toString()),
                trailing: const Icon(TablerIcons.edit),
                onTap: _editTimezone,
              ),
              SplitListTile(
                title: l10n.toolbox_localTime,
                subtitle: displayValue(context, _base['localTime']?.toString()),
              ),
              SplitListTile(
                title: l10n.toolbox_hostname,
                subtitle: displayValue(context, _base['hostname']?.toString()),
                trailing: const Icon(TablerIcons.edit),
                onTap: _editHostname,
              ),
              if (_base['user'] != null)
                SplitListTile(
                  title: l10n.toolbox_users,
                  subtitle: '${_base['user']}',
                ),
            ],
          ),
          const SizedBox(height: AppTokens.s24),
          SectionHeader(title: l10n.toolbox_swapDns),
          SplitListGroup(
            children: [
              SplitListTile(
                title: l10n.toolbox_dns,
                subtitle: displayValue(context, dns),
                trailing: const Icon(TablerIcons.edit),
                onTap: () => _editDns(dns),
              ),
              for (final swap in swaps.whereType<Map>())
                SplitListTile(
                  title: displayValue(context, swap['path']?.toString()),
                  subtitle:
                      '${formatBytes(swap['size'])} · ${swap['used'] ?? ''}',
                ),
              SplitListTile(
                title: l10n.toolbox_dnsCheck,
                trailing: const Icon(TablerIcons.activity),
                onTap: () => _checkDns(dns),
              ),
              SplitListTile(
                title: l10n.toolbox_hosts,
                trailing: const Icon(TablerIcons.edit),
                onTap: _editHosts,
              ),
              SplitListTile(
                title: l10n.toolbox_addHost,
                trailing: const Icon(TablerIcons.plus),
                onTap: _addHost,
              ),
              SplitListTile(
                title: l10n.toolbox_password,
                trailing: const Icon(TablerIcons.key),
                onTap: _changePassword,
              ),
              SplitListTile(
                title: l10n.toolbox_systemClean,
                trailing: const Icon(TablerIcons.trash),
                onTap: _cleanSystem,
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s16),
          PrimaryButton(
            label: l10n.toolbox_addSwap,
            icon: TablerIcons.plus,
            onPressed: _addSwap,
          ),
        ],
      ),
    );
  }

  Future<void> _editHostname() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(
      text: '${_base['hostname'] ?? ''}',
    );
    final value = await pushFormPage<String>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.toolbox_hostname,
          onSave: () async => Navigator.of(pageContext).pop(controller.text),
          children: [AppTextField(controller: controller, autofocus: true)],
        ),
      ),
    );
    controller.dispose();
    final next = value?.trim() ?? '';
    if (next.isEmpty) return;
    await _saveConf('Hostname', next);
  }

  Future<void> _editHosts() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      final content = await repository.loadDeviceConf('Hosts');
      if (!mounted) return;
      final controller = TextEditingController(text: content);
      final confirmed = await pushFormPage<bool>(
        context,
        Builder(
          builder: (pageContext) => SimpleFormPage(
            title: l10n.toolbox_hostsEdit,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [AppTextField(controller: controller, maxLines: 16)],
          ),
        ),
      );
      final file = controller.text;
      controller.dispose();
      if (confirmed != true || !mounted) return;
      await repository.updateDeviceByFile(name: 'Hosts', file: file);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _addHost() async {
    final l10n = AppLocalizations.of(context);
    final ip = TextEditingController();
    final host = TextEditingController();
    final confirmed = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.toolbox_addHost,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(
              controller: ip,
              label: 'IP',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: host, label: l10n.toolbox_hostname),
          ],
        ),
      ),
    );
    final ipValue = ip.text.trim();
    final hostValue = host.text.trim();
    ip.dispose();
    host.dispose();
    if (confirmed != true || ipValue.isEmpty || hostValue.isEmpty) return;
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.updateDeviceHosts([
        {'ip': ipValue, 'host': hostValue},
      ]);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _changePassword() async {
    final l10n = AppLocalizations.of(context);
    final user = '${_base['user'] ?? 'root'}';
    final controller = TextEditingController();
    final confirmed = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.toolbox_password,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(
              controller: controller,
              label: l10n.toolbox_password,
              obscure: true,
              autofocus: true,
            ),
          ],
        ),
      ),
    );
    final value = controller.text;
    controller.dispose();
    if (confirmed != true || value.isEmpty || !mounted) return;
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.updateDevicePassword(user: user, password: value);
      if (!mounted) return;
      AppToast.success(context, l10n.toolbox_passwordChanged);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _checkDns(String dns) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      final ok = await repository.checkDns(value: dns);
      if (!mounted) return;
      if (ok) {
        AppToast.success(context, l10n.toolbox_dnsOk);
      } else {
        AppToast.warning(context, l10n.toolbox_dnsFail);
      }
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _cleanSystem() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      final scan = await repository.scanClean();
      if (!mounted) return;
      final items = <Map<String, dynamic>>[];
      void collect(Object? node) {
        if (node is! Map) return;
        final children = node['children'];
        if (children is List && children.isNotEmpty) {
          for (final child in children) {
            collect(child);
          }
          return;
        }
        if (node['canDelete'] != true) return;
        final type = '${node['type'] ?? ''}';
        final name = '${node['name'] ?? ''}';
        if (type.isEmpty || name.isEmpty) return;
        items.add({'treeType': type, 'name': name, 'size': node['size'] ?? 0});
      }

      for (final group in const [
        'systemClean',
        'backupClean',
        'uploadClean',
        'downloadClean',
        'systemLogClean',
        'containerClean',
      ]) {
        final children = scan[group];
        if (children is! List) continue;
        for (final item in children) {
          collect(item);
        }
      }
      if (items.isEmpty) {
        AppToast.success(context, l10n.vm_orphansEmpty);
        return;
      }
      final confirmed = await showConfirmSheet(
        context,
        title: l10n.toolbox_systemClean,
        message: l10n.toolbox_systemCleanConfirm,
        confirmLabel: l10n.action_clear,
      );
      if (!confirmed || !mounted) return;
      await repository.cleanSystem(items);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editTimezone() async {
    final l10n = AppLocalizations.of(context);
    final controller = ValueNotifier<String>('${_base['timeZone'] ?? ''}');
    final value = await pushFormPage<String>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.toolbox_timezone,
          onSave: () async => Navigator.of(pageContext).pop(controller.value),
          children: [
            ValueListenableBuilder<String>(
              valueListenable: controller,
              builder: (context, selected, _) =>
                  DropdownButtonFormField<String>(
                    initialValue: _zones.contains(selected) ? selected : null,
                    decoration: InputDecoration(
                      labelText: l10n.toolbox_timezone,
                    ),
                    items: [
                      for (final zone in _zones)
                        DropdownMenuItem(value: zone, child: Text(zone)),
                    ],
                    onChanged: (next) {
                      if (next != null) controller.value = next;
                    },
                  ),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty) return;
    await _saveConf('TimeZone', value);
  }

  Future<void> _editDns(String current) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: current);
    final value = await pushFormPage<String>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.toolbox_dns,
          onSave: () async => Navigator.of(pageContext).pop(controller.text),
          children: [
            AppTextField(
              controller: controller,
              helper: '8.8.8.8,1.1.1.1',
              autofocus: true,
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    final next = value?.trim() ?? '';
    if (next.isEmpty || next == current) return;
    await _saveConf('DNS', next);
  }

  Future<void> _saveConf(String key, String value) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.updateDeviceConf(key, value);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _addSwap() async {
    final l10n = AppLocalizations.of(context);
    final path = TextEditingController(text: '/swapfile');
    final size = TextEditingController(text: '1024');
    final confirmed = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.toolbox_addSwap,
          saveLabel: l10n.action_create,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(controller: path, label: l10n.toolbox_swapPath),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: size,
              label: l10n.toolbox_swapSize,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
    final swapPath = path.text.trim();
    final swapSize = int.tryParse(size.text.trim()) ?? 0;
    path.dispose();
    size.dispose();
    if (confirmed != true || swapPath.isEmpty || swapSize <= 0) return;
    try {
      final repository = await ref.read(toolboxRepositoryProvider.future);
      await repository.updateSwap(path: swapPath, size: swapSize);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      unawaited(_load());
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }
}
