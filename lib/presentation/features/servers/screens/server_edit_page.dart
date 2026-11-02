import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/server_repository_impl.dart';
import '../../../../domain/entities/server.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/tonal_card.dart';
import '../providers/servers_provider.dart';
import '../../../common/states/error_mapper.dart';
import '../../../common/states/error_state.dart';
import '../../../common/states/error_toast.dart';

enum _StepState { idle, running, ok, failed, skipped }

class _DiagnosisStep {
  const _DiagnosisStep(this.title, {this.state = _StepState.idle, this.detail});

  final String title;
  final _StepState state;
  final String? detail;
}

class ServerEditPage extends ConsumerStatefulWidget {
  const ServerEditPage({super.key, this.serverId});

  final int? serverId;

  bool get isEditing => serverId != null;

  @override
  ConsumerState<ServerEditPage> createState() => _ServerEditPageState();
}

class _ServerEditPageState extends ConsumerState<ServerEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '9999');
  final _apiKeyController = TextEditingController();

  bool _isHttps = false;
  bool _allowInsecure = false;
  bool _obscureKey = true;
  bool _saving = false;
  bool _loading = false;
  bool _diagnosing = false;
  Object? _loadError;

  List<_DiagnosisStep> _steps = const [];
  String? _clockDrift;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _loadServer();
  }

  Future<void> _loadServer() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final repository = ref.read(serverRepositoryProvider);
      final server = await repository.find(widget.serverId!);
      final apiKey = await repository.getApiKey(widget.serverId!);
      if (!mounted) return;
      if (server != null) {
        _nameController.text = server.name ?? '';
        _hostController.text = server.host;
        _portController.text = '${server.port}';
        _apiKeyController.text = apiKey ?? '';
        _isHttps = server.isHttps;
        _allowInsecure = server.allowInsecureConnections;
      }
    } catch (error) {
      if (!mounted) return;
      _loadError = error;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _syncDefaultPort(bool isHttps) {
    final current = _portController.text.trim();
    if (current == '9999' || current == '443' || current.isEmpty) {
      _portController.text = isHttps ? '443' : '9999';
    }
  }

  String? _validateHost(String? value) {
    final l10n = AppLocalizations.of(context);
    final host = value?.trim() ?? '';
    if (host.isEmpty) return l10n.server_edit_validation_host_required;
    if (host.contains('://')) {
      return l10n.server_edit_validation_host_protocol;
    }
    if (host.contains(' ')) return l10n.server_edit_validation_host_space;
    return null;
  }

  String? _validatePort(String? value) {
    final port = int.tryParse(value?.trim() ?? '');
    if (port == null || port < 1 || port > 65535) {
      return AppLocalizations.of(context).server_edit_validation_port_range;
    }
    return null;
  }

  String? _validateKey(String? value) {
    final l10n = AppLocalizations.of(context);
    final key = value?.trim() ?? '';
    if (key.length < 16) return l10n.server_edit_validation_key_length;
    if (key.contains(' ')) return l10n.server_edit_validation_key_space;
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final repository = ref.read(serverRepositoryProvider);
    final l10n = AppLocalizations.of(context);
    try {
      final host = _hostController.text.trim();
      final port = int.parse(_portController.text.trim());
      final name = _nameController.text.trim();
      final apiKey = _apiKeyController.text.trim();

      late Server server;
      if (widget.isEditing) {
        final existing = await repository.find(widget.serverId!);
        if (existing == null) throw const ServerNotFoundException();
        existing
          ..name = name.isEmpty ? null : name
          ..host = host
          ..port = port
          ..isHttps = _isHttps
          ..allowInsecureConnections = _allowInsecure
          ..updatedAt = DateTime.now();
        await repository.update(existing, apiKey: apiKey);
        server = existing;
      } else {
        server = await repository.add(
          name: name.isEmpty ? null : name,
          host: host,
          port: port,
          isHttps: _isHttps,
          allowInsecureConnections: _allowInsecure,
          apiKey: apiKey,
        );
      }
      await ref.read(serversProvider.notifier).touch(server.id);
      if (!mounted) return;
      AppToast.success(context, l10n.server_edit_savedConnecting);
      context.go('/s/${server.id}/overview');
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showErrorToast(context, error);
    }
  }

  Future<void> _runDiagnosis() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = AppLocalizations.of(context);
    final host = _hostController.text.trim();
    final port = int.parse(_portController.text.trim());
    final apiKey = _apiKeyController.text.trim();

    setState(() {
      _diagnosing = true;
      _clockDrift = null;
      _steps = [
        _DiagnosisStep(
          l10n.server_edit_diag_network,
          state: _StepState.running,
        ),
        _DiagnosisStep(
          l10n.server_edit_diag_tls,
          state: _isHttps ? _StepState.idle : _StepState.skipped,
        ),
        _DiagnosisStep(l10n.server_edit_diag_auth, state: _StepState.idle),
        _DiagnosisStep(
          l10n.server_edit_diag_capability,
          state: _StepState.idle,
        ),
      ];
    });

    Future<void> update(int index, _DiagnosisStep step) async {
      if (!mounted) return;
      setState(() {
        final next = List<_DiagnosisStep>.of(_steps);
        next[index] = step;
        _steps = next;
      });
    }

    final stopwatch = Stopwatch()..start();
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 3),
      );
      socket.destroy();
      stopwatch.stop();
      await update(
        0,
        _DiagnosisStep(
          l10n.server_edit_diag_network,
          state: _StepState.ok,
          detail: '${stopwatch.elapsedMilliseconds} ms',
        ),
      );
    } catch (error) {
      await update(
        0,
        _DiagnosisStep(
          l10n.server_edit_diag_network,
          state: _StepState.failed,
          detail: l10n.server_edit_diag_failed,
        ),
      );
      if (mounted) setState(() => _diagnosing = false);
      return;
    }

    if (_isHttps) {
      try {
        final secure = await SecureSocket.connect(
          host,
          port,
          timeout: const Duration(seconds: 4),
          onBadCertificate: (_) => _allowInsecure,
        );
        secure.destroy();
        await update(
          1,
          _DiagnosisStep(
            l10n.server_edit_diag_tls,
            state: _StepState.ok,
            detail: _allowInsecure
                ? l10n.server_edit_self_signed_allowed
                : null,
          ),
        );
      } catch (error) {
        await update(
          1,
          _DiagnosisStep(
            l10n.server_edit_diag_tls,
            state: _StepState.failed,
            detail: l10n.server_edit_diag_failed,
          ),
        );
      }
    }

    DioClient? client;
    try {
      client = await createProbeClient(
        host: host,
        port: port,
        apiKey: apiKey,
        isHttps: _isHttps,
        allowInsecureConnections: _allowInsecure,
        requestTimeoutSeconds: 5,
      );
      final response = await client.get<Map<String, dynamic>>(
        '/api/v2/dashboard/base/os',
      );
      final dateHeader = response.headers.value('date');
      if (dateHeader != null) {
        final serverTime = DateTime.tryParse(dateHeader);
        if (serverTime != null) {
          final drift = DateTime.now().difference(serverTime).inSeconds.abs();
          if (drift > 60) {
            _clockDrift = l10n.server_edit_clock_drift(drift);
          }
        }
      }
      await update(
        2,
        _DiagnosisStep(l10n.server_edit_diag_auth, state: _StepState.ok),
      );
    } catch (error) {
      await update(
        2,
        _DiagnosisStep(
          l10n.server_edit_diag_auth,
          state: _StepState.failed,
          detail: l10n.server_edit_diag_failed,
        ),
      );
      client?.dispose();
      if (mounted) setState(() => _diagnosing = false);
      return;
    }

    const probes = [
      '/api/v2/dashboard/base/all/all',
      '/api/v2/websites/search',
      '/api/v2/containers/search',
      '/api/v2/databases/search',
      '/api/v2/apps/installed/search',
      '/api/v2/cronjobs/search',
      '/api/v2/hosts/firewall/base',
      '/api/v2/hosts/terminal/local',
    ];
    var supported = 0;
    for (final path in probes) {
      try {
        await client.get<Map<String, dynamic>>(path);
        supported++;
      } catch (_) {
        // 端点缺失视为能力不支持，不阻塞诊断。
      }
    }
    client.dispose();
    await update(
      3,
      _DiagnosisStep(
        l10n.server_edit_diag_capability,
        state: _StepState.ok,
        detail: '$supported / ${probes.length}',
      ),
    );

    if (mounted) setState(() => _diagnosing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    if (_loading) {
      return const Scaffold(
        body: SkeletonShimmer(
          child: Padding(
            padding: EdgeInsets.all(AppTokens.s16),
            child: Column(
              children: [
                SkeletonCard(height: 96),
                SkeletonCard(height: 120),
                SkeletonCard(height: 96),
              ],
            ),
          ),
        ),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBarLarge(
          title: widget.isEditing
              ? l10n.server_edit_edit_title
              : l10n.server_edit_add_title,
        ),
        body: ErrorState(
          data: mapError(_loadError!, l10n),
          onRetry: _loadServer,
        ),
      );
    }

    return Scaffold(
      appBar: AppBarLarge(
        title: widget.isEditing
            ? l10n.server_edit_edit_title
            : l10n.server_edit_add_title,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.pagePadding),
          children: [
            SectionHeader(title: l10n.server_edit_address),
            TonalCard(
              child: Column(
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: l10n.server_edit_name,
                    hint: l10n.server_edit_name_hint,
                  ),
                  const SizedBox(height: AppTokens.s16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.server_edit_https),
                    value: _isHttps,
                    onChanged: (value) {
                      setState(() {
                        _isHttps = value;
                        _syncDefaultPort(value);
                      });
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: AppTextField(
                          controller: _hostController,
                          label: l10n.server_edit_host,
                          hint: l10n.server_edit_host_hint,
                          keyboardType: TextInputType.url,
                          validator: _validateHost,
                        ),
                      ),
                      const SizedBox(width: AppTokens.s12),
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                          controller: _portController,
                          label: l10n.server_edit_port,
                          helper: l10n.server_edit_portHelper,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: _validatePort,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s24),
            SectionHeader(title: l10n.server_edit_api_key),
            TonalCard(
              child: Column(
                children: [
                  AppTextField(
                    controller: _apiKeyController,
                    label: l10n.server_edit_api_key,
                    hint: l10n.server_edit_api_key_hint,
                    obscure: _obscureKey,
                    validator: _validateKey,
                    suffix: IconButton(
                      tooltip: _obscureKey
                          ? l10n.common_show
                          : l10n.common_hide,
                      icon: Icon(
                        _obscureKey ? TablerIcons.eye : TablerIcons.eye_off,
                        size: AppTokens.iconList,
                      ),
                      onPressed: () =>
                          setState(() => _obscureKey = !_obscureKey),
                    ),
                  ),
                  const SizedBox(height: AppTokens.s8),
                  Row(
                    children: [
                      Icon(
                        TablerIcons.info_circle,
                        size: AppTokens.iconList,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppTokens.s8),
                      Expanded(
                        child: Text(
                          l10n.server_edit_key_guide,
                          style: AppTextStyles.bodyS.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l10n.server_edit_allow_insecure,
                      style: AppTextStyles.bodyM,
                    ),
                    subtitle: Text(
                      l10n.server_edit_allow_insecure_hint,
                      style: AppTextStyles.bodyS.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    value: _allowInsecure,
                    onChanged: (value) =>
                        setState(() => _allowInsecure = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s24),
            SectionHeader(title: l10n.server_edit_test),
            TonalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final step in _steps) ...[
                    _DiagnosisRow(step: step),
                    if (step != _steps.last)
                      const SizedBox(height: AppTokens.s12),
                  ],
                  if (_clockDrift != null) ...[
                    const SizedBox(height: AppTokens.s12),
                    Row(
                      children: [
                        Icon(
                          TablerIcons.clock_exclamation,
                          size: AppTokens.iconList,
                          color: context.appColors.warning,
                        ),
                        const SizedBox(width: AppTokens.s8),
                        Expanded(
                          child: Text(
                            _clockDrift!,
                            style: AppTextStyles.bodyS.copyWith(
                              color: context.appColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppTokens.s16),
                  SecondaryButton(
                    label: l10n.server_edit_test,
                    icon: TablerIcons.plug_connected,
                    loading: _diagnosing,
                    onPressed: _diagnosing ? null : _runDiagnosis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s24),
            PrimaryButton(
              label: l10n.server_edit_save,
              icon: TablerIcons.device_floppy,
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
            const SizedBox(height: AppTokens.s32),
          ],
        ),
      ),
    );
  }
}

class _DiagnosisRow extends StatelessWidget {
  const _DiagnosisRow({required this.step});

  final _DiagnosisStep step;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.appColors;
    final (icon, color) = switch (step.state) {
      _StepState.idle => (TablerIcons.circle, scheme.onSurfaceVariant),
      _StepState.running => (TablerIcons.loader, scheme.primary),
      _StepState.ok => (TablerIcons.circle_check, colors.success),
      _StepState.failed => (TablerIcons.circle_x, colors.danger),
      _StepState.skipped => (TablerIcons.minus, scheme.onSurfaceVariant),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        step.state == _StepState.running
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Icon(icon, size: 18, color: color),
        const SizedBox(width: AppTokens.s8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(step.title, style: AppTextStyles.bodyM),
              if (step.detail != null)
                Text(
                  step.detail!,
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
}
