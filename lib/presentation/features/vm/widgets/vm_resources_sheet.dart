import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/vm_repository_impl.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../screens/vm_page.dart';

final vmIsoProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((
  ref,
) async {
  final repository = await ref.watch(vmRepositoryProvider.future);
  return repository.listIsos();
}, name: 'vmIsoProvider');

final vmStorageProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final repository = await ref.watch(vmRepositoryProvider.future);
      return repository.listStorages();
    }, name: 'vmStorageProvider');

final vmTemplateProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final repository = await ref.watch(vmRepositoryProvider.future);
      return repository.listTemplates();
    }, name: 'vmTemplateProvider');

enum _ResourceKind { network, storage, template, iso }

Future<void> showVmResourcesSheet(BuildContext context) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.94,
    builder: (sheetContext) =>
        const SizedBox(height: 600, child: _VmResourcesSheet()),
  );
}

class _VmResourcesSheet extends ConsumerStatefulWidget {
  const _VmResourcesSheet();

  @override
  ConsumerState<_VmResourcesSheet> createState() => _VmResourcesSheetState();
}

class _VmResourcesSheetState extends ConsumerState<_VmResourcesSheet> {
  _ResourceKind _kind = _ResourceKind.network;

  void _refresh() {
    ref.invalidate(vmNetworksProvider);
    ref.invalidate(vmStorageProvider);
    ref.invalidate(vmTemplateProvider);
    ref.invalidate(vmIsoProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppTokens.s20, 0, AppTokens.s8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(l10n.vm_resources, style: AppTextStyles.titleM),
              ),
              IconButton(
                tooltip: l10n.action_refresh,
                icon: const Icon(TablerIcons.refresh),
                onPressed: _refresh,
              ),
              if (_kind == _ResourceKind.iso)
                IconButton(
                  tooltip: l10n.vm_isoSearch,
                  icon: const Icon(TablerIcons.search),
                  onPressed: _searchIso,
                ),
              if (_kind == _ResourceKind.network)
                IconButton(
                  tooltip: l10n.vm_networkInterfaces,
                  icon: const Icon(TablerIcons.sitemap),
                  onPressed: _showInterfaces,
                ),
              IconButton(
                tooltip: l10n.action_add,
                icon: const Icon(TablerIcons.plus),
                onPressed: _add,
              ),
              IconButton(
                tooltip: l10n.action_close,
                icon: const Icon(TablerIcons.x),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        SegmentedTabs(
          labels: [
            l10n.vm_networks,
            l10n.vm_storages,
            l10n.vm_templates,
            l10n.vm_isos,
          ],
          selectedIndex: _kind.index,
          onChanged: (index) =>
              setState(() => _kind = _ResourceKind.values[index]),
        ),
        const SizedBox(height: AppTokens.s8),
        Expanded(child: _ResourceList(kind: _kind)),
      ],
    );
  }

  Future<void> _add() async {
    switch (_kind) {
      case _ResourceKind.network:
        await _addNetwork();
      case _ResourceKind.storage:
        await _addStorage();
      case _ResourceKind.template:
        await _addTemplate();
      case _ResourceKind.iso:
        await _addIso();
    }
  }

  Future<void> _searchIso() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final query = await pushFormPage<String>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.vm_isoSearch,
          saveLabel: l10n.action_search,
          onSave: () async =>
              Navigator.of(pageContext).pop(controller.text.trim()),
          children: [
            AppTextField(
              controller: controller,
              label: l10n.vm_isoSearchHint,
              autofocus: true,
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (query == null || !mounted) return;
    try {
      final repository = await ref.read(vmRepositoryProvider.future);
      final result = await repository.searchIsos(info: query);
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.82,
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.vm_isoSearch, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s12),
            if (result.items.isEmpty)
              EmptyState(
                compact: true,
                icon: TablerIcons.disc,
                title: l10n.vm_resourceEmpty,
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: result.items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppTokens.s8),
                  itemBuilder: (context, index) {
                    final item = result.items[index];
                    return TonalCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item['name'] ?? ''}',
                            style: AppTextStyles.titleS,
                          ),
                          Text(
                            [
                              if ('${item['type'] ?? ''}'.isNotEmpty)
                                '${item['type']}',
                              if ('${item['path'] ?? ''}'.isNotEmpty)
                                '${item['path']}',
                              if ('${item['status'] ?? ''}'.isNotEmpty)
                                '${item['status']}',
                            ].join(' · '),
                            style: AppTextStyles.caption.copyWith(
                              color: context.scheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
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

  Future<void> _showInterfaces() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(vmRepositoryProvider.future);
      final items = await repository.listNetworkInterfaces();
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.82,
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.vm_networkInterfaces, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s12),
            if (items.isEmpty)
              EmptyState(
                compact: true,
                icon: TablerIcons.sitemap,
                title: l10n.vm_resourceEmpty,
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppTokens.s8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final addresses =
                        (item['addresses'] as List?)
                            ?.map((value) => '$value')
                            .where((value) => value.isNotEmpty)
                            .join(', ') ??
                        '';
                    return TonalCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item['name'] ?? ''}',
                            style: AppTextStyles.titleS,
                          ),
                          if (addresses.isNotEmpty)
                            Text(
                              addresses,
                              style: AppTextStyles.caption.copyWith(
                                color: context.scheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
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

  Future<void> _addNetwork() async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController();
    final cidr = TextEditingController();
    final gateway = TextEditingController();
    final source = TextEditingController();
    var type = 'nat';
    var autoStart = true;
    final saved = await _showForm(
      title: l10n.vm_networks,
      children: (setFormState) => [
        AppTextField(controller: name, label: l10n.vm_name),
        const SizedBox(height: AppTokens.s12),
        DropdownButtonFormField<String>(
          initialValue: type,
          decoration: InputDecoration(labelText: l10n.vm_type),
          items: [
            DropdownMenuItem(value: 'nat', child: Text(l10n.vm_netNat)),
            DropdownMenuItem(value: 'bridge', child: Text(l10n.vm_netBridge)),
            DropdownMenuItem(value: 'macvtap', child: Text(l10n.vm_netMacvtap)),
          ],
          onChanged: (value) {
            if (value != null) setFormState(() => type = value);
          },
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: cidr, label: l10n.vm_cidr),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: gateway, label: l10n.vm_gateway),
        if (type == 'macvtap') ...[
          const SizedBox(height: AppTokens.s12),
          AppTextField(controller: source, label: l10n.vm_sourceInterface),
        ],
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.vm_autoStart),
          value: autoStart,
          onChanged: (value) => setFormState(() => autoStart = value),
        ),
      ],
    );
    final body = <String, dynamic>{
      'name': name.text.trim(),
      'type': type,
      'cidr': cidr.text.trim(),
      'gateway': gateway.text.trim(),
      'sourceInterface': source.text.trim(),
      'autoStart': autoStart,
    };
    name.dispose();
    cidr.dispose();
    gateway.dispose();
    source.dispose();
    if (!saved || !mounted) return;
    try {
      final repository = await ref.read(vmRepositoryProvider.future);
      await repository.createNetwork(body);
      if (!mounted) return;
      ref.invalidate(vmNetworksProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _addStorage() async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController();
    final path = TextEditingController();
    var autoStart = true;
    final saved = await _showForm(
      title: l10n.vm_storages,
      children: (setFormState) => [
        AppTextField(controller: name, label: l10n.vm_name),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: path, label: l10n.vm_path),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.vm_autoStart),
          value: autoStart,
          onChanged: (value) => setFormState(() => autoStart = value),
        ),
      ],
    );
    final body = <String, dynamic>{
      'name': name.text.trim(),
      'type': 'dir',
      'path': path.text.trim(),
      'autoStart': autoStart,
    };
    name.dispose();
    path.dispose();
    if (!saved || !mounted) return;
    try {
      final repository = await ref.read(vmRepositoryProvider.future);
      await repository.createStorage(body);
      if (!mounted) return;
      ref.invalidate(vmStorageProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _addTemplate() async {
    final l10n = AppLocalizations.of(context);
    final source = TextEditingController();
    final name = TextEditingController();
    final saved = await _showForm(
      title: l10n.vm_templates,
      children: (_) => [
        AppTextField(controller: source, label: l10n.vm_sourceVm),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: name, label: l10n.vm_templateName),
      ],
    );
    final body = <String, dynamic>{
      'taskID': const Uuid().v4(),
      'name': source.text.trim(),
      'templateName': name.text.trim(),
    };
    source.dispose();
    name.dispose();
    if (!saved || !mounted) return;
    try {
      final repository = await ref.read(vmRepositoryProvider.future);
      await repository.createTemplate(body);
      if (!mounted) return;
      ref.invalidate(vmTemplateProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _addIso() async {
    final l10n = AppLocalizations.of(context);
    final mode = await showSelectionMenu<String>(
      context,
      title: l10n.vm_isos,
      options: [
        SelectionOption(
          value: 'create',
          label: l10n.vm_isoCreateRecord,
          icon: TablerIcons.plus,
        ),
        SelectionOption(
          value: 'import',
          label: l10n.vm_isoImport,
          icon: TablerIcons.file_import,
        ),
      ],
    );
    if (!mounted || mode == null) return;
    final name = TextEditingController();
    final path = TextEditingController();
    var type = 'iso';
    final saved = await _showForm(
      title: l10n.vm_isos,
      children: (setFormState) => [
        AppTextField(controller: name, label: l10n.vm_name),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: path, label: l10n.vm_path),
        const SizedBox(height: AppTokens.s12),
        DropdownButtonFormField<String>(
          initialValue: type,
          decoration: InputDecoration(labelText: l10n.vm_isoType),
          items: [
            DropdownMenuItem(value: 'iso', child: Text(l10n.vm_isoImage)),
            DropdownMenuItem(value: 'disk', child: Text(l10n.vm_isoDisk)),
          ],
          onChanged: (value) {
            if (value != null) setFormState(() => type = value);
          },
        ),
      ],
    );
    final body = <String, dynamic>{
      'type': type,
      'name': name.text.trim(),
      'path': path.text.trim(),
    };
    name.dispose();
    path.dispose();
    if (!saved || !mounted) return;
    try {
      final repository = await ref.read(vmRepositoryProvider.future);
      if (mode == 'import') {
        final id = await repository.startIsoImport({
          ...body,
          'status': 'uploading',
          'tempFileType': 'upload',
        });
        try {
          await repository.updateIsoImport({'id': id, 'status': 'ready'});
        } catch (error) {
          await repository.updateIsoImport({
            'id': id,
            'status': 'failed',
            'error': '$error',
          });
          rethrow;
        }
      } else {
        await repository.createIso(body);
      }
      if (!mounted) return;
      ref.invalidate(vmIsoProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<bool> _showForm({
    required String title,
    required List<Widget> Function(StateSetter setState) children,
  }) async {
    final result = await pushFormPage<bool>(
      context,
      StatefulBuilder(
        builder: (pageContext, setState) => SimpleFormPage(
          title: title,
          saveLabel: AppLocalizations.of(pageContext).action_create,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: children(setState),
        ),
      ),
    );
    return result == true;
  }
}

class _ResourceList extends ConsumerWidget {
  const _ResourceList({required this.kind});

  final _ResourceKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = switch (kind) {
      _ResourceKind.network => vmNetworksProvider,
      _ResourceKind.storage => vmStorageProvider,
      _ResourceKind.template => vmTemplateProvider,
      _ResourceKind.iso => vmIsoProvider,
    };
    return AsyncStateView(
      value: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      loading: const SkeletonList(itemCount: 4),
      isEmpty: (items) => items.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.stack_2,
        title: l10n.vm_resourceEmpty,
        message: l10n.vm_resources,
      ),
      builder: (items) => ListView.separated(
        padding: EdgeInsets.all(context.pagePadding),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
        itemBuilder: (context, index) {
          final item = items[index];
          final name = '${item['name'] ?? ''}';
          return TonalCard(
            onTap: () => _edit(context, ref, item),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.titleS),
                      Text(
                        [
                          if ('${item['type'] ?? ''}'.isNotEmpty)
                            '${item['type']}',
                          if ('${item['path'] ?? ''}'.isNotEmpty)
                            '${item['path']}',
                          if ('${item['cidr'] ?? ''}'.isNotEmpty)
                            '${item['cidr']}',
                          if ('${item['status'] ?? ''}'.isNotEmpty)
                            '${item['status']}',
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
                IconButton(
                  tooltip: l10n.action_delete,
                  icon: Icon(
                    TablerIcons.trash,
                    color: context.appColors.danger,
                  ),
                  onPressed: () => _delete(context, ref, name, item),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final repository = await ref.read(vmRepositoryProvider.future);
    final id = (item['id'] as num?)?.toInt() ?? 0;
    if (!context.mounted) return;
    try {
      if (kind == _ResourceKind.network) {
        await repository.updateNetwork({
          'id': id,
          'autoStart': item['autoStart'] != true,
        });
        ref.invalidate(vmNetworksProvider);
      } else if (kind == _ResourceKind.storage) {
        await repository.updateStorage({
          'id': id,
          'autoStart': item['autoStart'] != true,
        });
        ref.invalidate(vmStorageProvider);
      } else if (kind == _ResourceKind.iso) {
        final name = TextEditingController(text: '${item['name'] ?? ''}');
        final path = TextEditingController(text: '${item['path'] ?? ''}');
        var type = '${item['type'] ?? 'iso'}';
        final saved = await pushFormPage<bool>(
          context,
          StatefulBuilder(
            builder: (pageContext, setState) => SimpleFormPage(
              title: l10n.vm_isos,
              onSave: () async => Navigator.of(pageContext).pop(true),
              children: [
                AppTextField(controller: name, label: l10n.vm_name),
                const SizedBox(height: AppTokens.s12),
                AppTextField(controller: path, label: l10n.vm_path),
                const SizedBox(height: AppTokens.s12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: InputDecoration(labelText: l10n.vm_isoType),
                  items: [
                    DropdownMenuItem(
                      value: 'iso',
                      child: Text(l10n.vm_isoImage),
                    ),
                    DropdownMenuItem(
                      value: 'disk',
                      child: Text(l10n.vm_isoDisk),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => type = value);
                  },
                ),
              ],
            ),
          ),
        );
        final body = <String, dynamic>{
          'id': id,
          'type': type,
          'name': name.text.trim(),
          'path': path.text.trim(),
        };
        name.dispose();
        path.dispose();
        if (saved == true) {
          await repository.updateIso(body);
          ref.invalidate(vmIsoProvider);
        }
      } else {
        return;
      }
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    String name,
    Map<String, dynamic> item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: l10n.vm_deleteResource(name),
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(vmRepositoryProvider.future);
      final id = (item['id'] as num?)?.toInt() ?? 0;
      switch (kind) {
        case _ResourceKind.network:
          await repository.deleteNetwork(id);
        case _ResourceKind.storage:
          await repository.deleteStorage(id);
        case _ResourceKind.template:
          await repository.deleteTemplate(id);
        case _ResourceKind.iso:
          await repository.deleteIso(id);
      }
      if (!context.mounted) return;
      switch (kind) {
        case _ResourceKind.network:
          ref.invalidate(vmNetworksProvider);
        case _ResourceKind.storage:
          ref.invalidate(vmStorageProvider);
        case _ResourceKind.template:
          ref.invalidate(vmTemplateProvider);
        case _ResourceKind.iso:
          ref.invalidate(vmIsoProvider);
      }
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}
