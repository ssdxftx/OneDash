/// `/hosts/disks` 响应 DTO（对应 Go `response.CompleteDiskInfo`）。
class CompleteDiskDto {
  const CompleteDiskDto({
    this.disks = const [],
    this.unpartitionedDisks = const [],
    this.systemDisks = const [],
    this.totalDisks = 0,
    this.totalCapacity = 0,
  });

  final List<DiskItemDto> disks;
  final List<DiskBasicDto> unpartitionedDisks;
  final List<DiskItemDto> systemDisks;
  final int totalDisks;
  final int totalCapacity;

  bool get isEmpty =>
      disks.isEmpty && unpartitionedDisks.isEmpty && systemDisks.isEmpty;

  factory CompleteDiskDto.fromJson(Map<String, dynamic> json) {
    return CompleteDiskDto(
      disks: _items(json['disks'], DiskItemDto.fromJson),
      unpartitionedDisks: _items(
        json['unpartitionedDisks'],
        DiskBasicDto.fromJson,
      ),
      systemDisks: _items(json['systemDisks'], DiskItemDto.fromJson),
      totalDisks: (json['totalDisks'] as num?)?.toInt() ?? 0,
      totalCapacity: (json['totalCapacity'] as num?)?.toInt() ?? 0,
    );
  }

  static List<T> _items<T>(
    Object? value,
    T Function(Map<String, dynamic>) parse,
  ) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((row) => parse(row.cast<String, dynamic>()))
        .toList(growable: false);
  }
}

/// 单块磁盘及其分区。
class DiskItemDto {
  const DiskItemDto({required this.info, this.partitions = const []});

  final DiskBasicDto info;
  final List<DiskBasicDto> partitions;

  factory DiskItemDto.fromJson(Map<String, dynamic> json) {
    return DiskItemDto(
      info: DiskBasicDto.fromJson(json),
      partitions: switch (json['partitions']) {
        final List rows =>
          rows
              .whereType<Map>()
              .map((row) => DiskBasicDto.fromJson(row.cast<String, dynamic>()))
              .toList(growable: false),
        _ => const [],
      },
    );
  }
}

/// 磁盘或分区的基础信息。
class DiskBasicDto {
  const DiskBasicDto({
    this.device = '',
    this.size = '',
    this.model = '',
    this.diskType = '',
    this.isRemovable = false,
    this.isSystem = false,
    this.filesystem = '',
    this.used = '',
    this.avail = '',
    this.usePercent = 0,
    this.mountPoint = '',
    this.isMounted = false,
    this.serial = '',
  });

  final String device;
  final String size;
  final String model;
  final String diskType;
  final bool isRemovable;
  final bool isSystem;
  final String filesystem;
  final String used;
  final String avail;
  final int usePercent;
  final String mountPoint;
  final bool isMounted;
  final String serial;

  factory DiskBasicDto.fromJson(Map<String, dynamic> json) {
    return DiskBasicDto(
      device: json['device'] as String? ?? '',
      size: json['size'] as String? ?? '',
      model: json['model'] as String? ?? '',
      diskType: json['diskType'] as String? ?? '',
      isRemovable: json['isRemovable'] as bool? ?? false,
      isSystem: json['isSystem'] as bool? ?? false,
      filesystem: json['filesystem'] as String? ?? '',
      used: json['used'] as String? ?? '',
      avail: json['avail'] as String? ?? '',
      usePercent: (json['usePercent'] as num?)?.toInt() ?? 0,
      mountPoint: json['mountPoint'] as String? ?? '',
      isMounted: json['isMounted'] as bool? ?? false,
      serial: json['serial'] as String? ?? '',
    );
  }
}

/// `/hosts/disks/partition` 请求体。
class DiskPartitionReq {
  const DiskPartitionReq({
    required this.device,
    required this.filesystem,
    required this.mountPoint,
    this.label = '',
    this.autoMount = true,
  });

  final String device;
  final String filesystem;
  final String mountPoint;
  final String label;
  final bool autoMount;

  Map<String, dynamic> toJson() {
    return {
      'device': device,
      'filesystem': filesystem,
      'label': label,
      'autoMount': autoMount,
      'mountPoint': mountPoint,
    };
  }
}

/// `/hosts/disks/mount` 请求体。
class DiskMountReq {
  const DiskMountReq({
    required this.device,
    required this.filesystem,
    required this.mountPoint,
    this.autoMount = true,
    this.noFail = true,
  });

  final String device;
  final String filesystem;
  final String mountPoint;
  final bool autoMount;
  final bool noFail;

  Map<String, dynamic> toJson() {
    return {
      'device': device,
      'filesystem': filesystem,
      'mountPoint': mountPoint,
      'autoMount': autoMount,
      'noFail': noFail,
    };
  }
}
