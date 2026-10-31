class WebsiteDomainReq {
  const WebsiteDomainReq({
    required this.domain,
    this.host,
    this.port = 80,
    this.ssl = false,
  });

  final String domain;
  final String? host;
  final int port;
  final bool ssl;

  Map<String, dynamic> toJson() {
    return {
      'domain': domain,
      if (host != null && host!.isNotEmpty) 'host': host,
      'port': port,
      'ssl': ssl,
    };
  }
}
