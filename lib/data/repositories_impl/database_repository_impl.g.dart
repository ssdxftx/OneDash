// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseRepositoryHash() =>
    r'6693c5b033942926b80d8aeff5c1dcf9a9cd45a3';

/// 基于当前激活服务器的仓库 Provider。
///
/// Copied from [databaseRepository].
@ProviderFor(databaseRepository)
final databaseRepositoryProvider =
    AutoDisposeFutureProvider<DatabaseRepository>.internal(
      databaseRepository,
      name: r'databaseRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$databaseRepositoryHash,
      dependencies: <ProviderOrFamily>[activeServerIdProvider],
      allTransitiveDependencies: <ProviderOrFamily>{
        activeServerIdProvider,
        ...?activeServerIdProvider.allTransitiveDependencies,
      },
    );

typedef DatabaseRepositoryRef =
    AutoDisposeFutureProviderRef<DatabaseRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
