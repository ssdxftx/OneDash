import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import 'app_bar_large.dart';
import 'buttons.dart';
import 'form_footer.dart';

/// Fullscreen form template: large app bar, scrollable fields and a fixed
/// footer holding the primary action.
class SimpleFormPage extends StatelessWidget {
  const SimpleFormPage({
    super.key,
    required this.title,
    required this.children,
    required this.onSave,
    this.subtitle,
    this.saveLabel,
    this.saving = false,
    this.formKey,
    this.actions,
    this.leading,
    this.danger = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Future<void> Function() onSave;
  final String? saveLabel;
  final bool saving;
  final GlobalKey<FormState>? formKey;
  final List<Widget>? actions;
  final Widget? leading;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: title,
        subtitle: subtitle,
        actions: actions,
        leading: leading,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            context.pagePadding,
            AppTokens.s8,
            context.pagePadding,
            AppTokens.s32,
          ),
          children: [
            ...children,
            const SizedBox(height: AppTokens.s32),
          ],
        ),
      ),
      bottomNavigationBar: FormFooter(
        child: danger
            ? DangerButton(
                label: saveLabel ?? l10n.action_save,
                loading: saving,
                onPressed: saving ? null : onSave,
              )
            : PrimaryButton(
                label: saveLabel ?? l10n.action_save,
                icon: TablerIcons.check,
                loading: saving,
                onPressed: saving ? null : onSave,
              ),
      ),
    );
  }
}

/// Pushes [page] on the root navigator with the shared slide transition and
/// returns its result.
Future<T?> pushFormPage<T>(BuildContext context, Widget page) {
  return Navigator.of(
    context,
    rootNavigator: true,
  ).push<T>(MaterialPageRoute<T>(builder: (_) => page));
}

/// Sheet-shaped form used as a second layer above an action sheet.
class FormSheet extends StatelessWidget {
  const FormSheet({
    super.key,
    required this.title,
    required this.children,
    required this.onSave,
    this.subtitle,
    this.saveLabel,
    this.saving = false,
    this.formKey,
    this.actions,
    this.footer,
    this.danger = false,
  });

  final String title;
  final List<Widget> children;
  final Future<void> Function() onSave;
  final String? subtitle;
  final String? saveLabel;
  final bool saving;
  final GlobalKey<FormState>? formKey;
  final List<Widget>? actions;
  final Widget? footer;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppTokens.s20, 0, AppTokens.s8, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleM,
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: context.scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (actions != null) ...actions!,
              IconButton(
                tooltip: l10n.action_close,
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(TablerIcons.x),
              ),
            ],
          ),
        ),
        Expanded(
          child: Form(
            key: formKey,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s20,
                AppTokens.s8,
                AppTokens.s20,
                AppTokens.s24,
              ),
            ),
          ),
        ),
        FormFooter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (footer != null) ...[
                footer!,
                const SizedBox(height: AppTokens.s8),
              ],
              danger
                  ? DangerButton(
                      label: saveLabel ?? l10n.action_save,
                      loading: saving,
                      onPressed: saving ? null : onSave,
                    )
                  : PrimaryButton(
                      label: saveLabel ?? l10n.action_save,
                      icon: TablerIcons.check,
                      loading: saving,
                      onPressed: saving ? null : onSave,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<T?> showFormSheet<T>(
  BuildContext context, {
  required String title,
  required List<Widget> children,
  required Future<void> Function() onSave,
  String? subtitle,
  String? saveLabel,
  bool saving = false,
  GlobalKey<FormState>? formKey,
  List<Widget>? actions,
  Widget? footer,
  bool danger = false,
  double maxHeightFactor = 0.74,
  Color? barrierColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.18),
    builder: (ctx) {
      final media = MediaQuery.of(ctx);
      final height = (media.size.height * maxHeightFactor).clamp(
        240.0,
        media.size.height - media.viewInsets.bottom - 48,
      );
      return Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: ctx.scheme.surfaceContainer,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTokens.rSheet),
            ),
          ),
          child: SafeArea(
            top: false,
            child: FormSheet(
              title: title,
              onSave: onSave,
              subtitle: subtitle,
              saveLabel: saveLabel,
              saving: saving,
              formKey: formKey,
              actions: actions,
              footer: footer,
              danger: danger,
              children: children,
            ),
          ),
        ),
      );
    },
  );
}
