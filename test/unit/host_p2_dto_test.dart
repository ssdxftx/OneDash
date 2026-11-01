import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/data/dto/host/disk_dto.dart';
import 'package:onedash/data/dto/host/host_diagnostics_dto.dart';

void main() {
  test('CompleteDiskDto parses system, data and unpartitioned disks', () {
    final dto = CompleteDiskDto.fromJson({
      'totalDisks': 2,
      'totalCapacity': 100,
      'systemDisks': [
        {
          'device': 'vda',
          'size': '40G',
          'diskType': 'HDD',
          'partitions': [
            {
              'device': '/dev/vda2',
              'filesystem': 'ext4',
              'mountPoint': '/',
              'usePercent': 54,
              'isMounted': true,
            },
          ],
        },
      ],
      'disks': [
        {'device': '/dev/vdb', 'size': '60G', 'partitions': null},
      ],
      'unpartitionedDisks': [
        {'device': '/dev/vdc', 'size': '20G'},
      ],
    });

    expect(dto.totalDisks, 2);
    expect(dto.systemDisks.single.info.device, 'vda');
    expect(dto.systemDisks.single.partitions.single.mountPoint, '/');
    expect(dto.disks.single.partitions, isEmpty);
    expect(dto.unpartitionedDisks.single.device, '/dev/vdc');
    expect(dto.isEmpty, isFalse);
  });

  test('disk requests use the v2.4.2 JSON field names', () {
    const partition = DiskPartitionReq(
      device: '/dev/vdc',
      filesystem: 'xfs',
      mountPoint: '/data',
      label: 'data',
    );
    const mount = DiskMountReq(
      device: '/dev/vdb1',
      filesystem: 'ext4',
      mountPoint: '/mnt/vdb1',
      noFail: false,
    );

    expect(partition.toJson(), {
      'device': '/dev/vdc',
      'filesystem': 'xfs',
      'label': 'data',
      'autoMount': true,
      'mountPoint': '/data',
    });
    expect(mount.toJson(), {
      'device': '/dev/vdb1',
      'filesystem': 'ext4',
      'mountPoint': '/mnt/vdb1',
      'autoMount': true,
      'noFail': false,
    });
  });

  test('component DTO parses missing executable response', () {
    final dto = ComponentInfoDto.fromJson({
      'exists': false,
      'error': 'exec: ffmpeg: executable file not found',
    });

    expect(dto.exists, isFalse);
    expect(dto.version, isEmpty);
    expect(dto.error, contains('ffmpeg'));
  });

  test('diagnostics DTOs tolerate missing fields', () {
    final summary = DiagnosticsSummaryDto.fromJson({'rss': 1024});
    final snapshot = GoroutineSnapshotDto.fromJson({
      'total': 2,
      'goroutines': [
        {
          'state': 'select',
          'top': 'database/sql.',
          'count': 2,
          'stack': ['frame one', 3],
        },
      ],
    });

    expect(summary.rss, 1024);
    expect(summary.heapAlloc, 0);
    expect(snapshot.total, 2);
    expect(snapshot.groups.single.count, 2);
    expect(snapshot.groups.single.stack, ['frame one', '3']);
  });
}
