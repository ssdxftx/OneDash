import 'package:flutter/widgets.dart';

import '../../../core/localization/generated/app_localizations.dart';

String displayValue(BuildContext context, String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return AppLocalizations.of(context).common_notAvailable;
  }
  return text;
}
