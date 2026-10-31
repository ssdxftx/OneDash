class LoginLogDto {
  const LoginLogDto({
    required this.id,
    required this.ip,
    this.address = '',
    this.agent = '',
    required this.status,
    this.message = '',
    required this.createdAt,
  });

  final int id;
  final String ip;
  final String address;
  final String agent;
  final String status;
  final String message;
  final DateTime createdAt;

  factory LoginLogDto.fromJson(Map<String, dynamic> json) {
    return LoginLogDto(
      id: json['id'] as int? ?? 0,
      ip: json['ip'] as String? ?? '',
      address: json['address'] as String? ?? '',
      agent: json['agent'] as String? ?? '',
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
