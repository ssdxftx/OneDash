import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/data/dto/common/page_result.dart';
import 'package:onedash/data/dto/cronjob/cronjob_dto.dart';
import 'package:onedash/data/repositories_impl/cronjob_repository_impl.dart';
import 'package:onedash/domain/repositories/cronjob_repository.dart';
import 'package:onedash/presentation/features/cronjobs/providers/cronjobs_provider.dart';

class _FakeCronjobRepository implements CronjobRepository {
  _FakeCronjobRepository({this.onSearchCronjobs, this.onSearchRecords});

  final Future<PageResult<CronjobDto>> Function(Map<String, dynamic> req)?
  onSearchCronjobs;
  final Future<PageResult<CronjobRecordDto>> Function(Map<String, dynamic> req)?
  onSearchRecords;

  @override
  Future<PageResult<CronjobDto>> searchCronjobs(Map<String, dynamic> req) =>
      onSearchCronjobs?.call(req) ??
      Future.value(const PageResult<CronjobDto>(total: 0, items: []));

  @override
  Future<PageResult<CronjobRecordDto>> searchRecords(
    Map<String, dynamic> req,
  ) =>
      onSearchRecords?.call(req) ??
      Future.value(const PageResult<CronjobRecordDto>(total: 0, items: []));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('cronjobs request carries required paging fields', () async {
    late Map<String, dynamic> captured;
    final container = ProviderContainer(
      overrides: [
        cronjobRepositoryProvider.overrideWith(
          (ref) async => _FakeCronjobRepository(
            onSearchCronjobs: (req) async {
              captured = req;
              return const PageResult<CronjobDto>(total: 0, items: []);
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(cronjobsProvider.future);

    expect(captured['orderBy'], 'createdAt');
    expect(captured['order'], 'descending');
    expect(captured['info'], '');
    expect(captured['page'], 1);
    expect(captured['pageSize'], 100);
  });

  test('records request carries a valid 30-day window', () async {
    late Map<String, dynamic> captured;
    final container = ProviderContainer(
      overrides: [
        cronjobRepositoryProvider.overrideWith(
          (ref) async => _FakeCronjobRepository(
            onSearchRecords: (req) async {
              captured = req;
              return const PageResult<CronjobRecordDto>(total: 0, items: []);
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(cronjobRecordsProvider(7).future);

    expect(captured['cronjobID'], 7);
    expect(captured['status'], '');
    final start = DateTime.parse(captured['startTime'] as String);
    final end = DateTime.parse(captured['endTime'] as String);
    expect(end.isAfter(start), isTrue);
    expect(end.difference(start).inDays, inInclusiveRange(29, 30));
    expect(captured['startTime'], endsWith('Z'));
    expect(captured['endTime'], endsWith('Z'));
  });
}
