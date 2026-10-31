class ContainerSearchDto {
  const ContainerSearchDto({required this.total, required this.items});

  final int total;
  final List<ContainerItemDto> items;

  factory ContainerSearchDto.fromJson(Map<String, dynamic> json) {
    return ContainerSearchDto(
      total: json['total'] as int? ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ContainerItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ContainerItemDto {
  const ContainerItemDto({
    required this.containerID,
    required this.name,
    required this.imageID,
    required this.imageName,
    required this.createTime,
    required this.state,
    required this.runTime,
    this.network,
    this.ports,
    required this.isFromApp,
    required this.isFromCompose,
    this.appName,
    this.appInstallName,
    this.websites,
    required this.isPinned,
    required this.description,
  });

  final String containerID;
  final String name;
  final String imageID;
  final String imageName;
  final String createTime;
  final String state;
  final String runTime;
  final List<String>? network;
  final List<String>? ports;
  final bool isFromApp;
  final bool isFromCompose;
  final String? appName;
  final String? appInstallName;
  final List<String>? websites;
  final bool isPinned;
  final String description;

  factory ContainerItemDto.fromJson(Map<String, dynamic> json) {
    return ContainerItemDto(
      containerID: json['containerID'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageID: json['imageID'] as String? ?? '',
      imageName: json['imageName'] as String? ?? '',
      createTime: json['createTime'] as String? ?? '',
      state: json['state'] as String? ?? '',
      runTime: json['runTime'] as String? ?? '',
      network: (json['network'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      ports: (json['ports'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isFromApp: json['isFromApp'] as bool? ?? false,
      isFromCompose: json['isFromCompose'] as bool? ?? false,
      appName: json['appName'] as String?,
      appInstallName: json['appInstallName'] as String?,
      websites: (json['websites'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isPinned: json['isPinned'] as bool? ?? false,
      description: json['description'] as String? ?? '',
    );
  }
}
