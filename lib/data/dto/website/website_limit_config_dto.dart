class WebsiteLimitConfigDto {
  const WebsiteLimitConfigDto({
    required this.enable,
    required this.perServerLimit,
    required this.perIpLimit,
    required this.rateKb,
  });

  final bool enable;
  final int? perServerLimit;
  final int? perIpLimit;
  final int? rateKb;

  factory WebsiteLimitConfigDto.fromJson(Map<String, dynamic> json) {
    final rawParams = json['params'];
    int? perServerLimit;
    int? perIpLimit;
    int? rateKb;

    if (rawParams is List) {
      for (final item in rawParams) {
        if (item is! Map<String, dynamic>) continue;
        final name = item['name']?.toString() ?? '';
        final params = item['params'];
        if (params is! List) continue;
        if (name == 'limit_conn') {
          // 兼容两种返回格式：
          // 1) ["perserver", "50"] / ["perip", "3"]
          // 2) ["perserver 50", "perip 3"]
          if (params.length >= 2) {
            final key = params.first.toString().trim().toLowerCase();
            final limit = int.tryParse(params[1].toString().trim());
            if (limit != null) {
              if (key == 'perserver') perServerLimit = limit;
              if (key == 'perip') perIpLimit = limit;
              continue;
            }
          }
          for (final value in params) {
            final text = value?.toString().trim() ?? '';
            if (text.isEmpty) continue;
            final parts = text.split(RegExp(r'\s+'));
            if (parts.length < 2) continue;
            final key = parts[0].toLowerCase();
            final limit = int.tryParse(parts[1]);
            if (limit == null) continue;
            if (key == 'perserver') perServerLimit = limit;
            if (key == 'perip') perIpLimit = limit;
          }
        } else if (name == 'limit_rate' && params.isNotEmpty) {
          final text = params.first?.toString().trim().toLowerCase() ?? '';
          final normalized = text.endsWith('k')
              ? text.substring(0, text.length - 1)
              : text;
          rateKb = int.tryParse(normalized);
        }
      }
    }

    return WebsiteLimitConfigDto(
      enable: json['enable'] as bool? ?? false,
      perServerLimit: perServerLimit,
      perIpLimit: perIpLimit,
      rateKb: rateKb,
    );
  }
}
