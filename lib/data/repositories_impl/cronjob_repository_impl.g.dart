// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cronjob_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cronjobRepositoryHash() => r'913749b7727c178617b1b455023511125f37b87f';

/// 基于当前激活服务器的仓库 Provider。
///
/// Copied from [cronjobRepository].
@ProviderFor(cronjobRepository)
final cronjobRepositoryProvider =
    AutoDisposeFutureProvider<CronjobRepository>.internal(
      cronjobRepository,
      name: r'cronjobRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cronjobRepositoryHash,
      dependencies: <ProviderOrFamily>[activeServerIdProvider],
      allTransitiveDependencies: <ProviderOrFamily>{
        activeServerIdProvider,
        ...?activeServerIdProvider.allTransitiveDependencies,
      },
    );

typedef CronjobRepositoryRef = AutoDisposeFutureProviderRef<CronjobRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
