import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/container/container_info_dto.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/error_toast.dart';
import '../providers/containers_provider.dart';

class ContainerCreatePage extends ConsumerStatefulWidget {
  const ContainerCreatePage({
    super.key,
    required this.serverId,
    this.containerName,
  });

  final int serverId;
  final String? containerName;

  bool get isEditing => containerName != null;

  @override
  ConsumerState<ContainerCreatePage> createState() =>
      _ContainerCreatePageState();
}

class _ContainerCreatePageState extends ConsumerState<ContainerCreatePage> {
  final _image = TextEditingController();
  final _name = TextEditingController();
  final _workingDir = TextEditingController();
  final _command = TextEditingController();
  final _entrypoint = TextEditingController();
  final _cpu = TextEditingController();
  final _memory = TextEditingController();
  final _ports = <_PortFields>[_PortFields()];
  final _volumes = <_VolumeFields>[_VolumeFields()];
  final _envs = <_EnvFields>[_EnvFields()];

  String _restartPolicy = 'unless-stopped';
  String _network = '1panel-network';
  bool _privileged = false;
  bool _autoRemove = false;
  bool _submitting = false;
  List<String> _images = const [];
  List<String> _networks = const ['1panel-network'];
  ContainerInfoDto? _initial;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final images = await repository.getImages();
      final networks = await repository.getNetworks();
      final initial = widget.containerName == null
          ? null
          : await repository.getContainerInfo(widget.containerName!);
      if (!mounted) return;
      setState(() {
        _images = images
            .map((image) => image.option)
            .where((image) => image.isNotEmpty)
            .toList();
        _networks = {
          _network,
          ...networks
              .map((network) => network.option)
              .where((network) => network.isNotEmpty),
        }.toList();
        if (initial != null) _applyInitial(initial);
      });
    } catch (error) {
      if (!mounted) return;
      if (widget.isEditing) showErrorToast(context, error);
    }
  }

  void _applyInitial(ContainerInfoDto initial) {
    _initial = initial;
    _image.text = initial.image;
    _name.text = initial.name;
    _workingDir.text = initial.workingDir;
    _command.text = initial.cmd?.join(' ') ?? '';
    _entrypoint.text = initial.entrypoint?.join(' ') ?? '';
    _cpu.text = initial.nanoCPUs <= 0
        ? ''
        : (initial.nanoCPUs / 1000000000).toStringAsFixed(2);
    _memory.text = initial.memory <= 0
        ? ''
        : '${(initial.memory / 1024 / 1024).round()}';
    _restartPolicy = initial.restartPolicy.isEmpty
        ? 'unless-stopped'
        : initial.restartPolicy;
    _privileged = initial.privileged;
    _autoRemove = initial.autoRemove;
    if (initial.networks.isNotEmpty) {
      _network = initial.networks.first.network;
      _networks = {_network, ..._networks}.toList();
    }
    for (final port in _ports) {
      port.dispose();
    }
    _ports
      ..clear()
      ..addAll(initial.exposedPorts.map((port) => _PortFields()..fill(port)));
    if (_ports.isEmpty) _ports.add(_PortFields());
    for (final volume in _volumes) {
      volume.dispose();
    }
    _volumes
      ..clear()
      ..addAll(initial.volumes.map((volume) => _VolumeFields()..fill(volume)));
    if (_volumes.isEmpty) _volumes.add(_VolumeFields());
    for (final env in _envs) {
      env.dispose();
    }
    _envs
      ..clear()
      ..addAll(initial.env.map((value) => _EnvFields()..fill(value)));
    if (_envs.isEmpty) _envs.add(_EnvFields());
  }

  @override
  void dispose() {
    _image.dispose();
    _name.dispose();
    _workingDir.dispose();
    _command.dispose();
    _entrypoint.dispose();
    _cpu.dispose();
    _memory.dispose();
    for (final port in _ports) {
      port.dispose();
    }
    for (final volume in _volumes) {
      volume.dispose();
    }
    for (final env in _envs) {
      env.dispose();
    }
    super.dispose();
  }

  bool get _canSubmit =>
      _image.text.trim().isNotEmpty && _name.text.trim().isNotEmpty;

  Future<void> _pickImage() async {
    final image = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => _ImagePickerSheet(images: _images),
    );
    if (image == null || image.isEmpty) return;
    setState(() => _image.text = image);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final providerContainer = ProviderScope.containerOf(context, listen: false);
    final name = _name.text.trim();
    final image = _image.text.trim();
    if (!RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9_.-]*$').hasMatch(name)) {
      AppToast.warning(context, l10n.containers_nameInvalid);
      return;
    }
    if (image.isEmpty) {
      AppToast.warning(context, l10n.containers_imageRequired);
      return;
    }
    setState(() => _submitting = true);
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final payload = _payload(name, image);
      if (widget.isEditing) {
        await repository.updateContainer(payload);
      } else {
        final taskID = await repository.createContainer(payload);
        await repository.waitForTask(taskID);
      }
      providerContainer.invalidate(containersProvider);
      if (!mounted) return;
      AppToast.success(
        context,
        widget.isEditing ? l10n.containers_updated : l10n.containers_created,
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Map<String, dynamic> _payload(String name, String image) {
    final ports = _ports
        .where(
          (port) =>
              port.host.text.trim().isNotEmpty &&
              port.container.text.trim().isNotEmpty,
        )
        .map(
          (port) => {
            'hostIP': '',
            'hostPort': port.host.text.trim(),
            'containerPort': port.container.text.trim(),
            'protocol': port.protocol,
          },
        )
        .toList();
    final volumes = _volumes
        .where(
          (volume) =>
              volume.source.text.trim().isNotEmpty &&
              volume.target.text.trim().isNotEmpty,
        )
        .map(
          (volume) => {
            'type': 'bind',
            'sourceDir': volume.source.text.trim(),
            'containerDir': volume.target.text.trim(),
            'mode': 'rw',
          },
        )
        .toList();
    final env = _envs
        .map((entry) => entry.value.text.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    final cpu = double.tryParse(_cpu.text.trim()) ?? 0;
    final memory = int.tryParse(_memory.text.trim()) ?? 0;
    final initial = _initial;
    final networks = initial == null
        ? [
            {
              'network': _network,
              'ipv4': '',
              'ipv6': '',
              'macAddr': '',
              'links': <String>[],
              'aliases': <String>[],
              'driverOpts': <String, String>{},
              'gwPriority': 0,
              'linkLocalIPs': <String>[],
            },
          ]
        : initial.networks
              .map(
                (network) => {
                  ...network.toJson(),
                  'links': <String>[],
                  'aliases': <String>[],
                  'driverOpts': <String, String>{},
                  'gwPriority': 0,
                  'linkLocalIPs': <String>[],
                },
              )
              .toList();
    if (networks.isEmpty) {
      networks.add({
        'network': _network,
        'ipv4': '',
        'ipv6': '',
        'macAddr': '',
        'links': <String>[],
        'aliases': <String>[],
        'driverOpts': <String, String>{},
        'gwPriority': 0,
        'linkLocalIPs': <String>[],
      });
    } else {
      networks.first['network'] = _network;
    }

    return {
      'taskID': initial?.taskID ?? const Uuid().v4(),
      'forcePull': initial?.forcePull ?? false,
      'name': name,
      'image': image,
      'hostname': initial?.hostname ?? '',
      'domainName': initial?.domainName ?? '',
      'dns': initial?.dns ?? <String>[],
      'networks': networks,
      'publishAllPorts': initial?.publishAllPorts ?? false,
      'exposedPorts': ports,
      'tty': initial?.tty ?? false,
      'openStdin': initial?.openStdin ?? false,
      'workingDir': _workingDir.text.trim(),
      'user': initial?.user ?? '',
      'cmd': _split(_command.text),
      'entrypoint': _split(_entrypoint.text),
      'cpuShares': initial?.cpuShares ?? 0,
      'nanoCPUs': cpu <= 0 ? 0 : cpu * 1000000000,
      'memory': memory <= 0 ? 0 : memory * 1024 * 1024,
      'volumes': volumes,
      'extraHosts': initial?.extraHosts ?? <String>[],
      'privileged': _privileged,
      'autoRemove': _autoRemove,
      'labels': initial?.labels ?? <String>[],
      'env': env,
      'restartPolicy': _restartPolicy,
    };
  }

  List<String> _split(String value) => value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  void _addPort() => setState(() => _ports.add(_PortFields()));
  void _addVolume() => setState(() => _volumes.add(_VolumeFields()));
  void _addEnv() => setState(() => _envs.add(_EnvFields()));

  void _removePort(int index) {
    if (_ports.length <= 1) return;
    setState(() => _ports.removeAt(index).dispose());
  }

  void _removeVolume(int index) {
    if (_volumes.length <= 1) return;
    setState(() => _volumes.removeAt(index).dispose());
  }

  void _removeEnv(int index) {
    if (_envs.length <= 1) return;
    setState(() => _envs.removeAt(index).dispose());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: widget.isEditing ? l10n.containers_edit : l10n.containers_create,
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
        children: [
          SectionHeader(title: l10n.containers_title),
          TonalCard(
            child: Column(
              children: [
                AppTextField(
                  controller: _image,
                  label: l10n.containers_image,
                  hint: 'nginx:alpine',
                  suffix: IconButton(
                    tooltip: l10n.containers_selectImage,
                    onPressed: _pickImage,
                    icon: const Icon(TablerIcons.photo),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: _name,
                  label: l10n.containers_name,
                  hint: 'my-nginx',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppTokens.s12),
                DropdownButtonFormField<String>(
                  initialValue: _restartPolicy,
                  decoration: InputDecoration(
                    labelText: l10n.containers_restartPolicy,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'unless-stopped',
                      child: Text('unless-stopped'),
                    ),
                    DropdownMenuItem(value: 'always', child: Text('always')),
                    DropdownMenuItem(
                      value: 'on-failure',
                      child: Text('on-failure'),
                    ),
                    DropdownMenuItem(value: 'no', child: Text('no')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _restartPolicy = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s24),
          SectionHeader(
            title: l10n.containers_ports,
            trailing: TextButton(
              onPressed: _addPort,
              child: Text(l10n.containers_add),
            ),
          ),
          for (var index = 0; index < _ports.length; index++) ...[
            _PortRow(
              fields: _ports[index],
              onRemove: () => _removePort(index),
              onChanged: () => setState(() {}),
              canRemove: _ports.length > 1,
            ),
            const SizedBox(height: AppTokens.s8),
          ],
          const SizedBox(height: AppTokens.s16),
          SectionHeader(
            title: l10n.containers_volumes,
            trailing: TextButton(
              onPressed: _addVolume,
              child: Text(l10n.containers_add),
            ),
          ),
          for (var index = 0; index < _volumes.length; index++) ...[
            _VolumeRow(
              fields: _volumes[index],
              onRemove: () => _removeVolume(index),
              canRemove: _volumes.length > 1,
            ),
            const SizedBox(height: AppTokens.s8),
          ],
          const SizedBox(height: AppTokens.s16),
          SectionHeader(
            title: l10n.containers_env,
            trailing: TextButton(
              onPressed: _addEnv,
              child: Text(l10n.containers_add),
            ),
          ),
          for (var index = 0; index < _envs.length; index++) ...[
            TonalCard(
              padding: const EdgeInsets.all(AppTokens.s12),
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _envs[index].value,
                      hint: l10n.containers_envHint,
                    ),
                  ),
                  if (_envs.length > 1)
                    IconButton(
                      tooltip: l10n.containers_removeRow,
                      onPressed: () => _removeEnv(index),
                      icon: const Icon(TablerIcons.trash),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s8),
          ],
          const SizedBox(height: AppTokens.s16),
          TonalCard(
            padding: EdgeInsets.zero,
            child: ExpansionTile(
              title: Text(
                l10n.containers_advanced,
                style: AppTextStyles.titleS,
              ),
              subtitle: Text(
                l10n.containers_advancedHint,
                style: AppTextStyles.bodyS.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(
                AppTokens.s16,
                0,
                AppTokens.s16,
                AppTokens.s16,
              ),
              children: [
                AppTextField(
                  controller: _command,
                  label: l10n.containers_command,
                  hint: l10n.containers_cmdHint,
                ),
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: _entrypoint,
                  label: l10n.containers_entrypoint,
                  hint: l10n.containers_entrypointHint,
                ),
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: _workingDir,
                  label: l10n.containers_workingDir,
                  hint: l10n.containers_workingDirHint,
                ),
                const SizedBox(height: AppTokens.s12),
                DropdownButtonFormField<String>(
                  initialValue: _network,
                  decoration: InputDecoration(
                    labelText: l10n.containers_network,
                  ),
                  items: [
                    for (final network in _networks)
                      DropdownMenuItem(value: network, child: Text(network)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _network = value);
                  },
                ),
                const SizedBox(height: AppTokens.s12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _cpu,
                        label: l10n.containers_cpuLimit,
                        hint: '1.0',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTokens.s12),
                    Expanded(
                      child: AppTextField(
                        controller: _memory,
                        label: l10n.containers_memoryLimit,
                        hint: '512',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.containers_privileged),
                  value: _privileged,
                  onChanged: (value) => setState(() => _privileged = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.containers_autoRemove),
                  value: _autoRemove,
                  onChanged: (value) => setState(() => _autoRemove = value),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppTokens.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              label: _submitting
                  ? l10n.containers_saving
                  : widget.isEditing
                  ? l10n.action_save
                  : l10n.containers_createSubmit,
              loading: _submitting,
              onPressed:
                  _canSubmit &&
                      !_submitting &&
                      (!widget.isEditing || _initial != null)
                  ? _submit
                  : null,
            ),
            if (_submitting) ...[
              const SizedBox(height: AppTokens.s8),
              SecondaryButton(
                label: l10n.containers_continueInBackground,
                icon: TablerIcons.arrow_back,
                onPressed: () {
                  ProviderScope.containerOf(
                    context,
                    listen: false,
                  ).invalidate(containersProvider);
                  context.pop();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PortFields {
  final host = TextEditingController();
  final container = TextEditingController();
  String protocol = 'tcp';

  void fill(ContainerPortDto port) {
    host.text = port.hostPort;
    container.text = port.containerPort;
    protocol = port.protocol.isEmpty ? 'tcp' : port.protocol;
  }

  void dispose() {
    host.dispose();
    container.dispose();
  }
}

class _VolumeFields {
  final source = TextEditingController();
  final target = TextEditingController();

  void fill(ContainerVolumeDto volume) {
    source.text = volume.sourceDir;
    target.text = volume.containerDir;
  }

  void dispose() {
    source.dispose();
    target.dispose();
  }
}

class _EnvFields {
  final value = TextEditingController();

  void fill(String env) {
    value.text = env;
  }

  void dispose() {
    value.dispose();
  }
}

class _PortRow extends StatelessWidget {
  const _PortRow({
    required this.fields,
    required this.onRemove,
    required this.onChanged,
    required this.canRemove,
  });

  final _PortFields fields;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TonalCard(
      padding: const EdgeInsets.all(AppTokens.s12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: fields.host,
                  label: l10n.containers_hostPort,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: AppTokens.s12),
              Expanded(
                child: AppTextField(
                  controller: fields.container,
                  label: l10n.containers_containerPort,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: fields.protocol,
                  decoration: InputDecoration(
                    labelText: l10n.firewall_ruleProtocol,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'tcp', child: Text('TCP')),
                    DropdownMenuItem(value: 'udp', child: Text('UDP')),
                  ],
                  onChanged: (value) {
                    if (value != null) fields.protocol = value;
                  },
                ),
              ),
              if (canRemove)
                IconButton(
                  tooltip: l10n.containers_removeRow,
                  onPressed: onRemove,
                  icon: const Icon(TablerIcons.trash),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VolumeRow extends StatelessWidget {
  const _VolumeRow({
    required this.fields,
    required this.onRemove,
    required this.canRemove,
  });

  final _VolumeFields fields;
  final VoidCallback onRemove;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TonalCard(
      padding: const EdgeInsets.all(AppTokens.s12),
      child: Column(
        children: [
          AppTextField(
            controller: fields.source,
            label: l10n.containers_sourceDir,
            hint: '/opt/html',
          ),
          const SizedBox(height: AppTokens.s12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: fields.target,
                  label: l10n.containers_containerDir,
                  hint: '/usr/share/nginx/html',
                ),
              ),
              if (canRemove)
                IconButton(
                  tooltip: l10n.containers_removeRow,
                  onPressed: onRemove,
                  icon: const Icon(TablerIcons.trash),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImagePickerSheet extends StatefulWidget {
  const _ImagePickerSheet({required this.images});

  final List<String> images;

  @override
  State<_ImagePickerSheet> createState() => _ImagePickerSheetState();
}

class _ImagePickerSheetState extends State<_ImagePickerSheet> {
  final _manual = TextEditingController();

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.containers_selectImage, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s16),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _manual,
                hint: 'nginx:alpine',
                label: l10n.containers_manualInput,
              ),
            ),
            const SizedBox(width: AppTokens.s8),
            IconButton(
              tooltip: l10n.action_confirm,
              onPressed: () => Navigator.of(context).pop(_manual.text.trim()),
              icon: const Icon(TablerIcons.check),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s16),
        if (widget.images.isEmpty)
          Text(
            l10n.containers_noImages,
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: SingleChildScrollView(
              child: SplitListGroup(
                children: [
                  for (final image in widget.images)
                    SplitListTile(
                      leading: const Icon(TablerIcons.box),
                      title: image,
                      onTap: () => Navigator.of(context).pop(image),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
