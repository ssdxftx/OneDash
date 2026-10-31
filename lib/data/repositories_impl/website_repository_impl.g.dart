// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteRepositoryHash() => r'b3d63a8050450833cc5b12220dddb00a14e81b33';

/// 基于当前激活服务器的仓库 Provider。
///
/// Copied from [websiteRepository].
@ProviderFor(websiteRepository)
final websiteRepositoryProvider =
    AutoDisposeFutureProvider<WebsiteRepository>.internal(
      websiteRepository,
      name: r'websiteRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$websiteRepositoryHash,
      dependencies: <ProviderOrFamily>[activeServerIdProvider],
      allTransitiveDependencies: <ProviderOrFamily>{
        activeServerIdProvider,
        ...?activeServerIdProvider.allTransitiveDependencies,
      },
    );

typedef WebsiteRepositoryRef = AutoDisposeFutureProviderRef<WebsiteRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
