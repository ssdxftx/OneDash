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
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/error_toast.dart';

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
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          SectionHeader(title: l10n.toolbox_time),
          SplitListGroup(
            children: [
              SplitListTile(
                title: l10n.toolbox_timezone,
                subtitle: '${_base['timeZone'] ?? '-'}',
                trailing: const Icon(TablerIcons.edit),
                onTap: _editTimezone,
              ),
              SplitListTile(
                title: l10n.toolbox_localTime,
                subtitle: '${_base['localTime'] ?? '-'}',
              ),
              SplitListTile(
                title: l10n.toolbox_hostname,
                subtitle: '${_base['hostname'] ?? '-'}',
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s24),
          SectionHeader(title: l10n.toolbox_swapDns),
          SplitListGroup(
            children: [
              SplitListTile(
                title: l10n.toolbox_dns,
                subtitle: dns.isEmpty ? '-' : dns,
                trailing: const Icon(TablerIcons.edit),
                onTap: () => _editDns(dns),
              ),
              for (final swap in swaps.whereType<Map>())
                SplitListTile(
                  title: '${swap['path'] ?? '-'}',
                  subtitle:
                      '${formatBytes(swap['size'])} · ${swap['used'] ?? ''}',
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

  Future<void> _editTimezone() async {
    final l10n = AppLocalizations.of(context);
    final controller = ValueNotifier<String>('${_base['timeZone'] ?? ''}');
    final value = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.toolbox_timezone, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          ValueListenableBuilder<String>(
            valueListenable: controller,
            builder: (context, selected, _) => DropdownButtonFormField<String>(
              initialValue: _zones.contains(selected) ? selected : null,
              decoration: InputDecoration(labelText: l10n.toolbox_timezone),
              items: [
                for (final zone in _zones)
                  DropdownMenuItem(value: zone, child: Text(zone)),
              ],
              onChanged: (next) {
                if (next != null) controller.value = next;
              },
            ),
          ),
          const SizedBox(height: AppTokens.s24),
          PrimaryButton(
            label: l10n.action_save,
            onPressed: () => Navigator.of(sheetContext).pop(controller.value),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty) return;
    await _saveConf('TimeZone', value);
  }

  Future<void> _editDns(String current) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: current);
    final value = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.toolbox_dns, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            controller: controller,
            helper: '8.8.8.8,1.1.1.1',
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
    final confirmed = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.toolbox_addSwap, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(controller: path, label: l10n.toolbox_swapPath),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: size,
            label: l10n.toolbox_swapSize,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppTokens.s24),
          PrimaryButton(
            label: l10n.action_create,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
        ],
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
