// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$logRepositoryHash() => r'51bb916a337c9a0da76923221fb255cb9f92f4e4';

/// 基于当前激活服务器的日志仓库 Provider。
///
/// Copied from [logRepository].
@ProviderFor(logRepository)
final logRepositoryProvider = AutoDisposeFutureProvider<LogRepository>.internal(
  logRepository,
  name: r'logRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$logRepositoryHash,
  dependencies: <ProviderOrFamily>[activeServerIdProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    activeServerIdProvider,
    ...?activeServerIdProvider.allTransitiveDependencies,
  },
);

typedef LogRepositoryRef = AutoDisposeFutureProviderRef<LogRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
