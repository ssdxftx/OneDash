import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/container/container_compose_dto.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/task_progress_sheet.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/error_toast.dart';

class ComposeFormPage extends ConsumerStatefulWidget {
  const ComposeFormPage({super.key, required this.serverId, this.compose});

  final int serverId;
  final ContainerComposeDto? compose;

  bool get isEditing => compose != null;

  @override
  ConsumerState<ComposeFormPage> createState() => _ComposeFormPageState();
}

class _ComposeFormPageState extends ConsumerState<ComposeFormPage> {
  late final TextEditingController _name = TextEditingController(
    text: widget.compose?.name ?? '',
  );
  final _content = TextEditingController();
  final _env = TextEditingController();
  bool _forcePull = false;
  bool _loading = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _env.text = widget.compose?.env ?? '';
    if (widget.isEditing) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final compose = widget.compose!;
      final content = await repository.inspect(
        id: compose.name,
        type: 'compose',
        detail: compose.configFile,
      );
      if (!mounted) return;
      setState(() {
        _content.text = content;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      showErrorToast(context, error);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _content.dispose();
    _env.dispose();
    super.dispose();
  }

  Map<String, dynamic> _payload(String taskID) {
    if (widget.isEditing) {
      final compose = widget.compose!;
      return {
        'taskID': taskID,
        'name': compose.name,
        'path': compose.path,
        'detailPath': compose.configFile,
        'content': _content.text,
        'env': _env.text,
        'forcePull': _forcePull,
      };
    }
    return {
      'taskID': taskID,
      'name': _name.text.trim(),
      'dirName': _name.text.trim(),
      'from': 'edit',
      'file': _content.text,
      'env': _env.text,
      'forcePull': _forcePull,
    };
  }

  Future<void> _test() async {
    final l10n = AppLocalizations.of(context);
    if (_content.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final valid = await repository.testCompose(_payload(const Uuid().v4()));
      if (!mounted) return;
      if (valid) {
        AppToast.success(context, l10n.containers_composeValid);
      } else {
        AppToast.warning(context, l10n.containers_composeInvalid);
      }
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_content.text.trim().isEmpty) {
      AppToast.warning(context, l10n.containers_composeContentRequired);
      return;
    }
    if (!widget.isEditing && _name.text.trim().isEmpty) {
      AppToast.warning(context, l10n.containers_nameRequired);
      return;
    }
    setState(() => _submitting = true);
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final taskID = const Uuid().v4();
      final payload = _payload(taskID);
      setState(() => _submitting = false);
      if (!mounted) return;
      final success = await TaskProgressSheet.run(
        context,
        title: widget.isEditing
            ? l10n.containers_updateCompose
            : l10n.containers_createCompose,
        task: (controller) async {
          if (widget.isEditing) {
            await repository.updateCompose(payload);
          } else {
            await repository.createCompose(payload);
          }
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
    return Scaffold(
      appBar: AppBarLarge(
        title: widget.isEditing
            ? l10n.containers_updateCompose
            : l10n.containers_createCompose,
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
          SectionHeader(title: l10n.containers_compose),
          TonalCard(
            child: Column(
              children: [
                AppTextField(
                  controller: _name,
                  label: l10n.containers_name,
                  enabled: !widget.isEditing,
                ),
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: _env,
                  label: l10n.containers_env,
                  hint: 'KEY=VALUE',
                  maxLines: 3,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.containers_forcePull),
                  value: _forcePull,
                  onChanged: (value) => setState(() => _forcePull = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s24),
          const SectionHeader(title: 'docker-compose.yml'),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(AppTokens.s24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            TonalCard(
              child: AppTextField(
                controller: _content,
                hint: 'services:\n  web:\n    image: nginx:alpine',
                maxLines: 18,
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
                  : l10n.containers_createCompose,
              loading: _submitting,
              onPressed: _submitting ? null : _submit,
            ),
            if (!_loading) ...[
              const SizedBox(height: AppTokens.s8),
              SecondaryButton(
                label: l10n.containers_testCompose,
                onPressed: _submitting ? null : _test,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
