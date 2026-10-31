import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_editor/re_editor.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';
import '../../../common/components/app_toast.dart';

class FileEditorPage extends ConsumerStatefulWidget {
  const FileEditorPage({super.key, required this.serverId, required this.path});

  final int serverId;
  final String path;

  @override
  ConsumerState<FileEditorPage> createState() => _FileEditorPageState();
}

class _FileEditorPageState extends ConsumerState<FileEditorPage> {
  final _focusNode = FocusNode();
  CodeLineEditingController? _controller;
  bool _loading = true;
  bool _saving = false;
  bool _dirty = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final file = await repository.getFileContent(
        path: widget.path,
        isDetail: true,
      );
      if (!mounted) return;
      _controller = CodeLineEditingController.fromText(file.content)
        ..addListener(_onChanged);
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  void _onChanged() {
    if (!_dirty) setState(() => _dirty = true);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onChanged);
    _controller?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _saving = true);
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      await repository.saveFileContent(
        path: widget.path,
        content: controller.text,
      );
      if (!mounted) return;
      setState(() {
        _dirty = false;
        _saving = false;
      });
      AppToast.success(context, AppLocalizations.of(context).action_save);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error(context, '$error');
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.action_close),
        content: Text(l10n.file_editor_unsavedLeave),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.action_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.action_close),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmDiscard()) {
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.path.split('/').last, style: AppTextStyles.titleM),
          actions: [
            TextButton(
              onPressed: _dirty && !_saving ? _save : null,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.action_save),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTokens.s24),
                  child: Text(_error!, textAlign: TextAlign.center),
                ),
              )
            : CodeEditor(
                controller: _controller!,
                focusNode: _focusNode,
                autofocus: false,
                style: CodeEditorStyle(
                  fontSize: 14,
                  fontFamilyFallback: const ['monospace'],
                  textColor: scheme.onSurface,
                  cursorColor: scheme.primary,
                  selectionColor: scheme.primary.withValues(alpha: 0.22),
                ),
              ),
      ),
    );
  }
}
