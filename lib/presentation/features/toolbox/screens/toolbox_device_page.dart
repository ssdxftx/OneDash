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
