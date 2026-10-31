// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardRepositoryHash() =>
    r'787a066a445a402081b144877346448e1018ef5a';

/// 基于当前激活服务器的仓库 Provider。
///
/// Copied from [dashboardRepository].
@ProviderFor(dashboardRepository)
final dashboardRepositoryProvider =
    AutoDisposeFutureProvider<DashboardRepository>.internal(
      dashboardRepository,
      name: r'dashboardRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardRepositoryHash,
      dependencies: <ProviderOrFamily>[activeServerIdProvider],
      allTransitiveDependencies: <ProviderOrFamily>{
        activeServerIdProvider,
        ...?activeServerIdProvider.allTransitiveDependencies,
      },
    );

typedef DashboardRepositoryRef =
    AutoDisposeFutureProviderRef<DashboardRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
