class AppStoreConfigDto {
  const AppStoreConfigDto({
    required this.uninstallDeleteImage,
    required this.upgradeBackup,
    required this.uninstallDeleteBackup,
    required this.installAllowPort,
  });

  final bool uninstallDeleteImage;
  final bool upgradeBackup;
  final bool uninstallDeleteBackup;
  final bool installAllowPort;

  factory AppStoreConfigDto.fromJson(Map<String, dynamic> json) {
    return AppStoreConfigDto(
      uninstallDeleteImage: json['uninstallDeleteImage'] == 'Enable',
      upgradeBackup: json['upgradeBackup'] == 'Enable',
      uninstallDeleteBackup: json['uninstallDeleteBackup'] == 'Enable',
      installAllowPort: json['installAllowPort'] == 'Enable',
    );
  }
}
