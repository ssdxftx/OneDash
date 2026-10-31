class WebsiteRealIpDto {
  const WebsiteRealIpDto({
    required this.websiteID,
    this.open = false,
    this.ipFrom = '',
    this.ipHeader = '',
    this.ipOther = '',
  });

  final int websiteID;
  final bool open;
  final String ipFrom;
  final String ipHeader;
  final String ipOther;

  factory WebsiteRealIpDto.fromJson(Map<String, dynamic> json) {
    return WebsiteRealIpDto(
      websiteID: json['websiteID'] as int? ?? 0,
      open: json['open'] as bool? ?? false,
      ipFrom: json['ipFrom'] as String? ?? '',
      ipHeader: json['ipHeader'] as String? ?? '',
      ipOther: json['ipOther'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'websiteID': websiteID,
      'open': open,
      'ipFrom': ipFrom,
      'ipHeader': ipHeader,
      'ipOther': ipOther,
    };
  }
}
