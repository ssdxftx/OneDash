import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/common/page_result.dart';
import '../../../../data/dto/runtime/runtime_dto.dart';
import '../../../../data/repositories_impl/runtime_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import 'runtime_detail_page.dart';

final _runtimesProvider = FutureProvider.autoDispose<PageResult<RuntimeDto>>((
  ref,
) async {
  final repository = await ref.watch(runtimeRepositoryProvider.future);
  return repository.searchRuntimes(const {'page': 1, 'pageSize': 100});
}, name: 'runtimesProvider');

class RuntimesPage extends ConsumerWidget {
  const RuntimesPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final runtimes = ref.watch(_runtimesProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.more_runtimes,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_runtimesProvider),
          ),
          AppIconButton(
            icon: TablerIcons.cloud_download,
            tooltip: l10n.runtimes_sync,
            onPressed: () async {
              try {
                final repository = await ref.read(
                  runtimeRepositoryProvider.future,
                );
                await repository.syncRuntimes();
                ref.invalidate(_runtimesProvider);
              } catch (error) {
                if (!context.mounted) return;
                showErrorToast(context, error);
              }
            },
          ),
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.runtime_create,
            onPressed: () => _create(context, ref),
          ),
        ],
      ),
      body: AsyncStateView(
        value: runtimes,
        onRetry: () => ref.invalidate(_runtimesProvider),
        loading: const SkeletonList(itemCount: 8),
        isEmpty: (data) => data.items.isEmpty,
        empty: EmptyState(
          icon: TablerIcons.brand_docker,
          title: l10n.runtimes_emptyTitle,
          message: l10n.runtimes_emptyMessage,
        ),
        builder: (data) => ListView.builder(
          padding: EdgeInsets.all(context.pagePadding),
          itemCount: data.items.length,
          itemBuilder: (context, index) {
            final runtime = data.items[index];
            final imageLine = _joinNonEmpty([runtime.image, runtime.version]);
            final locationLine = _joinNonEmpty([runtime.port, runtime.path]);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.s12),
              child: TonalCard(
                onTap: () => _showActions(context, ref, runtime),
                onLongPress: () => _showActions(context, ref, runtime),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusDot(status: runtime.status.toLowerCase()),
                        const SizedBox(width: AppTokens.s8),
                        Expanded(
                          child: Text(
                            runtime.name,
                            style: AppTextStyles.titleM,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTokens.s8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.scheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppTokens.rXs),
                          ),
                          child: Text(
                            runtime.type,
                            style: AppTextStyles.caption,
                          ),
                        ),
                        Icon(
                          TablerIcons.chevron_right,
                          size: AppTokens.iconList,
                          color: context.scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    if (imageLine.isNotEmpty) ...[
                      const SizedBox(height: AppTokens.s8),
                      Text(
                        imageLine,
                        style: AppTextStyles.caption.copyWith(
                          color: context.scheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (locationLine.isNotEmpty) ...[
                      const SizedBox(height: AppTokens.s4),
                      Text(
                        locationLine,
                        style: AppTextStyles.caption.copyWith(
                          color: context.scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    RuntimeDto runtime,
  ) async {
    final l10n = AppLocalizations.of(context);
    final running = runtime.status.toLowerCase() == 'running';
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(runtime.name, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s4),
          Text(
            _joinNonEmpty([runtime.type, runtime.version]),
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.info_circle),
                title: l10n.error_details,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push(
                    '/s/$serverId/more/runtimes/${runtime.id}'
                    '?type=${Uri.encodeComponent(runtime.type)}'
                    '&name=${Uri.encodeComponent(runtime.name)}',
                  );
                },
              ),
              if (runtime.type.startsWith('php')) ...[
                SplitListTile(
                  leading: const Icon(TablerIcons.puzzle),
                  title: l10n.runtime_extensions,
                  onTap: () => showRuntimeTabSheet(
                    sheetContext,
                    serverId: serverId,
                    id: runtime.id,
                    type: runtime.type,
                    name: runtime.name,
                    tab: 0,
                  ),
                ),
                SplitListTile(
                  leading: const Icon(TablerIcons.file_code),
                  title: l10n.runtime_phpIni,
                  onTap: () => showRuntimeTabSheet(
                    sheetContext,
                    serverId: serverId,
                    id: runtime.id,
                    type: runtime.type,
                    name: runtime.name,
                    tab: 1,
                  ),
                ),
                SplitListTile(
                  leading: const Icon(TablerIcons.settings),
                  title: l10n.runtime_fpm,
                  onTap: () => showRuntimeTabSheet(
                    sheetContext,
                    serverId: serverId,
                    id: runtime.id,
                    type: runtime.type,
                    name: runtime.name,
                    tab: 2,
                  ),
                ),
              ] else if (runtime.type == 'node')
                SplitListTile(
                  leading: const Icon(TablerIcons.puzzle),
                  title: l10n.runtime_modules,
                  onTap: () => showRuntimeTabSheet(
                    sheetContext,
                    serverId: serverId,
                    id: runtime.id,
                    type: runtime.type,
                    name: runtime.name,
                    tab: 3,
                  ),
                ),
              SplitListTile(
                leading: const Icon(TablerIcons.player_play),
                title: running ? l10n.containers_stop : l10n.containers_start,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _operate(
                    context,
                    ref,
                    runtime,
                    running ? 'stop' : 'start',
                  );
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.edit),
                title: l10n.action_edit,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _edit(context, ref, runtime);
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.refresh),
                title: l10n.containers_restart,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _operate(context, ref, runtime, 'restart');
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.trash),
                title: l10n.action_delete,
                danger: true,
                enabled: !running,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _delete(context, ref, runtime);
                },
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
        ],
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController();
    final type = TextEditingController(text: 'php');
    final image = TextEditingController();
    final appDetailId = TextEditingController();
    final resource = TextEditingController();
    final version = TextEditingController();
    final codeDir = TextEditingController();
    final port = TextEditingController();
    final remark = TextEditingController();
    final params = TextEditingController(text: '{}');
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.runtime_create,
          saveLabel: l10n.action_create,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(controller: name, label: l10n.runtime_name),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: type, label: l10n.runtime_typeLabel),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: image, label: l10n.runtime_image),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: appDetailId,
              label: l10n.runtime_appDetailId,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: resource, label: l10n.runtime_resource),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: version, label: l10n.runtime_version),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: codeDir, label: l10n.runtime_codeDir),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: port,
              label: l10n.runtime_port,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: remark, label: l10n.runtime_remark),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: params,
              label: l10n.runtime_paramsJson,
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
    final nameValue = name.text.trim();
    final typeValue = type.text.trim();
    final imageValue = image.text.trim();
    final detailId = int.tryParse(appDetailId.text.trim()) ?? 0;
    final resourceValue = resource.text.trim();
    final versionValue = version.text.trim();
    final codeDirValue = codeDir.text.trim();
    final portValue = int.tryParse(port.text.trim()) ?? 0;
    final remarkValue = remark.text.trim();
    final paramsRaw = params.text.trim();
    name.dispose();
    type.dispose();
    image.dispose();
    appDetailId.dispose();
    resource.dispose();
    version.dispose();
    codeDir.dispose();
    port.dispose();
    remark.dispose();
    params.dispose();
    if (saved != true || !context.mounted || nameValue.isEmpty) return;
    Map<String, dynamic> parsed;
    try {
      final decoded = jsonDecode(paramsRaw.isEmpty ? '{}' : paramsRaw);
      if (decoded is! Map<String, dynamic>) {
        AppToast.warning(context, l10n.runtime_paramsInvalid);
        return;
      }
      parsed = decoded;
    } catch (_) {
      AppToast.warning(context, l10n.runtime_paramsInvalid);
      return;
    }
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      await repository.createRuntime(
        RuntimeCreateReq(
          name: nameValue,
          appDetailID: detailId,
          image: imageValue,
          params: parsed,
          type: typeValue,
          resource: resourceValue,
          version: versionValue,
          codeDir: codeDirValue,
          port: portValue,
          remark: remarkValue,
        ),
      );
      ref.invalidate(_runtimesProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    RuntimeDto runtime,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      final detail = await repository.getRuntime(runtime.id);
      if (!context.mounted) return;
      final name = TextEditingController(text: detail.name);
      final remark = TextEditingController(text: detail.remark);
      final port = TextEditingController(text: detail.port);
      final saved = await pushFormPage<bool>(
        context,
        Builder(
          builder: (pageContext) => SimpleFormPage(
            title: l10n.action_edit,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              AppTextField(controller: name, label: l10n.runtime_name),
              const SizedBox(height: AppTokens.s12),
              AppTextField(controller: port, label: l10n.runtime_port),
              const SizedBox(height: AppTokens.s12),
              AppTextField(controller: remark, label: l10n.runtime_remark),
            ],
          ),
        ),
      );
      final nameValue = name.text.trim();
      final remarkValue = remark.text.trim();
      final portValue = int.tryParse(port.text.trim().split(':').last) ?? 0;
      name.dispose();
      remark.dispose();
      port.dispose();
      if (saved != true || !context.mounted || nameValue.isEmpty) return;
      await repository.updateRuntime(
        RuntimeCreateReq(
          id: detail.id,
          name: nameValue,
          appDetailID: detail.appDetailID,
          image: detail.image,
          params: detail.params ?? const {},
          type: detail.type,
          resource: detail.resource,
          appID: detail.appID,
          version: detail.version,
          source: detail.source,
          codeDir: detail.codeDir,
          port: portValue,
          exposedPorts: detail.exposedPorts,
          environments: detail.environments,
          volumes: detail.volumes,
          extraHosts: detail.extraHosts,
          remark: remarkValue,
        ),
      );
      ref.invalidate(_runtimesProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    RuntimeDto runtime,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.runtimes_delete,
      message: l10n.runtimes_deleteConfirm(runtime.name),
      confirmLabel: l10n.action_delete,
      requireText: runtime.name,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      await repository.deleteRuntime(runtime.id, forceDelete: true);
      ref.invalidate(_runtimesProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _operate(
    BuildContext context,
    WidgetRef ref,
    RuntimeDto runtime,
    String operation,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(runtimeRepositoryProvider.future);
      await repository.operateRuntime(runtime.id, operation);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_runtimesProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

String _joinNonEmpty(List<String> values) {
  final parts = values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  return parts.join(' · ');
}
