import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/data/dto/app/app_catalog_dto.dart';
import 'package:onedash/data/dto/app/app_catalog_search_req.dart';
import 'package:onedash/data/dto/app/app_installed_dto.dart';
import 'package:onedash/data/dto/app/app_installed_search_req.dart';
import 'package:onedash/data/dto/common/page_result.dart';
import 'package:onedash/data/repositories_impl/app_repository_impl.dart';
import 'package:onedash/domain/repositories/app_repository.dart';
import 'package:onedash/presentation/features/app_store/providers/app_store_provider.dart';
import 'package:onedash/presentation/features/server_detail/providers/active_server_provider.dart';

class _FakeAppRepository implements AppRepository {
  _FakeAppRepository(this.marker);

  final int marker;

  @override
  Future<PageResult<AppCatalogDto>> searchApps(AppCatalogSearchReq req) async =>
      PageResult<AppCatalogDto>(total: marker, items: const []);

  @override
  Future<PageResult<AppInstalledDto>> searchInstalledApps(
    AppInstalledSearchReq req,
  ) async => PageResult<AppInstalledDto>(total: marker, items: const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('app store providers rebuild for the active server', () async {
    final first = _FakeAppRepository(1);
    final second = _FakeAppRepository(2);
    final container = ProviderContainer(
      overrides: [
        appRepositoryProvider.overrideWith((ref) async {
          final serverId = ref.watch(activeServerIdProvider);
          return serverId == 1 ? first : second;
        }),
      ],
    );
    addTearDown(container.dispose);
    final catalog = container.listen(
      appCatalogProvider(''),
      (_, _) {},
      fireImmediately: true,
    );
    final installed = container.listen(
      installedAppsProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(catalog.close);
    addTearDown(installed.close);

    container.read(activeServerIdStateProvider.notifier).state = 1;
    expect((await container.read(appCatalogProvider('').future)).total, 1);
    expect((await container.read(installedAppsProvider.future)).total, 1);

    container.read(activeServerIdStateProvider.notifier).state = 2;
    expect((await container.read(appCatalogProvider('').future)).total, 2);
    expect((await container.read(installedAppsProvider.future)).total, 2);
  });
}
