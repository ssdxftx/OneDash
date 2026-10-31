class OperationLogDto {
  const OperationLogDto({
    required this.id,
    required this.source,
    this.node = '',
    this.ip = '',
    this.path = '',
    this.method = '',
    this.userAgent = '',
    this.latency = 0,
    required this.status,
    this.message = '',
    this.detailZH = '',
    this.detailEN = '',
    required this.createdAt,
  });

  final int id;
  final String source;
  final String node;
  final String ip;
  final String path;
  final String method;
  final String userAgent;
  final int latency;
  final String status;
  final String message;
  final String detailZH;
  final String detailEN;
  final DateTime createdAt;

  factory OperationLogDto.fromJson(Map<String, dynamic> json) {
    return OperationLogDto(
      id: json['id'] as int? ?? 0,
      source: json['source'] as String? ?? '',
      node: json['node'] as String? ?? '',
      ip: json['ip'] as String? ?? '',
      path: json['path'] as String? ?? '',
      method: json['method'] as String? ?? '',
      userAgent: json['userAgent'] as String? ?? '',
      latency: (json['latency'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      detailZH: json['detailZH'] as String? ?? '',
      detailEN: json['detailEN'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
