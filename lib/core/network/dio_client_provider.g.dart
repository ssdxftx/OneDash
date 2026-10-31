// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_client_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioClientHash() => r'4c3e2335c6988bb945107e42901461f31fabb4e1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 指定服务器的 DioClient（按 id 缓存，生命周期内复用）。
///
/// 使用 `keepAlive` 避免 Provider 销毁触发重建连接池。
///
/// Copied from [dioClient].
@ProviderFor(dioClient)
const dioClientProvider = DioClientFamily();

/// 指定服务器的 DioClient（按 id 缓存，生命周期内复用）。
///
/// 使用 `keepAlive` 避免 Provider 销毁触发重建连接池。
///
/// Copied from [dioClient].
class DioClientFamily extends Family<AsyncValue<DioClient>> {
  /// 指定服务器的 DioClient（按 id 缓存，生命周期内复用）。
  ///
  /// 使用 `keepAlive` 避免 Provider 销毁触发重建连接池。
  ///
  /// Copied from [dioClient].
  const DioClientFamily();

  /// 指定服务器的 DioClient（按 id 缓存，生命周期内复用）。
  ///
  /// 使用 `keepAlive` 避免 Provider 销毁触发重建连接池。
  ///
  /// Copied from [dioClient].
  DioClientProvider call(int serverId) {
    return DioClientProvider(serverId);
  }

  @override
  DioClientProvider getProviderOverride(covariant DioClientProvider provider) {
    return call(provider.serverId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dioClientProvider';
}

/// 指定服务器的 DioClient（按 id 缓存，生命周期内复用）。
///
/// 使用 `keepAlive` 避免 Provider 销毁触发重建连接池。
///
/// Copied from [dioClient].
class DioClientProvider extends FutureProvider<DioClient> {
  /// 指定服务器的 DioClient（按 id 缓存，生命周期内复用）。
  ///
  /// 使用 `keepAlive` 避免 Provider 销毁触发重建连接池。
  ///
  /// Copied from [dioClient].
  DioClientProvider(int serverId)
    : this._internal(
        (ref) => dioClient(ref as DioClientRef, serverId),
        from: dioClientProvider,
        name: r'dioClientProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$dioClientHash,
        dependencies: DioClientFamily._dependencies,
        allTransitiveDependencies: DioClientFamily._allTransitiveDependencies,
        serverId: serverId,
      );

  DioClientProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.serverId,
  }) : super.internal();

  final int serverId;

  @override
  Override overrideWith(
    FutureOr<DioClient> Function(DioClientRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DioClientProvider._internal(
        (ref) => create(ref as DioClientRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        serverId: serverId,
      ),
    );
  }

  @override
  FutureProviderElement<DioClient> createElement() {
    return _DioClientProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DioClientProvider && other.serverId == serverId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, serverId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DioClientRef on FutureProviderRef<DioClient> {
  /// The parameter `serverId` of this provider.
  int get serverId;
}

class _DioClientProviderElement extends FutureProviderElement<DioClient>
    with DioClientRef {
  _DioClientProviderElement(super.provider);

  @override
  int get serverId => (origin as DioClientProvider).serverId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
