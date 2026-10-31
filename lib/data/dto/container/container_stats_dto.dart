import 'package:json_annotation/json_annotation.dart';

part 'container_stats_dto.g.dart';

@JsonSerializable()
class ContainerStatsDto {
  const ContainerStatsDto({
    required this.cpuPercent,
    required this.memory,
    required this.cache,
    required this.ioRead,
    required this.ioWrite,
    required this.networkRX,
    required this.networkTX,
    required this.shotTime,
  });

  factory ContainerStatsDto.fromJson(Map<String, dynamic> json) =>
      _$ContainerStatsDtoFromJson(json);

  final double cpuPercent;
  final double memory;
  final double cache;
  final double ioRead;
  final double ioWrite;
  final double networkRX;
  final double networkTX;
  final String shotTime;

  Map<String, dynamic> toJson() => _$ContainerStatsDtoToJson(this);
}
