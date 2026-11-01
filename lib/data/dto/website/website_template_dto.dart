import 'dart:convert';

/// `/websites/templates/search` 列表项。
class WebsiteTemplateDto {
  const WebsiteTemplateDto({
    this.id = 0,
    this.name = '',
    this.type = 'single',
    this.content = '',
    this.filePath = '',
    this.variables = '',
    this.remark = '',
    this.createdAt = '',
  });

  final int id;
  final String name;
  final String type;
  final String content;
  final String filePath;
  final String variables;
  final String remark;
  final String createdAt;

  bool get isSingle => type == 'single';

  List<WebsiteTemplateVariableDto> get parsedVariables {
    if (variables.trim().isEmpty) return const [];
    try {
      final data = jsonDecode(variables);
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map(
            (row) => WebsiteTemplateVariableDto.fromJson(
              row.cast<String, dynamic>(),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  factory WebsiteTemplateDto.fromJson(Map<String, dynamic> json) {
    return WebsiteTemplateDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'single',
      content: json['content'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      variables: json['variables'] as String? ?? '',
      remark: json['remark'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

/// 模板变量定义。
class WebsiteTemplateVariableDto {
  const WebsiteTemplateVariableDto({
    this.key = '',
    this.label = '',
    this.type = 'text',
    this.defaultValue = '',
    this.options = '',
    this.required = false,
  });

  final String key;
  final String label;
  final String type;
  final String defaultValue;
  final String options;
  final bool required;

  factory WebsiteTemplateVariableDto.fromJson(Map<String, dynamic> json) {
    return WebsiteTemplateVariableDto(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      defaultValue: json['default'] as String? ?? '',
      options: json['options'] as String? ?? '',
      required: json['required'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'type': type,
      'default': defaultValue,
      'options': options,
      'required': required,
    };
  }
}

/// `/websites/templates` 与 `/websites/templates/update` 请求体。
class WebsiteTemplateReq {
  const WebsiteTemplateReq({
    this.id,
    required this.name,
    required this.type,
    this.content = '',
    this.filePath = '',
    this.variables = const [],
    this.remark = '',
  });

  final int? id;
  final String name;
  final String type;
  final String content;
  final String filePath;
  final List<WebsiteTemplateVariableDto> variables;
  final String remark;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      'content': content,
      'filePath': filePath,
      'variables': jsonEncode([
        for (final variable in variables) variable.toJson(),
      ]),
      'remark': remark,
    };
  }
}

/// `/websites/templates/outputs/search` 列表项。
class WebsiteTemplateOutputDto {
  const WebsiteTemplateOutputDto({
    this.id = 0,
    this.name = '',
    this.templateID = 0,
    this.templateName = '',
    this.templateType = '',
    this.variableValues = '',
    this.outputPath = '',
    this.createdAt = '',
  });

  final int id;
  final String name;
  final int templateID;
  final String templateName;
  final String templateType;
  final String variableValues;
  final String outputPath;
  final String createdAt;

  factory WebsiteTemplateOutputDto.fromJson(Map<String, dynamic> json) {
    return WebsiteTemplateOutputDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      templateID: (json['templateID'] as num?)?.toInt() ?? 0,
      templateName: json['templateName'] as String? ?? '',
      templateType: json['templateType'] as String? ?? '',
      variableValues: json['variableValues'] as String? ?? '',
      outputPath: json['outputPath'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
