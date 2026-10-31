import '../../../domain/entities/os_info.dart';

/// `/dashboard/base/os` 响应 DTO。
class OsInfoDto {
  const OsInfoDto({
    required this.platform,
    required this.platformVersion,
    required this.kernelArch,
    required this.kernelVersion,
  });

  factory OsInfoDto.fromJson(Map<String, dynamic> json) {
    return OsInfoDto(
      platform: (json['platform'] ?? '') as String,
      platformVersion: (json['platformVersion'] ?? '') as String,
      kernelArch: (json['kernelArch'] ?? '') as String,
      kernelVersion: (json['kernelVersion'] ?? '') as String,
    );
  }

  final String platform;
  final String platformVersion;
  final String kernelArch;
  final String kernelVersion;

  OsInfo toEntity() => OsInfo(
    platform: platform,
    platformVersion: platformVersion,
    kernelArch: kernelArch,
    kernelVersion: kernelVersion,
  );
}
