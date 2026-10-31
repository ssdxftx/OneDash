import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/states/error_mapper.dart';
import 'package:onedash/presentation/common/states/error_state.dart';

Widget _wrap(Widget child, {double scale = 1}) {
  return MaterialApp(
    theme: AppTheme.build(Brightness.light),
    locale: const Locale('zh'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    builder: (context, appChild) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: appChild!,
    ),
    home: Scaffold(body: child),
  );
}

const _data = ErrorViewData(
  icon: TablerIcons.cloud_off,
  title: '连接失败',
  message: '请检查网络后重试',
  kind: ErrorKind.network,
);

void main() {
  testWidgets('ErrorState renders retry action in a horizontal layout', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(ErrorState(data: _data, onRetry: () {})));

    expect(find.text('重试'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ErrorState renders both actions without constraints overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ErrorState(
          data: _data.copyWithSecondary('编辑服务器'),
          onSecondaryAction: () {},
          onRetry: () {},
        ),
        scale: 1.5,
      ),
    );

    expect(find.text('编辑服务器'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

extension on ErrorViewData {
  ErrorViewData copyWithSecondary(String label) => ErrorViewData(
    icon: icon,
    title: title,
    message: message,
    detail: detail,
    actionLabel: actionLabel,
    secondaryActionLabel: label,
    kind: kind,
  );
}
