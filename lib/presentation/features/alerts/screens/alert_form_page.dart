import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/alert/alert_dto.dart';
import '../../../../data/repositories_impl/alert_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/form_footer.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/error_toast.dart';

final alertDisksProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final repository = await ref.watch(alertRepositoryProvider.future);
      return repository.listDisks();
    }, name: 'alertDisksProvider');

String _diskPath(Map<String, dynamic> disk) {
  for (final key in const ['path', 'mountPoint', 'name', 'device']) {
    final value = '${disk[key] ?? ''}'.trim();
    if (value.isNotEmpty) return value;
  }
  return '';
}

final alertConfigsProvider = FutureProvider.autoDispose<List<AlertConfigInfo>>((
  ref,
) async {
  final repository = await ref.watch(alertRepositoryProvider.future);
  return repository.getAlertConfigs();
}, name: 'alertConfigsProvider');

class AlertFormPage extends ConsumerStatefulWidget {
  const AlertFormPage({
    super.key,
    required this.serverId,
    this.alertId,
    this.embedded = false,
  });

  final int serverId;
  final int? alertId;
  final bool embedded;

  bool get isEditing => alertId != null;

  @override
  ConsumerState<AlertFormPage> createState() => _AlertFormPageState();
}

class _AlertFormPageState extends ConsumerState<AlertFormPage> {
  final _title = TextEditingController();
  final _project = TextEditingController();
  final _disk = TextEditingController();
  final _cycle = TextEditingController(text: '7');
  final _count = TextEditingController(text: '80');
  final _sendCount = TextEditingController(text: '3');
  final _advancedParams = TextEditingController();
  final _method = TextEditingController();

  String _type = 'cpu';
  String _status = 'Enable';
  bool _submitting = false;
  bool _loaded = false;

  static const _types = [
    'cpu',
    'memory',
    'disk',
    'load',
    'sshLogin',
    'panelLogin',
    'ssl',
    'siteEndTime',
    'panelUpdate',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.alertId != null) _load();
  }

  Future<void> _load() async {
    try {
      final repository = await ref.read(alertRepositoryProvider.future);
      final page = await repository.searchAlerts(
        const AlertSearchReq(page: 1, pageSize: 200),
      );
      AlertInfo? item;
      for (final alert in page.items) {
        if (alert.id == widget.alertId) {
          item = alert;
          break;
        }
      }
      if (item == null || !mounted) return;
      final alert = item;
      setState(() {
        _type = alert.type;
        _title.text = alert.title;
        _project.text = alert.project;
        if (alert.type == 'disk') _disk.text = alert.project;
        _cycle.text = '${alert.cycle}';
        _count.text = '${alert.count}';
        _sendCount.text = '${alert.sendCount}';
        _advancedParams.text = alert.advancedParams;
        _method.text = alert.method;
        _status = alert.status.isEmpty ? 'Enable' : alert.status;
        _loaded = true;
      });
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _project.dispose();
    _disk.dispose();
    _cycle.dispose();
    _count.dispose();
    _sendCount.dispose();
    _advancedParams.dispose();
    _method.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final method = _method.text.trim();
    if (method.isEmpty) {
      AppToast.warning(context, l10n.alerts_methodRequired);
      return;
    }
    setState(() => _submitting = true);
    try {
      final repository = await ref.read(alertRepositoryProvider.future);
      final request = AlertCreateReq(
        type: _type,
        method: method,
        cycle: int.tryParse(_cycle.text.trim()) ?? 0,
        count: int.tryParse(_count.text.trim()) ?? 0,
        title: _title.text.trim().isEmpty
            ? _defaultTitle(_type, l10n)
            : _title.text.trim(),
        project: _type == 'disk' ? _disk.text.trim() : _project.text.trim(),
        status: _status,
        sendCount: int.tryParse(_sendCount.text.trim()) ?? 3,
        advancedParams: _advancedParams.text.trim(),
      );
      if (widget.isEditing) {
        await repository.updateAlert(widget.alertId!, request);
      } else {
        await repository.createAlert(request);
      }
      if (!mounted) return;
      AppToast.success(
        context,
        widget.isEditing ? l10n.alerts_updated : l10n.alerts_created,
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final configs = ref.watch(alertConfigsProvider);
    final selected = _method.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
    final children = <Widget>[
      SectionHeader(title: l10n.alerts_rule),
      TonalCard(
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: InputDecoration(labelText: l10n.alerts_type),
              items: [
                for (final type in _types)
                  DropdownMenuItem(
                    value: type,
                    child: Text(_typeLabel(type, l10n)),
                  ),
              ],
              onChanged: widget.isEditing
                  ? null
                  : (value) {
                      if (value != null) setState(() => _type = value);
                    },
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: _title,
              label: l10n.alerts_title,
              helper: l10n.alerts_titleHint,
            ),
            const SizedBox(height: AppTokens.s12),
            if (_type == 'disk')
              ref
                  .watch(alertDisksProvider)
                  .when(
                    data: (disks) {
                      final options = disks
                          .map(_diskPath)
                          .where((path) => path.isNotEmpty)
                          .toSet()
                          .toList(growable: false);
                      return DropdownButtonFormField<String>(
                        initialValue: options.contains(_disk.text)
                            ? _disk.text
                            : null,
                        decoration: InputDecoration(
                          labelText: l10n.alerts_disk,
                          helperText: l10n.alerts_diskHint,
                        ),
                        items: [
                          for (final path in options)
                            DropdownMenuItem(value: path, child: Text(path)),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _disk.text = value);
                          }
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (error, _) => Text(
                      describeError(error, l10n),
                      style: AppTextStyles.bodyS.copyWith(
                        color: context.scheme.error,
                      ),
                    ),
                  )
            else
              AppTextField(
                controller: _project,
                label: l10n.alerts_project,
                helper: l10n.alerts_projectHint,
              ),
          ],
        ),
      ),
      const SizedBox(height: AppTokens.s24),
      SectionHeader(title: l10n.alerts_threshold),
      TonalCard(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _count,
                    label: l10n.alerts_count,
                    keyboardType: TextInputType.number,
                    helper: l10n.alerts_countHint,
                  ),
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: AppTextField(
                    controller: _cycle,
                    label: l10n.alerts_cycle,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: _sendCount,
              label: l10n.alerts_sendCount,
              keyboardType: TextInputType.number,
              helper: l10n.alerts_sendCountHint,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: _advancedParams,
              label: l10n.alerts_advancedParams,
              helper: l10n.alerts_advancedParamsHint,
            ),
          ],
        ),
      ),
      const SizedBox(height: AppTokens.s24),
      SectionHeader(title: l10n.alerts_notification),
      TonalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            configs.when(
              data: (items) => items.isEmpty
                  ? Text(
                      l10n.alerts_noConfigs,
                      style: AppTextStyles.bodyS.copyWith(
                        color: context.appColors.warning,
                      ),
                    )
                  : AppFilterChips<String>(
                      options: [for (final item in items) '${item.id}'],
                      labelOf: (value) {
                        final item = items.firstWhere(
                          (config) => '${config.id}' == value,
                        );
                        return item.title.isEmpty ? item.type : item.title;
                      },
                      selected: selected,
                      onChanged: (values) {
                        _method.text = values.join(',');
                        setState(() {});
                      },
                    ),
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text(
                describeError(error, l10n),
                style: AppTextStyles.bodyS.copyWith(
                  color: context.scheme.error,
                ),
              ),
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: _method,
              label: l10n.alerts_method,
              helper: l10n.alerts_methodHint,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    ];
    if (widget.embedded) {
      return FormSheet(
        title: widget.isEditing ? l10n.alerts_edit : l10n.alerts_create,
        onSave: _submit,
        saving: _submitting || (widget.isEditing && !_loaded),
        saveLabel: widget.isEditing ? l10n.action_save : l10n.alerts_create,
        children: children,
      );
    }
    return Scaffold(
      appBar: AppBarLarge(
        title: widget.isEditing ? l10n.alerts_edit : l10n.alerts_create,
        leading: IconButton(
          tooltip: l10n.action_close,
          onPressed: () => context.pop(),
          icon: const Icon(TablerIcons.x),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s8,
          AppTokens.s16,
          AppTokens.s32,
        ),
        children: children,
      ),
      bottomNavigationBar: FormFooter(
        child: PrimaryButton(
          label: _submitting
              ? l10n.alerts_saving
              : widget.isEditing
              ? l10n.action_save
              : l10n.alerts_create,
          loading: _submitting || (widget.isEditing && !_loaded),
          onPressed: _submitting ? null : _submit,
        ),
      ),
    );
  }

  String _typeLabel(String type, AppLocalizations l10n) {
    return switch (type) {
      'cpu' => l10n.alerts_typeCpu,
      'memory' => l10n.alerts_typeMemory,
      'disk' => l10n.alerts_typeDisk,
      'load' => l10n.alerts_typeLoad,
      'sshLogin' => l10n.alerts_typeSshLogin,
      'panelLogin' => l10n.alerts_typePanelLogin,
      'ssl' => l10n.alerts_typeSsl,
      'siteEndTime' => l10n.alerts_typeSiteEndTime,
      'panelUpdate' => l10n.alerts_typePanelUpdate,
      _ => type,
    };
  }

  String _defaultTitle(String type, AppLocalizations l10n) =>
      _typeLabel(type, l10n);
}

Future<void> showAlertFormSheet(
  BuildContext context, {
  required int serverId,
  int? alertId,
}) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.94,
    builder: (sheetContext) => SizedBox(
      height: MediaQuery.sizeOf(sheetContext).height * 0.78,
      child: AlertFormPage(
        serverId: serverId,
        alertId: alertId,
        embedded: true,
      ),
    ),
  );
}
