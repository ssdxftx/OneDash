import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/container/image_dtos.dart';
import '../../../../data/dto/container/network_dtos.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/components/action_sheet.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/task_progress_sheet.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

final _imagesProvider = FutureProvider.autoDispose<List<DockerImageInfo>>((
  ref,
) async {
  final repository = await ref.watch(containerRepositoryProvider.future);
  final page = await repository.searchImages(
    const PageImageReq(page: 1, pageSize: 100),
  );
  return page.items;
}, name: 'containerImagesProvider');

final _reposProvider = FutureProvider.autoDispose<List<ImageRepoDto>>((
  ref,
) async {
  final repository = await ref.watch(containerRepositoryProvider.future);
  return repository.listImageRepos();
}, name: 'containerImageReposProvider');

final _networksProvider = FutureProvider.autoDispose<List<NetworkDto>>((
  ref,
) async {
  final repository = await ref.watch(containerRepositoryProvider.future);
  final page = await repository.searchNetworks(pageSize: 100);
  return page.items;
}, name: 'containerNetworksProvider');

class ContainerResourcesPage extends ConsumerStatefulWidget {
  const ContainerResourcesPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<ContainerResourcesPage> createState() =>
      _ContainerResourcesPageState();
}

class _ContainerResourcesPageState
    extends ConsumerState<ContainerResourcesPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.containers_resources,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () {
              ref.invalidate(_imagesProvider);
              ref.invalidate(_networksProvider);
              ref.invalidate(_reposProvider);
            },
          ),
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: _tab == 0
                ? l10n.containers_pullImage
                : _tab == 1
                ? l10n.containers_createNetwork
                : l10n.containers_addRepo,
            onPressed: _tab == 0
                ? _pullImage
                : _tab == 1
                ? _createNetwork
                : _createRepo,
          ),
        ],
      ),
      body: SegmentedTabsView(
        labels: [
          l10n.containers_images,
          l10n.nav_network,
          l10n.containers_imageRepos,
        ],
        onChanged: (value) => setState(() => _tab = value),
        children: const [_ImagesTab(), _NetworksTab(), _ReposTab()],
      ),
    );
  }

  Future<void> _pullImage() async {
    final l10n = AppLocalizations.of(context);
    final name = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => const _PullImageSheet(),
    );
    if (name == null || !mounted) return;
    final repository = await ref.read(containerRepositoryProvider.future);
    if (!mounted) return;
    final taskID = const Uuid().v4();
    final success = await TaskProgressSheet.run(
      context,
      title: l10n.containers_pullImage,
      task: (controller) async {
        await repository.pullImage(
          ImagePullReq(taskID: taskID, imageName: [name]),
        );
        await repository.waitForTask(
          taskID,
          onUpdate: (log) {
            if (log.lines.isNotEmpty) controller.log(log.lines.last);
          },
        );
      },
    );
    if (!success || !mounted) return;
    AppToast.success(context, l10n.action_done);
    ref.invalidate(_imagesProvider);
  }

  Future<void> _createRepo() async {
    final l10n = AppLocalizations.of(context);
    final request = await showAppSheet<Map<String, dynamic>>(
      context: context,
      builder: (sheetContext) => const _RepoSheet(),
    );
    if (request == null || !mounted) return;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.createImageRepo(
        name: '${request['name']}',
        downloadUrl: '${request['downloadUrl']}',
        protocol: '${request['protocol']}',
        auth: request['auth'] == true,
        username: '${request['username'] ?? ''}',
        password: '${request['password'] ?? ''}',
      );
      ref.invalidate(_reposProvider);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _createNetwork() async {
    final l10n = AppLocalizations.of(context);
    final request = await showAppSheet<NetworkCreateReq>(
      context: context,
      builder: (sheetContext) => const _CreateNetworkSheet(),
    );
    if (request == null || !mounted) return;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.createNetwork(request);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_networksProvider);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _ImagesTab extends ConsumerStatefulWidget {
  const _ImagesTab();

  @override
  ConsumerState<_ImagesTab> createState() => _ImagesTabState();
}

class _ImagesTabState extends ConsumerState<_ImagesTab> {
  bool _selecting = false;
  final Set<String> _selected = {};

  bool get _selectionMode => _selecting;

  String _nameOf(DockerImageInfo image) =>
      image.tags.isEmpty ? image.id : image.tags.first;

  void _toggle(DockerImageInfo image) {
    final name = _nameOf(image);
    setState(() {
      _selecting = true;
      if (!_selected.remove(name)) _selected.add(name);
    });
  }

  Future<void> _removeSelected() async {
    final l10n = AppLocalizations.of(context);
    final names = _selected.toList(growable: false);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.files_batchDelete,
      message: l10n.files_selectCount(names.length),
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !mounted) return;
    final repository = await ref.read(containerRepositoryProvider.future);
    if (!mounted) return;
    final taskID = const Uuid().v4();
    final success = await TaskProgressSheet.run(
      context,
      title: l10n.files_batchDelete,
      task: (controller) async {
        await repository.removeImage(
          BatchDeleteReq(taskID: taskID, names: names),
        );
        await repository.waitForTask(
          taskID,
          onUpdate: (log) {
            if (log.lines.isNotEmpty) controller.log(log.lines.last);
          },
        );
      },
    );
    if (!success || !mounted) return;
    setState(() {
      _selecting = false;
      _selected.clear();
    });
    AppToast.success(context, l10n.action_done);
    ref.invalidate(_imagesProvider);
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    DockerImageInfo image,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    await showAppSheet<void>(
      context: context,
      maxHeightFactor: 0.85,
      builder: (sheetContext) => ActionSheetScaffold(
        infoCard: ActionSheetInfoCard(
          leading: Container(
            decoration: BoxDecoration(
              color: colors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTokens.rMd),
            ),
            child: Icon(
              TablerIcons.photo,
              color: colors.info,
              size: AppTokens.iconNav,
            ),
          ),
          title: image.tags.isEmpty ? image.id : image.tags.first,
          subtitle: image.tags.length > 1
              ? image.tags.skip(1).join(', ')
              : (image.isUsed ? l10n.containers_inUse : l10n.containers_unused),
          trailing: image.isUsed
              ? ActionSheetStatusPill(
                  label: l10n.containers_inUse,
                  color: colors.warning,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ActionSheetSection(
              title: l10n.action_more,
              icon: TablerIcons.settings,
              children: [
                ActionSheetRow(
                  icon: TablerIcons.tag,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.containers_tagImage,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _tag(context, ref, image);
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.box_multiple,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.containers_containersUsingImage,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _containersByImage(context, ref, image);
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.hammer,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.containers_buildImage,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _imageOperation(context, ref, image, 'build');
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.file_export,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.containers_exportImage,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _imageOperation(context, ref, image, 'save');
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.file_import,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.containers_importImage,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _imageOperation(context, ref, image, 'load');
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.upload,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.containers_pushImage,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _imageOperation(context, ref, image, 'push');
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.trash,
                  iconColor: colors.danger,
                  title: l10n.action_delete,
                  danger: true,
                  enabled: !image.isUsed,
                  subtitle: image.isUsed
                      ? l10n.containers_imageInUseHint
                      : null,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _remove(context, ref, image);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _containersByImage(
    BuildContext context,
    WidgetRef ref,
    DockerImageInfo image,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = image.tags.isEmpty ? image.id : image.tags.first;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final items = await repository.getContainersByImage(name);
      if (!context.mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.containers_containersUsingImage,
              style: AppTextStyles.titleL,
            ),
            const SizedBox(height: AppTokens.s16),
            if (items.isEmpty)
              EmptyState(
                compact: true,
                icon: TablerIcons.box,
                title: l10n.state_empty,
              )
            else
              SplitListGroup(
                children: [
                  for (final item in items)
                    SplitListTile(
                      leading: const Icon(TablerIcons.box),
                      title: item.name,
                      subtitle: item.state,
                    ),
                ],
              ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _tag(
    BuildContext context,
    WidgetRef ref,
    DockerImageInfo image,
  ) async {
    final l10n = AppLocalizations.of(context);
    final tag = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => _TagImageSheet(image: image),
    );
    if (tag == null || !context.mounted) return;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.tagImage(ImageTagReq(sourceID: image.id, tags: [tag]));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_imagesProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    DockerImageInfo image,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = image.tags.isEmpty ? image.id : image.tags.first;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.containers_removeImage,
      message: l10n.containers_removeImageConfirm(name),
      confirmLabel: l10n.action_delete,
      requireText: name,
    );
    if (!confirmed || !context.mounted) return;
    final repository = await ref.read(containerRepositoryProvider.future);
    if (!context.mounted) return;
    final taskID = const Uuid().v4();
    final success = await TaskProgressSheet.run(
      context,
      title: l10n.containers_removeImage,
      task: (controller) async {
        await repository.removeImage(
          BatchDeleteReq(taskID: taskID, names: [name]),
        );
        await repository.waitForTask(
          taskID,
          onUpdate: (log) {
            if (log.lines.isNotEmpty) controller.log(log.lines.last);
          },
        );
      },
    );
    if (!success || !context.mounted) return;
    AppToast.success(context, l10n.action_done);
    ref.invalidate(_imagesProvider);
  }

  Future<void> _imageOperation(
    BuildContext context,
    WidgetRef ref,
    DockerImageInfo image,
    String operation,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = image.tags.isEmpty ? image.id : image.tags.first;
    final target = TextEditingController(text: name);
    final source = TextEditingController(text: 'scratch');
    final archive = TextEditingController(text: '/tmp/image.tar');
    final repo = TextEditingController(text: '0');
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: _operationLabel(operation, l10n),
          saveLabel: _operationLabel(operation, l10n),
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            if (operation == 'build') ...[
              AppTextField(
                controller: source,
                label: l10n.containers_baseImage,
              ),
              const SizedBox(height: AppTokens.s12),
            ],
            AppTextField(
              controller: target,
              label: operation == 'load'
                  ? l10n.containers_imageArchive
                  : operation == 'save'
                  ? l10n.files_path
                  : l10n.containers_newImageName,
            ),
            if (operation == 'build') ...[
              const SizedBox(height: AppTokens.s12),
              AppTextField(controller: archive, label: 'Dockerfile'),
            ],
            if (operation == 'push') ...[
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: repo,
                label: l10n.containers_repoId,
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ),
      ),
    );
    final value = target.text.trim();
    final sourceValue = source.text.trim();
    final archiveValue = archive.text.trim();
    final repoId = int.tryParse(repo.text.trim()) ?? 0;
    target.dispose();
    source.dispose();
    archive.dispose();
    repo.dispose();
    if (saved != true || !context.mounted || value.isEmpty) return;
    final repository = await ref.read(containerRepositoryProvider.future);
    if (!context.mounted) return;
    final taskID = const Uuid().v4();
    final success = await TaskProgressSheet.run(
      context,
      title: _operationLabel(operation, l10n),
      task: (controller) async {
        switch (operation) {
          case 'build':
            await repository.buildImage(
              ImageBuildReq(
                taskID: taskID,
                from: sourceValue.isEmpty ? 'scratch' : sourceValue,
                name: value,
                dockerfile: archiveValue,
              ),
            );
          case 'save':
            await repository.saveImage(
              ImageSaveReq(
                taskID: taskID,
                tagName: name,
                path: value,
                name: name,
              ),
            );
          case 'load':
            await repository.loadImage(
              ImageLoadReq(
                taskID: taskID,
                paths: value
                    .split(',')
                    .map((item) => item.trim())
                    .where((item) => item.isNotEmpty)
                    .toList(),
              ),
            );
          case 'push':
            await repository.pushImage(
              ImagePushReq(
                taskID: taskID,
                repoID: repoId,
                tagName: name,
                name: name,
              ),
            );
        }
        await repository.waitForTask(
          taskID,
          onUpdate: (log) {
            if (log.lines.isNotEmpty) controller.log(log.lines.last);
          },
        );
      },
    );
    if (!success || !context.mounted) return;
    AppToast.success(context, l10n.action_done);
    ref.invalidate(_imagesProvider);
  }

  String _operationLabel(String operation, AppLocalizations l10n) {
    return switch (operation) {
      'build' => l10n.containers_buildImage,
      'save' => l10n.containers_exportImage,
      'load' => l10n.containers_importImage,
      _ => l10n.containers_pushImage,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final images = ref.watch(_imagesProvider);
    return Column(
      children: [
        if (_selectionMode)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s16,
              AppTokens.s8,
              AppTokens.s16,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.files_selectCount(_selected.length),
                    style: AppTextStyles.bodyM,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    final items = images.valueOrNull ?? const [];
                    _selecting = true;
                    _selected
                      ..clear()
                      ..addAll(
                        items.where((image) => !image.isUsed).map(_nameOf),
                      );
                  }),
                  child: Text(l10n.files_selectAll),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _selecting = false;
                    _selected.clear();
                  }),
                  child: Text(l10n.files_cancelSelection),
                ),
              ],
            ),
          ),
        Expanded(
          child: AsyncStateView(
            value: images,
            onRetry: () => ref.invalidate(_imagesProvider),
            loading: const SkeletonList(itemCount: 6),
            isEmpty: (items) => items.isEmpty,
            empty: EmptyState(
              icon: TablerIcons.photo,
              title: l10n.containers_noImages,
              message: l10n.containers_pullImageHint,
            ),
            builder: (items) => ListView.separated(
              padding: EdgeInsets.all(context.pagePadding),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
              itemBuilder: (context, index) {
                final image = items[index];
                final name = _nameOf(image);
                return TonalCard(
                  onTap: _selectionMode
                      ? () => _toggle(image)
                      : () => _showActions(context, ref, image),
                  onLongPress: image.isUsed ? null : () => _toggle(image),
                  child: Row(
                    children: [
                      if (_selectionMode)
                        Checkbox(
                          value: _selected.contains(name),
                          onChanged: image.isUsed
                              ? null
                              : (_) => _toggle(image),
                        ),
                      Icon(
                        TablerIcons.photo,
                        color: context.scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppTokens.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              image.tags.isEmpty ? image.id : image.tags.first,
                              style: AppTextStyles.titleM,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${formatBytes(image.size)} · ${formatLocalDateTime(image.createdAt)}',
                              style: AppTextStyles.caption.copyWith(
                                color: context.scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (image.isUsed)
                        StatusDot(
                          status: 'running',
                          semanticLabel: l10n.containers_inUse,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (_selectionMode)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.s16),
              child: Align(
                alignment: Alignment.centerRight,
                child: DangerButton(
                  expanded: false,
                  icon: TablerIcons.trash,
                  label: '${l10n.files_batchDelete} (${_selected.length})',
                  onPressed: _removeSelected,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NetworksTab extends ConsumerStatefulWidget {
  const _NetworksTab();

  @override
  ConsumerState<_NetworksTab> createState() => _NetworksTabState();
}

class _NetworksTabState extends ConsumerState<_NetworksTab> {
  bool _selecting = false;
  final Set<String> _selected = {};

  bool get _selectionMode => _selecting;

  void _toggle(NetworkDto network) {
    setState(() {
      _selecting = true;
      if (!_selected.remove(network.name)) _selected.add(network.name);
    });
  }

  Future<void> _removeSelected() async {
    final l10n = AppLocalizations.of(context);
    final names = _selected.toList(growable: false);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.containers_removeNetwork,
      message: l10n.files_selectCount(names.length),
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.deleteNetworks(names);
      if (!mounted) return;
      setState(() {
        _selecting = false;
        _selected.clear();
      });
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_networksProvider);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    NetworkDto network,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.containers_removeNetwork,
      message: l10n.containers_removeNetworkConfirm(network.name),
      confirmLabel: l10n.action_delete,
      requireText: network.name,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.deleteNetworks([network.name]);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(_networksProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final networks = ref.watch(_networksProvider);
    return Column(
      children: [
        if (_selectionMode)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s16,
              AppTokens.s8,
              AppTokens.s16,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.files_selectCount(_selected.length),
                    style: AppTextStyles.bodyM,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    final items = networks.valueOrNull ?? const [];
                    _selecting = true;
                    _selected
                      ..clear()
                      ..addAll(
                        items
                            .where((network) => !network.isSystem)
                            .map((network) => network.name),
                      );
                  }),
                  child: Text(l10n.files_selectAll),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _selecting = false;
                    _selected.clear();
                  }),
                  child: Text(l10n.files_cancelSelection),
                ),
              ],
            ),
          ),
        Expanded(
          child: AsyncStateView(
            value: networks,
            onRetry: () => ref.invalidate(_networksProvider),
            loading: const SkeletonList(itemCount: 5),
            isEmpty: (items) => items.isEmpty,
            empty: EmptyState(
              icon: TablerIcons.network,
              title: l10n.containers_noNetworks,
              message: l10n.containers_createNetworkHint,
            ),
            builder: (items) => ListView.separated(
              padding: EdgeInsets.all(context.pagePadding),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
              itemBuilder: (context, index) {
                final network = items[index];
                return TonalCard(
                  onTap: _selectionMode && !network.isSystem
                      ? () => _toggle(network)
                      : null,
                  onLongPress: network.isSystem ? null : () => _toggle(network),
                  child: Row(
                    children: [
                      if (_selectionMode)
                        Checkbox(
                          value: _selected.contains(network.name),
                          onChanged: network.isSystem
                              ? null
                              : (_) => _toggle(network),
                        ),
                      Icon(
                        TablerIcons.network,
                        color: context.scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppTokens.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(network.name, style: AppTextStyles.titleM),
                            const SizedBox(height: 2),
                            Text(
                              [
                                network.driver,
                                if (network.subnet.isNotEmpty) network.subnet,
                              ].join(' · '),
                              style: AppTextStyles.caption.copyWith(
                                color: context.scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (network.isSystem)
                        ActionSheetStatusPill(
                          label: l10n.containers_system,
                          color: context.appColors.info,
                        )
                      else
                        IconButton(
                          tooltip: l10n.action_delete,
                          icon: Icon(
                            TablerIcons.trash,
                            color: context.appColors.danger,
                          ),
                          onPressed: () => _remove(context, ref, network),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (_selectionMode)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.s16),
              child: Align(
                alignment: Alignment.centerRight,
                child: DangerButton(
                  expanded: false,
                  icon: TablerIcons.trash,
                  label: '${l10n.files_batchDelete} (${_selected.length})',
                  onPressed: _removeSelected,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReposTab extends ConsumerWidget {
  const _ReposTab();

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    ImageRepoDto? current,
  ]) async {
    final l10n = AppLocalizations.of(context);
    final request = await showAppSheet<Map<String, dynamic>>(
      context: context,
      builder: (sheetContext) => _RepoSheet(repo: current),
    );
    if (request == null || !context.mounted) return;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      if (current == null) {
        await repository.createImageRepo(
          name: '${request['name']}',
          downloadUrl: '${request['downloadUrl']}',
          protocol: '${request['protocol']}',
          auth: request['auth'] == true,
          username: '${request['username'] ?? ''}',
          password: '${request['password'] ?? ''}',
        );
      } else {
        await repository.updateImageRepo(
          id: current.id,
          downloadUrl: '${request['downloadUrl']}',
          protocol: '${request['protocol']}',
          auth: request['auth'] == true,
          username: '${request['username'] ?? ''}',
          password: '${request['password'] ?? ''}',
        );
      }
      ref.invalidate(_reposProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _sync(
    BuildContext context,
    WidgetRef ref,
    ImageRepoDto repo,
  ) async {
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.syncImageRepo(repo.id);
      ref.invalidate(_reposProvider);
      if (!context.mounted) return;
      AppToast.success(context, AppLocalizations.of(context).action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ImageRepoDto repo,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: repo.name,
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.deleteImageRepo(repo.id);
      ref.invalidate(_reposProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repos = ref.watch(_reposProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.s16,
            AppTokens.s12,
            AppTokens.s16,
            0,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _search(context, ref),
              icon: const Icon(TablerIcons.search, size: 18),
              label: Text(l10n.action_search),
            ),
          ),
        ),
        Expanded(
          child: AsyncStateView(
            value: repos,
            onRetry: () => ref.invalidate(_reposProvider),
            loading: const SkeletonList(itemCount: 4),
            isEmpty: (items) => items.isEmpty,
            empty: EmptyState(
              icon: TablerIcons.building_warehouse,
              title: l10n.containers_noRepos,
              message: l10n.containers_noReposHint,
            ),
            builder: (items) => ListView.separated(
              padding: EdgeInsets.all(context.pagePadding),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
              itemBuilder: (context, index) {
                final repo = items[index];
                return TonalCard(
                  onTap: () => _edit(context, ref, repo),
                  child: Row(
                    children: [
                      const Icon(TablerIcons.building_warehouse),
                      const SizedBox(width: AppTokens.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(repo.name, style: AppTextStyles.titleM),
                            Text(
                              repo.downloadUrl,
                              style: AppTextStyles.caption.copyWith(
                                color: context.scheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.action_refresh,
                        icon: const Icon(TablerIcons.refresh),
                        onPressed: () => _sync(context, ref, repo),
                      ),
                      if (!repo.isBuiltIn)
                        IconButton(
                          tooltip: l10n.action_delete,
                          icon: Icon(
                            TablerIcons.trash,
                            color: context.appColors.danger,
                          ),
                          onPressed: () => _delete(context, ref, repo),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _search(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final query = await pushFormPage<String>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.action_search,
          saveLabel: l10n.action_search,
          onSave: () async =>
              Navigator.of(pageContext).pop(controller.text.trim()),
          children: [AppTextField(controller: controller, autofocus: true)],
        ),
      ),
    );
    controller.dispose();
    if (query == null || !context.mounted) return;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final result = await repository.searchImageRepos(info: query);
      if (!context.mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.85,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.action_search, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            if (result.items.isEmpty)
              EmptyState(
                compact: true,
                icon: TablerIcons.building_warehouse,
                title: l10n.state_empty,
              )
            else
              SplitListGroup(
                children: [
                  for (final item in result.items)
                    SplitListTile(
                      leading: const Icon(TablerIcons.building_warehouse),
                      title: item.name,
                      subtitle: item.downloadUrl,
                    ),
                ],
              ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _RepoSheet extends StatefulWidget {
  const _RepoSheet({this.repo});

  final ImageRepoDto? repo;

  @override
  State<_RepoSheet> createState() => _RepoSheetState();
}

class _RepoSheetState extends State<_RepoSheet> {
  late final _name = TextEditingController(text: widget.repo?.name ?? '');
  late final _url = TextEditingController(text: widget.repo?.downloadUrl ?? '');
  late final _username = TextEditingController(
    text: widget.repo?.username ?? '',
  );
  late final _password = TextEditingController(
    text: widget.repo?.password ?? '',
  );
  late String _protocol = widget.repo?.protocol ?? 'https';
  late bool _auth = widget.repo?.auth ?? false;

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.repo == null
              ? l10n.containers_addRepo
              : l10n.containers_editRepo,
          style: AppTextStyles.titleL,
        ),
        const SizedBox(height: AppTokens.s16),
        AppTextField(
          controller: _name,
          label: l10n.containers_name,
          enabled: widget.repo == null,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: _url, label: l10n.containers_repoUrl),
        const SizedBox(height: AppTokens.s12),
        DropdownButtonFormField<String>(
          initialValue: _protocol,
          decoration: InputDecoration(labelText: l10n.containers_protocol),
          items: const [
            DropdownMenuItem(value: 'https', child: Text('HTTPS')),
            DropdownMenuItem(value: 'http', child: Text('HTTP')),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _protocol = value);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.containers_repoAuth),
          value: _auth,
          onChanged: (value) => setState(() => _auth = value),
        ),
        if (_auth) ...[
          AppTextField(controller: _username, label: l10n.websites_username),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: _password,
            label: l10n.websites_password,
            obscure: true,
          ),
        ],
        const SizedBox(height: AppTokens.s16),
        PrimaryButton(
          label: l10n.action_save,
          onPressed: () {
            if (_name.text.trim().isEmpty || _url.text.trim().isEmpty) return;
            Navigator.of(context).pop({
              'name': _name.text.trim(),
              'downloadUrl': _url.text.trim(),
              'protocol': _protocol,
              'auth': _auth,
              'username': _username.text.trim(),
              'password': _password.text,
            });
          },
        ),
      ],
    );
  }
}

class _PullImageSheet extends StatefulWidget {
  const _PullImageSheet();

  @override
  State<_PullImageSheet> createState() => _PullImageSheetState();
}

class _PullImageSheetState extends State<_PullImageSheet> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.containers_pullImage, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s16),
        AppTextField(
          controller: _name,
          label: l10n.containers_image,
          hint: 'nginx:latest',
          autofocus: true,
        ),
        const SizedBox(height: AppTokens.s16),
        PrimaryButton(
          label: l10n.containers_pullImage,
          onPressed: () {
            final name = _name.text.trim();
            if (name.isEmpty) return;
            Navigator.of(context).pop(name);
          },
        ),
      ],
    );
  }
}

class _TagImageSheet extends StatefulWidget {
  const _TagImageSheet({required this.image});

  final DockerImageInfo image;

  @override
  State<_TagImageSheet> createState() => _TagImageSheetState();
}

class _TagImageSheetState extends State<_TagImageSheet> {
  late final TextEditingController _tag = TextEditingController(
    text: widget.image.tags.isEmpty ? '' : widget.image.tags.first,
  );

  @override
  void dispose() {
    _tag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.containers_tagImage, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s16),
        AppTextField(
          controller: _tag,
          label: l10n.containers_newImageName,
          hint: 'repo/name:tag',
        ),
        const SizedBox(height: AppTokens.s16),
        PrimaryButton(
          label: l10n.action_save,
          onPressed: () {
            final tag = _tag.text.trim();
            if (tag.isEmpty) return;
            Navigator.of(context).pop(tag);
          },
        ),
      ],
    );
  }
}

class _CreateNetworkSheet extends StatefulWidget {
  const _CreateNetworkSheet();

  @override
  State<_CreateNetworkSheet> createState() => _CreateNetworkSheetState();
}

class _CreateNetworkSheetState extends State<_CreateNetworkSheet> {
  final _name = TextEditingController();
  final _subnet = TextEditingController();
  final _gateway = TextEditingController();
  final _subnetV6 = TextEditingController();
  final _gatewayV6 = TextEditingController();
  String _driver = 'bridge';
  bool _ipv4 = false;
  bool _ipv6 = false;

  @override
  void dispose() {
    _name.dispose();
    _subnet.dispose();
    _gateway.dispose();
    _subnetV6.dispose();
    _gatewayV6.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.containers_createNetwork, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s16),
        AppTextField(
          controller: _name,
          label: l10n.containers_name,
          hint: 'app-net',
        ),
        const SizedBox(height: AppTokens.s12),
        DropdownButtonFormField<String>(
          initialValue: _driver,
          decoration: InputDecoration(labelText: l10n.containers_driver),
          items: const [
            DropdownMenuItem(value: 'bridge', child: Text('bridge')),
            DropdownMenuItem(value: 'overlay', child: Text('overlay')),
            DropdownMenuItem(value: 'macvlan', child: Text('macvlan')),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _driver = value);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('IPv4'),
          value: _ipv4,
          onChanged: (value) => setState(() => _ipv4 = value),
        ),
        if (_ipv4) ...[
          AppTextField(
            controller: _subnet,
            label: l10n.containers_subnet,
            hint: '172.20.0.0/16',
          ),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: _gateway,
            label: l10n.containers_gateway,
            hint: '172.20.0.1',
          ),
        ],
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('IPv6'),
          value: _ipv6,
          onChanged: (value) => setState(() => _ipv6 = value),
        ),
        if (_ipv6) ...[
          AppTextField(
            controller: _subnetV6,
            label: l10n.containers_subnet,
            hint: 'fd00::/64',
          ),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: _gatewayV6,
            label: l10n.containers_gateway,
            hint: 'fd00::1',
          ),
        ],
        const SizedBox(height: AppTokens.s16),
        PrimaryButton(
          label: l10n.action_create,
          onPressed: () {
            final name = _name.text.trim();
            if (name.isEmpty) return;
            Navigator.of(context).pop(
              NetworkCreateReq(
                name: name,
                driver: _driver,
                ipv4: _ipv4,
                subnet: _subnet.text.trim(),
                gateway: _gateway.text.trim(),
                ipv6: _ipv6,
                subnetV6: _subnetV6.text.trim(),
                gatewayV6: _gatewayV6.text.trim(),
              ),
            );
          },
        ),
      ],
    );
  }
}
