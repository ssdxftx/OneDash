class AppInstallConfigDto {
  const AppInstallConfigDto({
    required this.id,
    required this.appId,
    required this.version,
    required this.dockerCompose,
    required this.params,
    this.image,
  });

  final int id;
  final int appId;
  final String version;
  final String dockerCompose;
  final AppInstallParamsDto params;
  final String? image;

  factory AppInstallConfigDto.fromJson(Map<String, dynamic> json) {
    return AppInstallConfigDto(
      id: json['id'] as int? ?? 0,
      appId: json['appId'] as int? ?? 0,
      version: json['version'] as String? ?? '',
      dockerCompose: json['dockerCompose'] as String? ?? '',
      params: AppInstallParamsDto.fromJson(
        json['params'] as Map<String, dynamic>? ?? const {},
      ),
      image: json['image'] as String?,
    );
  }
}

class AppInstallParamsDto {
  const AppInstallParamsDto({required this.formFields});

  final List<AppInstallFieldDto> formFields;

  factory AppInstallParamsDto.fromJson(Map<String, dynamic> json) {
    final rawFields = json['formFields'] as List?;
    return AppInstallParamsDto(
      formFields:
          rawFields
              ?.map(
                (e) => AppInstallFieldDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }
}

class AppInstallFieldDto {
  const AppInstallFieldDto({
    required this.defaultValue,
    required this.edit,
    required this.envKey,
    required this.labelZh,
    required this.labelEn,
    required this.required,
    required this.type,
    this.rule,
    this.values,
    this.multiple,
    this.allowCreate,
  });

  final dynamic defaultValue;
  final bool edit;
  final String envKey;
  final String labelZh;
  final String labelEn;
  final bool required;
  final String type;
  final String? rule;
  final List<AppInstallFieldValue>? values;
  final bool? multiple;
  final bool? allowCreate;

  String get label => labelZh.isNotEmpty ? labelZh : labelEn;

  factory AppInstallFieldDto.fromJson(Map<String, dynamic> json) {
    final rawValues = json['values'] as List?;
    return AppInstallFieldDto(
      defaultValue: json['default'],
      edit: json['edit'] as bool? ?? true,
      envKey: json['envKey'] as String? ?? '',
      labelZh: json['labelZh'] as String? ?? '',
      labelEn: json['labelEn'] as String? ?? '',
      required: json['required'] as bool? ?? false,
      type: json['type'] as String? ?? 'text',
      rule: json['rule'] as String?,
      values: rawValues
          ?.whereType<Map<String, dynamic>>()
          .map(AppInstallFieldValue.fromJson)
          .toList(),
      multiple: json['multiple'] as bool?,
      allowCreate: json['allowCreate'] as bool?,
    );
  }
}

class AppInstallFieldValue {
  const AppInstallFieldValue({required this.label, required this.value});

  final String label;
  final String value;

  factory AppInstallFieldValue.fromJson(Map<String, dynamic> json) {
    return AppInstallFieldValue(
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }
}
