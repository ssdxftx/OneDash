import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class AppTheme {
  static ColorScheme schemeFor(
    Brightness brightness, {
    ColorScheme? dynamicScheme,
    Color seedColor = AppTokens.seed,
    DynamicSchemeVariant schemeVariant = DynamicSchemeVariant.tonalSpot,
    bool oled = false,
  }) {
    final base =
        dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: brightness,
          dynamicSchemeVariant: schemeVariant,
        );

    if (brightness == Brightness.light) {
      return base;
    }

    if (oled) {
      return base.copyWith(
        surface: Colors.black,
        surfaceContainerLowest: Colors.black,
        surfaceContainerLow: const Color(0xFF0A0A0A),
        surfaceContainer: const Color(0xFF0D0D0D),
        surfaceContainerHigh: const Color(0xFF121212),
        surfaceContainerHighest: const Color(0xFF171717),
      );
    }

    return base.copyWith(
      surface: const Color(0xFF101512),
      surfaceContainerLowest: const Color(0xFF0B0F0C),
      surfaceContainerLow: const Color(0xFF151B17),
      surfaceContainer: const Color(0xFF19211C),
      surfaceContainerHigh: const Color(0xFF1F2923),
      surfaceContainerHighest: const Color(0xFF26312A),
    );
  }

  static ThemeData build(
    Brightness brightness, {
    ColorScheme? dynamicScheme,
    Color seedColor = AppTokens.seed,
    DynamicSchemeVariant schemeVariant = DynamicSchemeVariant.tonalSpot,
    bool oled = false,
  }) {
    final scheme = schemeFor(
      brightness,
      dynamicScheme: dynamicScheme,
      seedColor: seedColor,
      oled: oled,
    );
    final semantic = brightness == Brightness.dark
        ? OneDashColors.dark
        : OneDashColors.light;
    final textTheme = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'MiSans',
      fontFamilyFallback: const ['Roboto'],
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[semantic],
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTextStyles.caption.copyWith(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: AppTokens.iconNav,
            color: selected
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: scheme.surfaceContainer,
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTokens.rSheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rXl),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.s16,
          vertical: AppTokens.s12,
        ),
        hintStyle: AppTextStyles.bodyM.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontWeight: FontWeight.w400,
        ),
        labelStyle: AppTextStyles.bodyM.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rSm),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rSm),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rSm),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rSm),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rSm),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppTokens.buttonHeight),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppTokens.buttonHeight),
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: AppTextStyles.label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppTokens.minTapTarget,
            AppTokens.minTapTarget,
          ),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.label,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: AppTextStyles.label,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: AppTextStyles.bodyM.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rMd),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        minVerticalPadding: AppTokens.s12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rSm),
        ),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    TextStyle colored(TextStyle style, Color color) =>
        style.copyWith(color: color);

    return TextTheme(
      displayLarge: colored(AppTextStyles.display, scheme.onSurface),
      displayMedium: colored(
        AppTextStyles.display.copyWith(fontSize: 30, height: 1.2),
        scheme.onSurface,
      ),
      displaySmall: colored(
        AppTextStyles.display.copyWith(fontSize: 28, height: 1.22),
        scheme.onSurface,
      ),
      headlineLarge: colored(
        AppTextStyles.headline.copyWith(fontSize: 26),
        scheme.onSurface,
      ),
      headlineMedium: colored(AppTextStyles.headline, scheme.onSurface),
      headlineSmall: colored(
        AppTextStyles.titleL.copyWith(fontSize: 22),
        scheme.onSurface,
      ),
      titleLarge: colored(AppTextStyles.titleL, scheme.onSurface),
      titleMedium: colored(AppTextStyles.titleM, scheme.onSurface),
      titleSmall: colored(AppTextStyles.titleS, scheme.onSurface),
      bodyLarge: colored(AppTextStyles.bodyL, scheme.onSurface),
      bodyMedium: colored(AppTextStyles.bodyM, scheme.onSurface),
      bodySmall: colored(AppTextStyles.bodyS, scheme.onSurfaceVariant),
      labelLarge: colored(AppTextStyles.label, scheme.onSurface),
      labelMedium: colored(AppTextStyles.bodyS, scheme.onSurfaceVariant),
      labelSmall: colored(AppTextStyles.caption, scheme.onSurfaceVariant),
    );
  }
}
