import '../../../core/utils/unit_parser.dart';
import '../../../domain/entities/dashboard.dart';

/// Dashboard 响应解析器。
///
/// 命名遵循 1Panel 返回（camelCase）。全部方法静态化，调用方直接用
/// `DashboardDto.parseBase(json)` / `DashboardDto.parseCurrent(json)`，
/// 无需构造实例。缺失字段统一兜底为 0 / 空串，不抛异常。
class DashboardDto {
  const DashboardDto._();

  /// 合并 base 与 current 为完整 [Dashboard]。
  ///
  /// [currentJson] 为空时会尝试读取 [baseJson] 的 `currentInfo` 字段，
  /// 仍缺失则使用空映射。
  static Dashboard parse({
    required Map<String, dynamic> baseJson,
    Map<String, dynamic>? currentJson,
  }) {
    final current =
        currentJson ??
        (baseJson['currentInfo'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    return Dashboard(base: parseBase(baseJson), current: parseCurrent(current));
  }

  static DashboardBase parseBase(Map<String, dynamic> json) {
    return DashboardBase(
      hostname: _str(json['hostname']),
      ipV4Addr: _str(json['ipV4Addr']),
      os: _str(json['os']),
      platform: _str(json['platform']),
      platformFamily: _str(json['platformFamily']),
      platformVersion: _str(json['platformVersion']),
      prettyDistro: _str(json['prettyDistro']),
      kernelArch: _str(json['kernelArch']),
      kernelVersion: _str(json['kernelVersion']),
      cpuCores: _int(json['cpuCores']),
      cpuLogicalCores: _int(json['cpuLogicalCores']),
      cpuMhz: _double(json['cpuMhz']),
      cpuModelName: _str(json['cpuModelName']),
      virtualizationSystem: _str(json['virtualizationSystem']),
      systemProxy: _str(json['systemProxy']),
      websiteNumber: _int(json['websiteNumber']),
      databaseNumber: _int(json['databaseNumber']),
      cronjobNumber: _int(json['cronjobNumber']),
      appInstalledNumber: _int(json['appInstalledNumber']),
      agentNumber: _int(json['agentNumber']),
    );
  }

  static DashboardCurrent parseCurrent(Map<String, dynamic> json) {
    return DashboardCurrent(
      uptimeSeconds: _int(json['uptime']),
      timeSinceUptime: _str(json['timeSinceUptime']),
      shotTime: _str(json['shotTime']),
      procs: _int(json['procs']),
      load1: _double(json['load1']),
      load5: _double(json['load5']),
      load15: _double(json['load15']),
      loadUsagePercent: _double(json['loadUsagePercent']),
      cpuTotal: _int(json['cpuTotal']),
      cpuUsed: _double(json['cpuUsed']),
      cpuUsedPercent: _double(json['cpuUsedPercent']),
      cpuPercent: _doubleList(json['cpuPercent']),
      cpuDetailedPercent: _doubleList(json['cpuDetailedPercent']),
      memoryTotal: _int(json['memoryTotal']),
      memoryUsed: _int(json['memoryUsed']),
      memoryFree: _int(json['memoryFree']),
      memoryAvailable: _int(json['memoryAvailable']),
      memoryCache: _int(json['memoryCache']),
      memoryUsedPercent: _double(json['memoryUsedPercent']),
      swapMemoryTotal: _int(json['swapMemoryTotal']),
      swapMemoryUsed: _int(json['swapMemoryUsed']),
      swapMemoryAvailable: _int(json['swapMemoryAvailable']),
      swapMemoryUsedPercent: _double(json['swapMemoryUsedPercent']),
      netBytesSent: _int(json['netBytesSent']),
      netBytesRecv: _int(json['netBytesRecv']),
      ioCount: _int(json['ioCount']),
      ioReadBytes: _int(json['ioReadBytes']),
      ioReadTime: _int(json['ioReadTime']),
      ioWriteBytes: _int(json['ioWriteBytes']),
      ioWriteTime: _int(json['ioWriteTime']),
      disks: _mapList(json['diskData'], _parseDisk),
      topCpuItems: _mapList(json['topCPUItems'], _parseProcess),
      topMemItems: _mapList(json['topMemItems'], _parseProcess),
      gpus: _mapList(json['gpuData'], _parseGpu),
      xpus: _mapList(json['xpuData'], _parseXpu),
    );
  }

  static DiskUsage _parseDisk(Map<String, dynamic> json) {
    return DiskUsage(
      path: _str(json['path']),
      device: _str(json['device']),
      fsType: _str(json['type'] ?? json['fsType']),
      total: _int(json['total']),
      used: _int(json['used']),
      free: _int(json['free']),
      usedPercent: _double(json['usedPercent']),
      inodesTotal: _int(json['inodesTotal']),
      inodesUsed: _int(json['inodesUsed']),
      inodesFree: _int(json['inodesFree']),
      inodesUsedPercent: _double(json['inodesUsedPercent']),
    );
  }

  static ProcessUsage _parseProcess(Map<String, dynamic> json) {
    return ProcessUsage(
      pid: _int(json['pid']),
      name: _str(json['name']),
      user: _str(json['user']),
      cmd: _str(json['cmd']),
      percent: _double(json['percent']),
      memory: _int(json['memory']),
    );
  }

  static GpuInfo _parseGpu(Map<String, dynamic> json) {
    return GpuInfo(
      index: _int(json['index']),
      productName: _str(json['productName']),
      utilPercent: UnitParser.number(_str(json['gpuUtil'])),
      memUsedBytes: UnitParser.bytes(_str(json['memUsed'])),
      memTotalBytes: UnitParser.bytes(_str(json['memTotal'])),
      memoryUsagePercent: UnitParser.number(_str(json['memoryUsage'])),
      temperatureC: UnitParser.number(_str(json['temperature'])),
      powerWatts: UnitParser.number(_str(json['powerUsage'])),
      fanSpeedPercent: UnitParser.number(_str(json['fanSpeed'])),
    );
  }

  static XpuInfo _parseXpu(Map<String, dynamic> json) {
    return XpuInfo(
      deviceId: _int(json['deviceID']),
      deviceName: _str(json['deviceName']),
      memoryBytes: UnitParser.bytes(_str(json['memory'])),
      memoryUsedBytes: UnitParser.bytes(_str(json['memoryUsed'])),
      memoryUtilPercent: UnitParser.number(_str(json['memoryUtil'])),
      powerWatts: UnitParser.number(_str(json['power'])),
      temperatureC: UnitParser.number(_str(json['temperature'])),
    );
  }

  static List<T> _mapList<T>(
    Object? value,
    T Function(Map<String, dynamic> json) mapper,
  ) {
    return value is List
        ? value
              .whereType<Map<String, dynamic>>()
              .map(mapper)
              .toList(growable: false)
        : const [];
  }

  static String _str(Object? v) => v?.toString() ?? '';

  static int _int(Object? v) =>
      (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

  static double _double(Object? v) =>
      (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;

  static List<double> _doubleList(Object? v) =>
      v is List ? v.map(_double).toList(growable: false) : const <double>[];
}
