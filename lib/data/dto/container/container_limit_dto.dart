class ContainerLimitDto {
  const ContainerLimitDto({required this.cpu, required this.memory});

  final int cpu;

  /// Host memory in bytes.
  final int memory;

  int get memoryMb => (memory / (1024 * 1024)).round();

  factory ContainerLimitDto.fromJson(Map<String, dynamic> json) {
    return ContainerLimitDto(
      cpu: json['cpu'] as int? ?? 0,
      memory: json['memory'] as int? ?? 0,
    );
  }
}
