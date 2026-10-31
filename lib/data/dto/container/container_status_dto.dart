class ContainerStatusDto {
  const ContainerStatusDto({
    required this.created,
    required this.running,
    required this.paused,
    required this.restarting,
    required this.removing,
    required this.exited,
    required this.dead,
    required this.containerCount,
    required this.composeCount,
    required this.composeTemplateCount,
    required this.imageCount,
    required this.networkCount,
    required this.volumeCount,
    required this.repoCount,
  });

  final int created;
  final int running;
  final int paused;
  final int restarting;
  final int removing;
  final int exited;
  final int dead;
  final int containerCount;
  final int composeCount;
  final int composeTemplateCount;
  final int imageCount;
  final int networkCount;
  final int volumeCount;
  final int repoCount;

  factory ContainerStatusDto.fromJson(Map<String, dynamic> json) {
    return ContainerStatusDto(
      created: json['created'] as int? ?? 0,
      running: json['running'] as int? ?? 0,
      paused: json['paused'] as int? ?? 0,
      restarting: json['restarting'] as int? ?? 0,
      removing: json['removing'] as int? ?? 0,
      exited: json['exited'] as int? ?? 0,
      dead: json['dead'] as int? ?? 0,
      containerCount: json['containerCount'] as int? ?? 0,
      composeCount: json['composeCount'] as int? ?? 0,
      composeTemplateCount: json['composeTemplateCount'] as int? ?? 0,
      imageCount: json['imageCount'] as int? ?? 0,
      networkCount: json['networkCount'] as int? ?? 0,
      volumeCount: json['volumeCount'] as int? ?? 0,
      repoCount: json['repoCount'] as int? ?? 0,
    );
  }
}
