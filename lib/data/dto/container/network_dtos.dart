class NetworkDto {
  const NetworkDto({
    required this.id,
    required this.name,
    this.labels = const [],
    this.driver = '',
    this.ipamDriver = '',
    this.subnet = '',
    this.gateway = '',
    this.createdAt = '',
    this.attachable = false,
  });

  final String id;
  final String name;
  final List<String> labels;
  final String driver;
  final String ipamDriver;
  final String subnet;
  final String gateway;
  final String createdAt;
  final bool attachable;

  bool get isSystem => const ['bridge', 'none', 'host'].contains(name);

  factory NetworkDto.fromJson(Map<String, dynamic> json) {
    return NetworkDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      labels:
          (json['labels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      driver: json['driver'] as String? ?? '',
      ipamDriver: json['ipamDriver'] as String? ?? '',
      subnet: json['subnet'] as String? ?? '',
      gateway: json['gateway'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      attachable: json['attachable'] as bool? ?? false,
    );
  }
}

class NetworkSearchDto {
  const NetworkSearchDto({required this.total, required this.items});

  final int total;
  final List<NetworkDto> items;

  factory NetworkSearchDto.fromJson(Map<String, dynamic> json) {
    return NetworkSearchDto(
      total: json['total'] is num
          ? (json['total'] as num).toInt()
          : int.tryParse(json['total']?.toString() ?? '') ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => NetworkDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class NetworkCreateReq {
  const NetworkCreateReq({
    required this.name,
    required this.driver,
    this.options = const [],
    this.labels = const [],
    this.ipv4 = false,
    this.subnet = '',
    this.gateway = '',
    this.ipRange = '',
    this.auxAddress = const [],
    this.ipv6 = false,
    this.subnetV6 = '',
    this.gatewayV6 = '',
    this.ipRangeV6 = '',
    this.auxAddressV6 = const [],
  });

  final String name;
  final String driver;
  final List<String> options;
  final List<String> labels;
  final bool ipv4;
  final String subnet;
  final String gateway;
  final String ipRange;
  final List<AuxAddress> auxAddress;
  final bool ipv6;
  final String subnetV6;
  final String gatewayV6;
  final String ipRangeV6;
  final List<AuxAddress> auxAddressV6;

  Map<String, dynamic> toJson() => {
    'name': name,
    'driver': driver,
    'options': options,
    'labels': labels,
    'ipv4': ipv4,
    'subnet': subnet,
    'gateway': gateway,
    'ipRange': ipRange,
    'auxAddress': auxAddress.map((e) => e.toJson()).toList(),
    'ipv6': ipv6,
    'subnetV6': subnetV6,
    'gatewayV6': gatewayV6,
    'ipRangeV6': ipRangeV6,
    'auxAddressV6': auxAddressV6.map((e) => e.toJson()).toList(),
  };
}

class AuxAddress {
  const AuxAddress({required this.key, required this.value});

  final String key;
  final String value;

  Map<String, dynamic> toJson() => {'key': key, 'value': value};
}
