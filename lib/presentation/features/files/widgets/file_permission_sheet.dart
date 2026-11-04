import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/file/file_item_dto.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/states/error_toast.dart';

Future<bool> showFilePermissionSheet(
  BuildContext context, {
  required FileItemDto item,
}) async {
  final updated = await pushFormPage<bool>(
    context,
    _FilePermissionSheet(item: item),
  );
  return updated ?? false;
}

class _FilePermissionSheet extends ConsumerStatefulWidget {
  const _FilePermissionSheet({required this.item});

  final FileItemDto item;

  @override
  ConsumerState<_FilePermissionSheet> createState() =>
      _FilePermissionSheetState();
}

class _FilePermissionSheetState extends ConsumerState<_FilePermissionSheet> {
  late final TextEditingController _mode;
  late final TextEditingController _user;
  late final TextEditingController _group;
  final List<List<bool>> _bits = [
    [false, false, false],
    [false, false, false],
    [false, false, false],
  ];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final mode = _normalizeMode(widget.item.mode);
    _mode = TextEditingController(text: mode);
    _user = TextEditingController(text: widget.item.user);
    _group = TextEditingController(text: widget.item.group);
    _applyMode(mode);
  }

  @override
  void dispose() {
    _mode.dispose();
    _user.dispose();
    _group.dispose();
    super.dispose();
  }

  String _normalizeMode(String raw) {
    if (RegExp(r'^[0-7]{3,4}$').hasMatch(raw)) {
      return raw.padLeft(4, '0');
    }
    if (raw.length >= 10) {
      final chars = raw.substring(1, 10);
      final buffer = StringBuffer('0');
      for (var group = 0; group < 3; group++) {
        var value = 0;
        if (chars[group * 3] == 'r') value += 4;
        if (chars[group * 3 + 1] == 'w') value += 2;
        if (chars[group * 3 + 2] == 'x') value += 1;
        buffer.write(value);
      }
      return buffer.toString();
    }
    return '0644';
  }

  void _applyMode(String value) {
    if (value.length < 4) return;
    for (var group = 0; group < 3; group++) {
      final digit = int.tryParse(value[group + 1]) ?? 0;
      _bits[group][0] = digit & 4 != 0;
      _bits[group][1] = digit & 2 != 0;
      _bits[group][2] = digit & 1 != 0;
    }
  }

  String _composeMode() {
    final buffer = StringBuffer('0');
    for (final group in _bits) {
      var value = 0;
      if (group[0]) value += 4;
      if (group[1]) value += 2;
      if (group[2]) value += 1;
      buffer.write(value);
    }
    return buffer.toString();
  }

  void _toggle(int group, int bit) {
    setState(() {
      _bits[group][bit] = !_bits[group][bit];
      _mode.text = _composeMode();
    });
  }

  Future<void> _pickOwner() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final data = await repository.getUserGroups();
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.files_pickOwner, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s8),
            for (final user in data.users)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(TablerIcons.user),
                title: Text(user.username),
                subtitle: Text(user.group),
                onTap: () {
                  _user.text = user.username;
                  _group.text = user.group;
                  Navigator.of(sheetContext).pop();
                },
              ),
            for (final group in data.groups)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(TablerIcons.users_group),
                title: Text(group),
                onTap: () {
                  _group.text = group;
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _save() async {
    final modeText = _mode.text.trim();
    if (!RegExp(r'^[0-7]{3,4}$').hasMatch(modeText)) return;
    final mode = int.parse(modeText.padLeft(4, '0'), radix: 8);
    setState(() => _saving = true);
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      await repository.changeMode(path: widget.item.path, mode: mode);
      final user = _user.text.trim();
      final group = _group.text.trim();
      if (user.isNotEmpty && group.isNotEmpty) {
        await repository.changeOwner(
          path: widget.item.path,
          user: user,
          group: group,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SimpleFormPage(
      title: l10n.files_permission,
      subtitle: widget.item.name,
      saving: _saving,
      onSave: _save,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _pickOwner,
            icon: const Icon(TablerIcons.users, size: 18),
            label: Text(l10n.files_pickOwner),
          ),
        ),
        for (var group = 0; group < 3; group++) ...[
          Text(
            group == 0
                ? l10n.files_permissionOwner
                : group == 1
                ? l10n.files_permissionGroup
                : l10n.files_permissionPublic,
            style: AppTextStyles.bodyM,
          ),
          Row(
            children: [
              for (var bit = 0; bit < 3; bit++)
                Expanded(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(switch (bit) {
                      0 => l10n.files_permissionRead,
                      1 => l10n.files_permissionWrite,
                      _ => l10n.files_permissionExecute,
                    }),
                    value: _bits[group][bit],
                    onChanged: (_) => _toggle(group, bit),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppTokens.s8),
        AppTextField(
          controller: _mode,
          label: l10n.files_permissionMode,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-7]')),
            LengthLimitingTextInputFormatter(4),
          ],
          onChanged: (value) {
            if (value.length < 3) return;
            setState(() => _applyMode(value.padLeft(4, '0')));
          },
        ),
        const SizedBox(height: AppTokens.s20),
        AppTextField(controller: _user, label: l10n.files_permissionUser),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: _group, label: l10n.files_permissionGroupName),
      ],
    );
  }
}
