// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_stats_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContainerStatsDto _$ContainerStatsDtoFromJson(Map<String, dynamic> json) =>
    ContainerStatsDto(
      cpuPercent: (json['cpuPercent'] as num).toDouble(),
      memory: (json['memory'] as num).toDouble(),
      cache: (json['cache'] as num).toDouble(),
      ioRead: (json['ioRead'] as num).toDouble(),
      ioWrite: (json['ioWrite'] as num).toDouble(),
      networkRX: (json['networkRX'] as num).toDouble(),
      networkTX: (json['networkTX'] as num).toDouble(),
      shotTime: json['shotTime'] as String,
    );

Map<String, dynamic> _$ContainerStatsDtoToJson(ContainerStatsDto instance) =>
    <String, dynamic>{
      'cpuPercent': instance.cpuPercent,
      'memory': instance.memory,
      'cache': instance.cache,
      'ioRead': instance.ioRead,
      'ioWrite': instance.ioWrite,
      'networkRX': instance.networkRX,
      'networkTX': instance.networkTX,
      'shotTime': instance.shotTime,
    };
