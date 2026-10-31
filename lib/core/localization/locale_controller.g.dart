// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appLocalizationsHash() => r'76a4661fe10af901b3ad460ee991d8bed2446494';

/// See also [appLocalizations].
@ProviderFor(appLocalizations)
final appLocalizationsProvider = Provider<AppLocalizations>.internal(
  appLocalizations,
  name: r'appLocalizationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appLocalizationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppLocalizationsRef = ProviderRef<AppLocalizations>;
String _$localeControllerHash() => r'6f383d145edb0004b2215c2c1c9cd5c4a60970e5';

/// See also [LocaleController].
@ProviderFor(LocaleController)
final localeControllerProvider =
    NotifierProvider<LocaleController, AppLocaleOption>.internal(
      LocaleController.new,
      name: r'localeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocaleController = Notifier<AppLocaleOption>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
