/// `/hosts/ssh/cert/search` 列表项 DTO（对应 Go `dto.RootCert`）。
class SshCertDto {
  const SshCertDto({
    required this.id,
    required this.name,
    this.encryptionMode = '',
    this.description = '',
    this.passPhrase = '',
    this.publicKey = '',
    this.privateKey = '',
  });

  final int id;
  final String name;
  final String encryptionMode;
  final String description;

  /// Base64 编码的口令。
  final String passPhrase;

  /// Base64 编码的公钥。
  final String publicKey;

  /// Base64 编码的私钥。
  final String privateKey;

  factory SshCertDto.fromJson(Map<String, dynamic> json) {
    return SshCertDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      encryptionMode: json['encryptionMode'] as String? ?? '',
      description: json['description'] as String? ?? '',
      passPhrase: json['passPhrase'] as String? ?? '',
      publicKey: json['publicKey'] as String? ?? '',
      privateKey: json['privateKey'] as String? ?? '',
    );
  }
}

/// `/hosts/ssh/cert` 和 `/hosts/ssh/cert/update` 请求体（对应 Go `dto.RootCertOperate`）。
class SshCertOperateReq {
  SshCertOperateReq({
    this.id,
    required this.name,
    required this.encryptionMode,
    this.mode = '',
    this.passPhrase = '',
    this.publicKey = '',
    this.privateKey = '',
    this.description = '',
  });

  final int? id;
  final String name;
  final String encryptionMode;

  /// `"generate"` / `"input"` / `"import"`，创建时必填。
  final String mode;
  final String passPhrase;
  final String publicKey;
  final String privateKey;
  final String description;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'encryptionMode': encryptionMode,
      if (mode.isNotEmpty) 'mode': mode,
      if (passPhrase.isNotEmpty) 'passPhrase': passPhrase,
      if (publicKey.isNotEmpty) 'publicKey': publicKey,
      if (privateKey.isNotEmpty) 'privateKey': privateKey,
      if (description.isNotEmpty) 'description': description,
    };
  }
}
