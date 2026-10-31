/// Dashboard 综合数据（基础信息 + 当前指标）。
class Dashboard {
  const Dashboard({required this.base, required this.current});

  final DashboardBase base;
  final DashboardCurrent current;
}

/// 静态主机信息。
class DashboardBase {
  const DashboardBase({
    required this.hostname,
    required this.ipV4Addr,
    required this.os,
    required this.platform,
    required this.platformFamily,
    required this.platformVersion,
    required this.prettyDistro,
    required this.kernelArch,
    required this.kernelVersion,
    required this.cpuCores,
    required this.cpuLogicalCores,
    required this.cpuMhz,
    required this.cpuModelName,
    required this.virtualizationSystem,
    required this.systemProxy,
    required this.websiteNumber,
    required this.databaseNumber,
    required this.cronjobNumber,
    required this.appInstalledNumber,
    required this.agentNumber,
  });

  final String hostname;
  final String ipV4Addr;
  final String os;
  final String platform;
  final String platformFamily;
  final String platformVersion;
  final String prettyDistro;
  final String kernelArch;
  final String kernelVersion;
  final int cpuCores;
  final int cpuLogicalCores;
  final double cpuMhz;
  final String cpuModelName;
  final String virtualizationSystem;
  final String systemProxy;
  final int websiteNumber;
  final int databaseNumber;
  final int cronjobNumber;
  final int appInstalledNumber;
  final int agentNumber;
}

/// 实时性能指标。
class DashboardCurrent {
  const DashboardCurrent({
    required this.uptimeSeconds,
    required this.timeSinceUptime,
    required this.shotTime,
    required this.procs,
    required this.load1,
    required this.load5,
    required this.load15,
    required this.loadUsagePercent,
    required this.cpuTotal,
    required this.cpuUsed,
    required this.cpuUsedPercent,
    required this.cpuPercent,
    required this.cpuDetailedPercent,
    required this.memoryTotal,
    required this.memoryUsed,
    required this.memoryFree,
    required this.memoryAvailable,
    required this.memoryCache,
    required this.memoryUsedPercent,
    required this.swapMemoryTotal,
    required this.swapMemoryUsed,
    required this.swapMemoryAvailable,
    required this.swapMemoryUsedPercent,
    required this.netBytesSent,
    required this.netBytesRecv,
    required this.ioCount,
    required this.ioReadBytes,
    required this.ioReadTime,
    required this.ioWriteBytes,
    required this.ioWriteTime,
    required this.disks,
    required this.topCpuItems,
    required this.topMemItems,
    required this.gpus,
    required this.xpus,
  });

  final int uptimeSeconds;
  final String timeSinceUptime;
  final String shotTime;
  final int procs;
  final double load1;
  final double load5;
  final double load15;
  final double loadUsagePercent;
  final int cpuTotal;
  final double cpuUsed;
  final double cpuUsedPercent;
  final List<double> cpuPercent;
  final List<double> cpuDetailedPercent;
  final int memoryTotal;
  final int memoryUsed;
  final int memoryFree;
  final int memoryAvailable;
  final int memoryCache;
  final double memoryUsedPercent;
  final int swapMemoryTotal;
  final int swapMemoryUsed;
  final int swapMemoryAvailable;
  final double swapMemoryUsedPercent;
  final int netBytesSent;
  final int netBytesRecv;
  final int ioCount;
  final int ioReadBytes;
  final int ioReadTime;
  final int ioWriteBytes;
  final int ioWriteTime;
  final List<DiskUsage> disks;
  final List<ProcessUsage> topCpuItems;
  final List<ProcessUsage> topMemItems;
  final List<GpuInfo> gpus;
  final List<XpuInfo> xpus;
}

/// 磁盘占用（按挂载点）。
class DiskUsage {
  const DiskUsage({
    required this.path,
    required this.device,
    required this.fsType,
    required this.total,
    required this.used,
    required this.free,
    required this.usedPercent,
    required this.inodesTotal,
    required this.inodesUsed,
    required this.inodesFree,
    required this.inodesUsedPercent,
  });

  final String path;
  final String device;
  final String fsType;
  final int total;
  final int used;
  final int free;
  final double usedPercent;
  final int inodesTotal;
  final int inodesUsed;
  final int inodesFree;
  final double inodesUsedPercent;
}

/// 进程资源占用。
class ProcessUsage {
  const ProcessUsage({
    required this.pid,
    required this.name,
    required this.user,
    required this.cmd,
    required this.percent,
    required this.memory,
  });

  final int pid;
  final String name;
  final String user;
  final String cmd;
  final double percent;
  final int memory;
}

/// NVIDIA GPU 信息。
class GpuInfo {
  const GpuInfo({
    required this.index,
    required this.productName,
    required this.utilPercent,
    required this.memUsedBytes,
    required this.memTotalBytes,
    required this.memoryUsagePercent,
    required this.temperatureC,
    required this.powerWatts,
    required this.fanSpeedPercent,
  });

  final int index;
  final String productName;

  /// GPU 利用率（0-100）。
  final double utilPercent;

  final int memUsedBytes;
  final int memTotalBytes;

  /// 显存使用率（0-100）。
  final double memoryUsagePercent;

  /// 温度，摄氏度。
  final double temperatureC;

  /// 功耗，瓦特。
  final double powerWatts;

  /// 风扇转速（0-100）。
  final double fanSpeedPercent;
}

/// XPU 信息。
class XpuInfo {
  const XpuInfo({
    required this.deviceId,
    required this.deviceName,
    required this.memoryBytes,
    required this.memoryUsedBytes,
    required this.memoryUtilPercent,
    required this.powerWatts,
    required this.temperatureC,
  });

  final int deviceId;
  final String deviceName;
  final int memoryBytes;
  final int memoryUsedBytes;

  /// 显存使用率（0-100）。
  final double memoryUtilPercent;

  /// 功耗，瓦特。
  final double powerWatts;

  /// 温度，摄氏度。
  final double temperatureC;
}
