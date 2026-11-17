import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/setting/panel_menu_dto.dart';
import '../../../../data/repositories_impl/setting_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/formatters/enum_labels.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

class PanelMenuPage extends ConsumerStatefulWidget {
  const PanelMenuPage({super.key});

  @override
  ConsumerState<PanelMenuPage> createState() => _PanelMenuPageState();
}

class _PanelMenuPageState extends ConsumerState<PanelMenuPage> {
  List<PanelMenuNode>? _nodes;
  Object? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _nodes = null;
    });
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      final settings = await repository.searchCoreSettings();
      final raw = _lookup(settings, 'HideMenu');
      if (!mounted) return;
      setState(() {
        _nodes = PanelMenuNode.listFromJsonString(raw?.toString() ?? '');
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  Object? _lookup(Map<String, dynamic> source, String key) {
    for (final entry in source.entries) {
      if (entry.key.toLowerCase() == key.toLowerCase()) return entry.value;
    }
    return null;
  }

  void _toggle(String id, bool value) {
    final nodes = _nodes;
    if (nodes == null) return;
    final updated = List<PanelMenuNode>.from(nodes);
    if (!_applyToggle(updated, id, value)) return;
    setState(() => _nodes = updated);
  }

  bool _applyToggle(List<PanelMenuNode> nodes, String id, bool value) {
    for (var index = 0; index < nodes.length; index++) {
      final node = nodes[index];
      if (node.id == id) {
        if (node.disabled) return false;
        nodes[index] = _setSubtree(node, value);
        return true;
      }
      final children = List<PanelMenuNode>.from(node.children);
      if (_applyToggle(children, id, value)) {
        nodes[index] = node.copyWith(
          children: children,
          isShow: children.any((child) => child.isShow),
        );
        return true;
      }
    }
    return false;
  }

  PanelMenuNode _setSubtree(PanelMenuNode node, bool value) {
    return node.copyWith(
      isShow: value,
      children: node.children
          .map((child) => child.disabled ? child : _setSubtree(child, value))
          .toList(growable: false),
    );
  }

  Future<void> _save() async {
    final nodes = _nodes;
    if (nodes == null || _saving) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.panelSettings_menuSettings,
      message: l10n.panelSettings_menuSaveConfirm,
      confirmLabel: l10n.action_save,
    );
    if (!confirmed || !mounted) return;
    setState(() => _saving = true);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.updateMenuSetting(PanelMenuNode.encodeList(nodes));
      if (!mounted) return;
      AppToast.success(context, l10n.panelSettings_menuUpdated);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _reset() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.panelSettings_resetMenu,
      message: l10n.panelSettings_resetMenuConfirm,
      confirmLabel: l10n.action_confirm,
    );
    if (!confirmed || !mounted) return;
    setState(() => _saving = true);
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.resetMenuSetting();
      await _load();
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nodes = _nodes;
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.panelSettings_menuSettings,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _saving ? null : _load,
          ),
          AppIconButton(
            icon: TablerIcons.restore,
            tooltip: l10n.panelSettings_resetMenu,
            onPressed: _saving ? null : _reset,
          ),
          AppIconButton(
            icon: TablerIcons.check,
            tooltip: l10n.action_save,
            onPressed: nodes == null || _saving ? null : _save,
          ),
        ],
      ),
      body: _buildBody(context, l10n, nodes),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    List<PanelMenuNode>? nodes,
  ) {
    if (_error != null) {
      return EmptyState(
        icon: TablerIcons.alert_triangle,
        title: l10n.error_unknown_title,
        message: l10n.error_unknown_message,
        actionLabel: l10n.common_retry,
        onAction: _load,
      );
    }
    if (nodes == null) {
      return const SkeletonList(itemCount: 8);
    }
    if (nodes.isEmpty) {
      return EmptyState(
        icon: TablerIcons.menu_2,
        title: l10n.panelSettings_menuEmpty,
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(context.pagePadding),
      itemCount: nodes.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
      itemBuilder: (context, index) =>
          _MenuCard(node: nodes[index], onToggle: _toggle),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.node, required this.onToggle});

  final PanelMenuNode node;
  final void Function(String id, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    return TonalCard(
      child: Column(
        children: [
          _MenuRow(node: node, onToggle: onToggle),
          for (final child in node.children)
            Padding(
              padding: const EdgeInsets.only(left: AppTokens.s16),
              child: _MenuRow(node: child, onToggle: onToggle),
            ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.node, required this.onToggle});

  final PanelMenuNode node;
  final void Function(String id, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    final title = panelMenuLabel(
      node.title,
      node.label,
      AppLocalizations.of(context),
    );
    return SwitchListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s12,
        vertical: AppTokens.s4,
      ),
      title: Text(
        title.isEmpty ? node.id : title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      value: node.isShow,
      onChanged: node.disabled ? null : (value) => onToggle(node.id, value),
    );
  }
}
