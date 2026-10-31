/// `/hosts/ssh/search` 响应 DTO（对应 Go `dto.SSHInfo`）。
class SshInfoDto {
  const SshInfoDto({
    required this.autoStart,
    required this.isExist,
    required this.isActive,
    this.message = '',
    this.port = '',
    this.listenAddress = '',
    this.passwordAuthentication = '',
    this.pubkeyAuthentication = '',
    this.permitRootLogin = '',
    this.useDNS = '',
    this.currentUser = '',
  });

  final bool autoStart;
  final bool isExist;
  final bool isActive;
  final String message;
  final String port;
  final String listenAddress;
  final String passwordAuthentication;
  final String pubkeyAuthentication;
  final String permitRootLogin;
  final String useDNS;
  final String currentUser;

  factory SshInfoDto.fromJson(Map<String, dynamic> json) {
    return SshInfoDto(
      autoStart: json['autoStart'] as bool? ?? false,
      isExist: json['isExist'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      port: json['port'] as String? ?? '',
      listenAddress: json['listenAddress'] as String? ?? '',
      passwordAuthentication: json['passwordAuthentication'] as String? ?? '',
      pubkeyAuthentication: json['pubkeyAuthentication'] as String? ?? '',
      permitRootLogin: json['permitRootLogin'] as String? ?? '',
      useDNS: json['useDNS'] as String? ?? '',
      currentUser: json['currentUser'] as String? ?? '',
    );
  }
}
