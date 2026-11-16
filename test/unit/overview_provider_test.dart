import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/data/dto/dashboard/dashboard_dto.dart';
import 'package:onedash/data/repositories_impl/repository_providers.dart';
import 'package:onedash/domain/entities/dashboard.dart';
import 'package:onedash/domain/repositories/dashboard_repository.dart';
import 'package:onedash/presentation/features/dashboard/providers/overview_provider.dart';

class _PollingDashboardRepository implements DashboardRepository {
  _PollingDashboardRepository();

  final dashboard = DashboardDto.parse(
    baseJson: const {},
    currentJson: const {},
  );
  int currentCalls = 0;

  @override
  Future<Dashboard> getDashboardSnapshot({
    required String ioOption,
    required String netOption,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return dashboard;
  }

  @override
  Future<DashboardCurrent> getDashboardCurrent({
    required String ioOption,
    required String netOption,
  }) async {
    currentCalls++;
    return dashboard.current;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RetryDashboardRepository implements DashboardRepository {
  _RetryDashboardRepository();

  var calls = 0;
  final dashboard = DashboardDto.parse(
    baseJson: const {},
    currentJson: const {},
  );

  @override
  Future<Dashboard> getDashboardSnapshot({
    required String ioOption,
    required String netOption,
  }) async {
    calls++;
    if (calls == 1) throw StateError('offline');
    return dashboard;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('overview retry recovers after the initial request fails', () async {
    final repository = _RetryDashboardRepository();
    final container = ProviderContainer(
      overrides: [
        dashboardRepositoryForServerProvider.overrideWith(
          (ref, serverId) => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      overviewProvider(1),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await expectLater(
      container.read(overviewProvider(1).future),
      throwsA(isA<StateError>()),
    );

    await container.read(overviewProvider(1).notifier).refresh();

    expect(repository.calls, 2);
    expect(container.read(overviewProvider(1)).hasValue, isTrue);
  });

  test(
    'polling starts even when visibility arrives before initial load',
    () async {
      final repository = _PollingDashboardRepository();
      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryForServerProvider.overrideWith(
            (ref, serverId) => repository,
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        overviewProvider(1),
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      container.read(overviewProvider(1).notifier).setVisible(true);
      await Future<void>.delayed(const Duration(milliseconds: 900));

      expect(repository.currentCalls, greaterThanOrEqualTo(1));
    },
  );

  test('visible dashboard polls current data every second', () async {
    final repository = _PollingDashboardRepository();
    final container = ProviderContainer(
      overrides: [
        dashboardRepositoryForServerProvider.overrideWith(
          (ref, serverId) => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      overviewProvider(1),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    container.read(overviewProvider(1).notifier).setVisible(true);
    await Future<void>.delayed(const Duration(milliseconds: 2300));

    expect(repository.currentCalls, greaterThanOrEqualTo(2));
  });
}
