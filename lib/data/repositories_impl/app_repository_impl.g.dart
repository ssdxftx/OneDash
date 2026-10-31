// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appRepositoryHash() => r'1d4904e446ccda99afa8e07bc534734f9d2d88e3';

/// 基于当前激活服务器的仓库 Provider。
///
/// Copied from [appRepository].
@ProviderFor(appRepository)
final appRepositoryProvider = AutoDisposeFutureProvider<AppRepository>.internal(
  appRepository,
  name: r'appRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appRepositoryHash,
  dependencies: <ProviderOrFamily>[activeServerIdProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    activeServerIdProvider,
    ...?activeServerIdProvider.allTransitiveDependencies,
  },
);

typedef AppRepositoryRef = AutoDisposeFutureProviderRef<AppRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
