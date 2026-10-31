class ContainerOptionDto {
  const ContainerOptionDto({required this.option});

  final String option;

  factory ContainerOptionDto.fromJson(Map<String, dynamic> json) {
    return ContainerOptionDto(option: json['option'] as String? ?? '');
  }
}
