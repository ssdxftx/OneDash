class RuleInfoDto {
  const RuleInfoDto({
    this.id,
    this.chain,
    this.family,
    this.address,
    this.port,
    this.protocol,
    this.strategy,
    this.num,
    this.targetIP,
    this.targetPort,
    this.interface,
    this.usedStatus,
    this.processInfo,
    this.description,
  });

  factory RuleInfoDto.fromJson(Map<String, dynamic> json) {
    return RuleInfoDto(
      id: json['id'] as int?,
      chain: json['chain'] as String?,
      family: json['family'] as String?,
      address: json['address'] as String?,
      port: json['port'] as String?,
      protocol: json['protocol'] as String?,
      strategy: json['strategy'] as String?,
      num: json['num'] as String?,
      targetIP: json['targetIP'] as String?,
      targetPort: json['targetPort'] as String?,
      interface: json['interface'] as String?,
      usedStatus: json['usedStatus'] as String?,
      description: json['description'] as String?,
    );
  }

  final int? id;
  final String? chain;
  final String? family;
  final String? address;
  final String? port;
  final String? protocol;
  final String? strategy;
  final String? num;
  final String? targetIP;
  final String? targetPort;
  final String? interface;
  final String? usedStatus;
  final Map<String, dynamic>? processInfo;
  final String? description;

  RuleInfoDto copyWith({
    int? id,
    String? chain,
    String? family,
    String? address,
    String? port,
    String? protocol,
    String? strategy,
    String? num,
    String? targetIP,
    String? targetPort,
    String? interface,
    String? usedStatus,
    Map<String, dynamic>? processInfo,
    String? description,
  }) {
    return RuleInfoDto(
      id: id ?? this.id,
      chain: chain ?? this.chain,
      family: family ?? this.family,
      address: address ?? this.address,
      port: port ?? this.port,
      protocol: protocol ?? this.protocol,
      strategy: strategy ?? this.strategy,
      num: num ?? this.num,
      targetIP: targetIP ?? this.targetIP,
      targetPort: targetPort ?? this.targetPort,
      interface: interface ?? this.interface,
      usedStatus: usedStatus ?? this.usedStatus,
      processInfo: processInfo ?? this.processInfo,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toPortRuleJson({String? operation}) {
    final json = {
      'chain': chain ?? '',
      'family': family ?? '',
      'address': isAnyAddress ? '' : (address ?? ''),
      'port': port ?? '',
      'protocol': protocol ?? '',
      'strategy': strategy ?? 'accept',
      'description': description ?? '',
    };
    if (operation != null) json['operation'] = operation;
    return json;
  }

  String get displayAddress {
    if (address == null || address!.isEmpty || address == 'Anywhere') {
      return '所有地址';
    }
    return address!;
  }

  String get displayProtocol {
    switch (protocol) {
      case 'tcp':
        return 'TCP';
      case 'udp':
        return 'UDP';
      case 'tcp/udp':
        return 'TCP/UDP';
      default:
        return protocol ?? '-';
    }
  }

  bool get isAccept =>
      strategy?.toLowerCase() == 'accept' || strategy?.toLowerCase() == 'allow';

  bool get isAnyAddress =>
      address == null ||
      address!.isEmpty ||
      address == 'Anywhere' ||
      address == '0.0.0.0/0' ||
      address == '::/0';
}
