import 'package:json_annotation/json_annotation.dart';

part 'container_by_image_dto.g.dart';

@JsonSerializable()
class ContainerByImageDto {
  const ContainerByImageDto({required this.name, required this.state});

  factory ContainerByImageDto.fromJson(Map<String, dynamic> json) =>
      _$ContainerByImageDtoFromJson(json);

  final String name;
  final String state;

  Map<String, dynamic> toJson() => _$ContainerByImageDtoToJson(this);
}
