import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/dto/common/page_result.dart';
import '../../../../data/dto/cronjob/cronjob_dto.dart';
import '../../../../data/repositories_impl/cronjob_repository_impl.dart';

final cronjobsProvider = FutureProvider.autoDispose<PageResult<CronjobDto>>((
  ref,
) {
  return ref
      .watch(cronjobRepositoryProvider.future)
      .then(
        (repository) => repository.searchCronjobs({
          'page': 1,
          'pageSize': 100,
          'info': '',
          'orderBy': 'createdAt',
          'order': 'descending',
        }),
      );
}, name: 'cronjobsProvider');

final cronjobRecordsProvider = FutureProvider.autoDispose
    .family<PageResult<CronjobRecordDto>, int>((ref, id) {
      final now = DateTime.now();
      return ref
          .watch(cronjobRepositoryProvider.future)
          .then(
            (repository) => repository.searchRecords({
              'page': 1,
              'pageSize': 50,
              'cronjobID': id,
              'startTime': now
                  .subtract(const Duration(days: 30))
                  .toUtc()
                  .toIso8601String(),
              'endTime': now.toUtc().toIso8601String(),
              'status': '',
            }),
          );
    }, name: 'cronjobRecordsProvider');
