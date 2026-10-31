class SshLogDto {
  const SshLogDto({
    required this.date,
    this.dateStr = '',
    this.area = '',
    this.user = '',
    this.authMode = '',
    this.address = '',
    this.port = '',
    required this.status,
    this.message = '',
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

  factory SshLogDto.fromJson(Map<String, dynamic> json) {
    return SshLogDto(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      dateStr: json['dateStr'] as String? ?? '',
      area: json['area'] as String? ?? '',
      user: json['user'] as String? ?? '',
      authMode: json['authMode'] as String? ?? '',
      address: json['address'] as String? ?? '',
      port: json['port'] as String? ?? '',
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}
