class ContainerItemStatsDto {
  const ContainerItemStatsDto({
    required this.sizeRw,
    required this.sizeRootFs,
    required this.containerUsage,
    required this.containerReclaimable,
    required this.imageUsage,
    required this.imageReclaimable,
    required this.volumeUsage,
    required this.volumeReclaimable,
    required this.buildCacheUsage,
    required this.buildCacheReclaimable,
  });

  final int sizeRw;
  final int sizeRootFs;
  final int containerUsage;
  final int containerReclaimable;
  final int imageUsage;
  final int imageReclaimable;
  final int volumeUsage;
  final int volumeReclaimable;
  final int buildCacheUsage;
  final int buildCacheReclaimable;

  factory ContainerItemStatsDto.fromJson(Map<String, dynamic> json) {
    return ContainerItemStatsDto(
      sizeRw: json['sizeRw'] as int? ?? 0,
      sizeRootFs: json['sizeRootFs'] as int? ?? 0,
      containerUsage: json['containerUsage'] as int? ?? 0,
      containerReclaimable: json['containerReclaimable'] as int? ?? 0,
      imageUsage: json['imageUsage'] as int? ?? 0,
      imageReclaimable: json['imageReclaimable'] as int? ?? 0,
      volumeUsage: json['volumeUsage'] as int? ?? 0,
      volumeReclaimable: json['volumeReclaimable'] as int? ?? 0,
      buildCacheUsage: json['buildCacheUsage'] as int? ?? 0,
      buildCacheReclaimable: json['buildCacheReclaimable'] as int? ?? 0,
    );
  }
}
