class McpServerDto {
  const McpServerDto({
    required this.id,
    required this.name,
    required this.status,
    required this.baseUrl,
    required this.ssePath,
    required this.command,
    required this.port,
    required this.message,
    required this.containerName,
    required this.dir,
    required this.hostIP,
    required this.protocol,
    required this.url,
    required this.outputTransport,
    required this.streamableHttpPath,
    required this.type,
    required this.gatewayImage,
    required this.protocolVersion,
    required this.gatewayArgs,
    required this.environments,
    required this.volumes,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String status;
  final String baseUrl;
  final String ssePath;
  final String command;
  final int port;
  final String message;
  final String containerName;
  final String dir;
  final String hostIP;
  final String protocol;
  final String url;
  final String outputTransport;
  final String streamableHttpPath;
  final String type;
  final String gatewayImage;
  final String protocolVersion;
  final String gatewayArgs;
  final List<Map<String, dynamic>> environments;
  final List<Map<String, dynamic>> volumes;
  final String createdAt;

  factory McpServerDto.fromJson(Map<String, dynamic> json) {
    return McpServerDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      baseUrl: json['baseUrl'] as String? ?? '',
      ssePath: json['ssePath'] as String? ?? '',
      command: json['command'] as String? ?? '',
      port: (json['port'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ?? '',
      containerName: json['containerName'] as String? ?? '',
      dir: json['dir'] as String? ?? '',
      hostIP: json['hostIP'] as String? ?? '',
      protocol: json['protocol'] as String? ?? 'http://',
      url: json['url'] as String? ?? '',
      outputTransport: json['outputTransport'] as String? ?? 'sse',
      streamableHttpPath: json['streamableHttpPath'] as String? ?? '',
      type: json['type'] as String? ?? 'npx',
      gatewayImage: json['gatewayImage'] as String? ?? '',
      protocolVersion: json['protocolVersion'] as String? ?? '',
      gatewayArgs: json['gatewayArgs'] as String? ?? '',
      environments:
          (json['environments'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .toList(growable: false) ??
          const [],
      volumes:
          (json['volumes'] as List?)?.whereType<Map<String, dynamic>>().toList(
            growable: false,
          ) ??
          const [],
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
