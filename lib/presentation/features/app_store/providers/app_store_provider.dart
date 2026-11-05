import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/dto/app/app_catalog_dto.dart';
import '../../../../data/dto/app/app_catalog_search_req.dart';
import '../../../../data/dto/app/app_detail_dto.dart';
import '../../../../data/dto/app/app_installed_dto.dart';
import '../../../../data/dto/app/app_installed_info_dto.dart';
import '../../../../data/dto/app/app_ignored_dto.dart';
import '../../../../data/dto/app/app_installed_search_req.dart';
import '../../../../data/dto/common/page_result.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';

final appCatalogProvider = FutureProvider.autoDispose
    .family<PageResult<AppCatalogDto>, String>((ref, query) {
      return ref
          .watch(appRepositoryProvider.future)
          .then(
            (repository) => repository.searchApps(
              AppCatalogSearchReq(page: 1, pageSize: 100, name: query),
            ),
          );
    }, name: 'appCatalogProvider');

final installedAppsProvider =
    FutureProvider.autoDispose<PageResult<AppInstalledDto>>((ref) {
      return ref
          .watch(appRepositoryProvider.future)
          .then(
            (repository) => repository.searchInstalledApps(
              const AppInstalledSearchReq(page: 1, pageSize: 100),
            ),
          );
    }, name: 'installedAppsProvider');

final appDetailProvider = FutureProvider.autoDispose
    .family<AppDetailDto, String>((ref, key) {
      return ref
          .watch(appRepositoryProvider.future)
          .then((repository) => repository.getAppDetail(key));
    }, name: 'appDetailProvider');

final installedInfoProvider = FutureProvider.autoDispose
    .family<AppInstalledInfoDto, int>((ref, id) {
      return ref
          .watch(appRepositoryProvider.future)
          .then((repository) => repository.getInstalledInfo(id));
    }, name: 'installedInfoProvider');

final installedIgnoredProvider = FutureProvider.autoDispose
    .family<AppIgnoredDto?, int>((ref, installId) async {
      final repository = await ref.watch(appRepositoryProvider.future);
      final ignored = await repository.getIgnoredApps();
      for (final item in ignored) {
        if (item.appId == installId) return item;
      }
      return null;
    }, name: 'installedIgnoredProvider');
