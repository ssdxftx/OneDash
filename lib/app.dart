import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import 'core/localization/generated/app_localizations.dart';
import 'core/localization/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

class OneDashApp extends ConsumerWidget {
  const OneDashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);
    final localeOption = ref.watch(localeControllerProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return ToastificationWrapper(
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) =>
                AppLocalizations.of(context).app_title,
            title: 'OneDash',
            theme: AppTheme.build(
              Brightness.light,
              dynamicScheme: theme.dynamicColor ? lightDynamic : null,
              seedColor: seedOf(theme),
            ),
            darkTheme: AppTheme.build(
              Brightness.dark,
              dynamicScheme: theme.dynamicColor ? darkDynamic : null,
              seedColor: seedOf(theme),
              oled: theme.oled,
            ),
            themeMode: theme.mode.themeMode,
            routerConfig: appRouter,
            locale: localeOption.toLocale(),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            builder: (context, child) {
              final systemScale = MediaQuery.textScalerOf(context).scale(1);
              final scale = (systemScale * theme.textScale).clamp(0.85, 1.5);
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child ?? const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}
