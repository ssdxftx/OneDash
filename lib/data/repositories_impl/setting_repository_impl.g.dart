// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingRepositoryHash() => r'8ebbf44381d15ce4b260fb2cdbb483d662d8587e';

/// 基于当前激活服务器的设置仓库 Provider。
///
/// Copied from [settingRepository].
@ProviderFor(settingRepository)
final settingRepositoryProvider =
    AutoDisposeFutureProvider<SettingRepository>.internal(
      settingRepository,
      name: r'settingRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingRepositoryHash,
      dependencies: <ProviderOrFamily>[
        activeServerIdProvider,
        storageServiceProvider,
      ],
      allTransitiveDependencies: <ProviderOrFamily>{
        activeServerIdProvider,
        ...?activeServerIdProvider.allTransitiveDependencies,
        storageServiceProvider,
        ...?storageServiceProvider.allTransitiveDependencies,
      },
    );

typedef SettingRepositoryRef = AutoDisposeFutureProviderRef<SettingRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
