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
