import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import 'buttons.dart';
import 'split_list_group.dart';

class BottomSheetSurface extends StatelessWidget {
  const BottomSheetSurface({
    super.key,
    required this.child,
    this.showHandle = true,
    this.padding = const EdgeInsets.fromLTRB(
      AppTokens.s20,
      AppTokens.s8,
      AppTokens.s20,
      AppTokens.s20,
    ),
    this.maxHeightFactor = 0.92,
  });

  final Widget child;
  final bool showHandle;
  final EdgeInsetsGeometry padding;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final maxHeight = MediaQuery.sizeOf(context).height * maxHeightFactor;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTokens.rSheet),
        ),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.06)
                : scheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) ...[
            const SizedBox(height: AppTokens.s8),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppTokens.rFull),
              ),
            ),
            const SizedBox(height: AppTokens.s8),
          ],
          Flexible(
            child: SingleChildScrollView(
              padding: padding,
              child: Material(
                type: MaterialType.transparency,
                child: SafeArea(top: false, child: child),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetSpringCurve extends Curve {
  const _SheetSpringCurve();

  static const double _seconds = 0.45;

  @override
  double transformInternal(double t) {
    final simulation = SpringSimulation(AppTokens.sheetSpring, 0, 1, 0);
    final end = simulation.x(_seconds);
    return simulation.x(t * _seconds) / end;
  }
}

Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  double maxHeightFactor = 0.92,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    sheetAnimationStyle: context.reduceMotion
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            curve: _SheetSpringCurve(),
            reverseCurve: Curves.easeInCubic,
            duration: AppTokens.dPage,
            reverseDuration: AppTokens.dFast,
          ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: BottomSheetSurface(
          maxHeightFactor: maxHeightFactor,
          child: builder(context),
        ),
      );
    },
  );
}

/// One option in a selection menu.
class SelectionOption<T> {
  const SelectionOption({
    required this.label,
    required this.value,
    this.icon,
    this.subtitle,
    this.danger = false,
    this.enabled = true,
  });

  final String label;
  final T value;
  final IconData? icon;
  final String? subtitle;
  final bool danger;
  final bool enabled;
}

/// Bottom selection menu for a fixed list of options.
Future<T?> showSelectionMenu<T>(
  BuildContext context, {
  required List<SelectionOption<T>> options,
  String? title,
  String? subtitle,
  double maxHeightFactor = 0.9,
}) {
  return showAppSheet<T>(
    context: context,
    maxHeightFactor: maxHeightFactor,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title, style: AppTextStyles.titleL),
          if (subtitle != null) ...[
            const SizedBox(height: AppTokens.s4),
            Text(
              subtitle,
              style: AppTextStyles.bodyS.copyWith(
                color: sheetContext.scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppTokens.s16),
        ],
        SplitListGroup(
          children: [
            for (final option in options)
              SplitListTile(
                leading: Icon(option.icon ?? Icons.chevron_right),
                title: option.label,
                subtitle: option.subtitle,
                danger: option.danger,
                enabled: option.enabled,
                onTap: option.enabled
                    ? () => Navigator.of(sheetContext).pop(option.value)
                    : null,
              ),
          ],
        ),
      ],
    ),
  );
}

/// 危险操作确认。传入 [requireText] 时必须精确输入资源名才可提交。
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  String? requireText,
  bool danger = true,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.rLg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.s24),
          child: _ConfirmSheetBody(
            title: title,
            message: message,
            confirmLabel: confirmLabel ?? l10n.action_confirm,
            cancelLabel: cancelLabel ?? l10n.action_cancel,
            requireText: requireText,
            danger: danger,
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}

class _ConfirmSheetBody extends StatefulWidget {
  const _ConfirmSheetBody({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    this.requireText,
    this.danger = true,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final String? requireText;
  final bool danger;

  @override
  State<_ConfirmSheetBody> createState() => _ConfirmSheetBodyState();
}

class _ConfirmSheetBodyState extends State<_ConfirmSheetBody> {
  final _controller = TextEditingController();

  bool get _canConfirm =>
      widget.requireText == null ||
      _controller.text.trim() == widget.requireText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.title, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s8),
        Text(
          widget.message,
          style: AppTextStyles.bodyM.copyWith(color: scheme.onSurfaceVariant),
        ),
        if (widget.requireText != null) ...[
          const SizedBox(height: AppTokens.s16),
          Text(
            AppLocalizations.of(
              context,
            ).common_typeToContinue(widget.requireText!),
            style: AppTextStyles.bodyS.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppTokens.s8),
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            autofocus: true,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).common_resourceName,
            ),
          ),
        ],
        const SizedBox(height: AppTokens.s24),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: widget.cancelLabel,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: widget.danger
                  ? DangerButton(
                      label: widget.confirmLabel,
                      onPressed: _canConfirm
                          ? () => Navigator.of(context).pop(true)
                          : null,
                    )
                  : PrimaryButton(
                      label: widget.confirmLabel,
                      onPressed: _canConfirm
                          ? () => Navigator.of(context).pop(true)
                          : null,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
