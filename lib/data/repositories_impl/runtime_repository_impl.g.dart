// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'runtime_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$runtimeRepositoryHash() => r'a4b10de4016b4121bc4bf8631f1600ccbf305d77';

/// 基于当前激活服务器的仓库 Provider。
///
/// Copied from [runtimeRepository].
@ProviderFor(runtimeRepository)
final runtimeRepositoryProvider =
    AutoDisposeFutureProvider<RuntimeRepository>.internal(
      runtimeRepository,
      name: r'runtimeRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$runtimeRepositoryHash,
      dependencies: <ProviderOrFamily>[activeServerIdProvider],
      allTransitiveDependencies: <ProviderOrFamily>{
        activeServerIdProvider,
        ...?activeServerIdProvider.allTransitiveDependencies,
      },
    );

typedef RuntimeRepositoryRef = AutoDisposeFutureProviderRef<RuntimeRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
