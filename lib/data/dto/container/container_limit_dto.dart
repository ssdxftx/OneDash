class ContainerLimitDto {
  const ContainerLimitDto({required this.cpu, required this.memory});

  final int cpu;
  final int memory;

  factory ContainerLimitDto.fromJson(Map<String, dynamic> json) {
    return ContainerLimitDto(
      cpu: json['cpu'] as int? ?? 0,
      memory: json['memory'] as int? ?? 0,
    );
  }
}
