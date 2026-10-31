/// 操作系统基础信息（Dashboard 概览用）。
class OsInfo {
  const OsInfo({
    required this.platform,
    required this.platformVersion,
    required this.kernelArch,
    required this.kernelVersion,
  });

  final String platform;
  final String platformVersion;
  final String kernelArch;
  final String kernelVersion;
}
