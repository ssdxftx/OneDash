/// `/hosts/ssh/log` 请求 DTO（对应 Go `dto.SearchSSHLog`）。
class SshLogSearchReq {
  const SshLogSearchReq({
    required this.page,
    required this.pageSize,
    this.info = '',
    this.status = 'All',
    required this.startTime,
    required this.endTime,
  });

  final int page;
  final int pageSize;
  final String info;
  final String status;
  final DateTime startTime;
  final DateTime endTime;

  Map<String, dynamic> toJson() => {
    'page': page,
    'pageSize': pageSize,
    'info': info,
    'Status': status,
    'startTime': startTime.toUtc().toIso8601String(),
    'endTime': endTime.toUtc().toIso8601String(),
  };
}

/// `/hosts/ssh/log` 响应项（对应 Go `dto.SSHHistory`）。
class SshLogDto {
  const SshLogDto({
    this.date = '',
    this.dateStr = '',
    this.area = '',
    this.user = '',
    this.authMode = '',
    this.address = '',
    this.port = '',
    this.status = '',
    this.message = '',
  });

  final String date;
  final String dateStr;
  final String area;
  final String user;
  final String authMode;
  final String address;
  final String port;
  final String status;
  final String message;

  factory SshLogDto.fromJson(Map<String, dynamic> json) {
    return SshLogDto(
      date: '${json['date'] ?? ''}',
      dateStr: '${json['dateStr'] ?? ''}',
      area: json['area'] as String? ?? '',
      user: json['user'] as String? ?? '',
      authMode: json['authMode'] as String? ?? '',
      address: json['address'] as String? ?? '',
      port: '${json['port'] ?? ''}',
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}
