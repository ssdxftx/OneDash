// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fileRepositoryHash() => r'02ab9a013f86fdbc806c118b2b0f017d9a9877fc';

/// 基于当前激活服务器的文件仓库 Provider。
///
/// Copied from [fileRepository].
@ProviderFor(fileRepository)
final fileRepositoryProvider =
    AutoDisposeFutureProvider<FileRepository>.internal(
      fileRepository,
      name: r'fileRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fileRepositoryHash,
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

typedef FileRepositoryRef = AutoDisposeFutureProviderRef<FileRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
