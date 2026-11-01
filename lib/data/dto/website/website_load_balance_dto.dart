/// `/websites/:id/lbs` 列表项（对应 Go `dto.NginxUpstream`）。
class WebsiteLoadBalanceDto {
  const WebsiteLoadBalanceDto({
    this.name = '',
    this.algorithm = '',
    this.content = '',
    this.servers = const [],
  });

  final String name;
  final String algorithm;
  final String content;
  final List<WebsiteLoadBalanceServerDto> servers;

  factory WebsiteLoadBalanceDto.fromJson(Map<String, dynamic> json) {
    return WebsiteLoadBalanceDto(
      name: json['name'] as String? ?? '',
      algorithm: json['algorithm'] as String? ?? '',
      content: json['content'] as String? ?? '',
      servers: switch (json['servers']) {
        final List rows =>
          rows
              .whereType<Map>()
              .map(
                (row) => WebsiteLoadBalanceServerDto.fromJson(
                  row.cast<String, dynamic>(),
                ),
              )
              .toList(growable: false),
        _ => const [],
      },
    );
  }
}

/// 负载均衡上游节点。
class WebsiteLoadBalanceServerDto {
  const WebsiteLoadBalanceServerDto({
    this.server = '',
    this.weight = 1,
    this.failTimeout = 10,
    this.failTimeoutUnit = 's',
    this.maxFails = 3,
    this.maxConns = 0,
    this.flag = '',
  });

  final String server;
  final int weight;
  final int failTimeout;
  final String failTimeoutUnit;
  final int maxFails;
  final int maxConns;
  final String flag;

  factory WebsiteLoadBalanceServerDto.fromJson(Map<String, dynamic> json) {
    return WebsiteLoadBalanceServerDto(
      server: json['server'] as String? ?? '',
      weight: (json['weight'] as num?)?.toInt() ?? 1,
      failTimeout: (json['failTimeout'] as num?)?.toInt() ?? 10,
      failTimeoutUnit: json['failTimeoutUnit'] as String? ?? 's',
      maxFails: (json['maxFails'] as num?)?.toInt() ?? 3,
      maxConns: (json['maxConns'] as num?)?.toInt() ?? 0,
      flag: json['flag'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'server': server,
      'weight': weight,
      'failTimeout': failTimeout,
      'failTimeoutUnit': failTimeoutUnit,
      'maxFails': maxFails,
      'maxConns': maxConns,
      'flag': flag,
    };
  }
}

/// `/websites/lbs/create` 与 `/websites/lbs/update` 请求体。
class WebsiteLoadBalanceReq {
  const WebsiteLoadBalanceReq({
    required this.websiteId,
    required this.name,
    required this.algorithm,
    required this.servers,
  });

  final int websiteId;
  final String name;
  final String algorithm;
  final List<WebsiteLoadBalanceServerDto> servers;

  Map<String, dynamic> toJson() {
    return {
      'websiteID': websiteId,
      'name': name,
      'algorithm': algorithm,
      'servers': [for (final server in servers) server.toJson()],
    };
  }
}
