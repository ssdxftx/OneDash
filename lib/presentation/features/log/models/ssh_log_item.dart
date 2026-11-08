import '../../../../data/dto/log/ssh_log_dto.dart';

/// SSH 登录日志的视图模型。
class SshLogItem {
  const SshLogItem({
    required this.date,
    required this.dateStr,
    required this.area,
    required this.user,
    required this.authMode,
    required this.address,
    required this.port,
    required this.status,
    required this.message,
  });

  final DateTime date;
  final String dateStr;
  final String area;
  final String user;
  final String authMode;
  final String address;
  final String port;
  final String status;
  final String message;

  factory SshLogItem.fromDto(SshLogDto dto) => SshLogItem(
    date: dto.date,
    dateStr: dto.dateStr,
    area: dto.area,
    user: dto.user,
    authMode: dto.authMode,
    address: dto.address,
    port: dto.port,
    status: dto.status,
    message: dto.message,
  );

  bool get isSuccess => status.toLowerCase() == 'success';
  bool get hasArea => area.trim().isNotEmpty;
  String get title => address.isEmpty ? user : '$user@$address';
}
