import '../../../../data/dto/log/login_log_dto.dart';

/// 登录日志的视图模型。
class LoginLogItem {
  const LoginLogItem({
    required this.id,
    required this.ip,
    required this.address,
    required this.agent,
    required this.status,
    required this.message,
    required this.createdAt,
  });

  final int id;
  final String ip;
  final String address;
  final String agent;
  final String status;
  final String message;
  final DateTime createdAt;

  factory LoginLogItem.fromDto(LoginLogDto dto) => LoginLogItem(
    id: dto.id,
    ip: dto.ip,
    address: dto.address,
    agent: dto.agent,
    status: dto.status,
    message: dto.message,
    createdAt: dto.createdAt,
  );

  bool get isSuccess => status.toLowerCase() == 'success';
  bool get hasLocation => address.trim().isNotEmpty;
  bool get hasDevice => agent.trim().isNotEmpty;
  String get deviceLabel => formatAgent(agent);

  /// 原始 UA → 可读设备名。
  static String formatAgent(String agent) {
    final value = agent.trim();
    if (value.isEmpty) return '';
    if (value.contains('Macintosh')) return 'macOS';
    if (value.contains('Windows')) return 'Windows';
    if (value.contains('iPhone')) return 'iPhone';
    if (value.contains('Android')) return 'Android';
    if (value.contains('Postman')) return 'Postman';
    if (value.contains('Linux')) return 'Linux';
    final match = RegExp(r'\(([^)]+)\)').firstMatch(value);
    if (match != null) return match.group(1)!.split(';').first.trim();
    return value;
  }
}
