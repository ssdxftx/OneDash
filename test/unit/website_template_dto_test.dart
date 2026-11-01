import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/data/dto/website/website_template_dto.dart';

void main() {
  test('template DTO parses variables and request field names', () {
    final dto = WebsiteTemplateDto.fromJson({
      'id': 3,
      'name': 'landing',
      'type': 'single',
      'content': '<h1>{{title}}</h1>',
      'variables': jsonEncode([
        {
          'key': 'title',
          'label': 'Title',
          'type': 'text',
          'default': 'Hello',
          'options': '',
          'required': true,
        },
      ]),
    });

    expect(dto.id, 3);
    expect(dto.isSingle, isTrue);
    expect(dto.parsedVariables.single.key, 'title');
    expect(dto.parsedVariables.single.required, isTrue);

    final req = WebsiteTemplateReq(
      id: dto.id,
      name: dto.name,
      type: dto.type,
      content: dto.content,
      variables: dto.parsedVariables,
    );
    final json = req.toJson();
    expect(json['id'], 3);
    expect(json['name'], 'landing');
    expect(json['type'], 'single');
    expect(jsonDecode(json['variables'] as String), [
      {
        'key': 'title',
        'label': 'Title',
        'type': 'text',
        'default': 'Hello',
        'options': '',
        'required': true,
      },
    ]);
  });

  test('template DTO tolerates malformed variables and null fields', () {
    final dto = WebsiteTemplateDto.fromJson({
      'name': 'broken',
      'variables': '{not json',
    });
    final empty = WebsiteTemplateDto.fromJson({});

    expect(dto.parsedVariables, isEmpty);
    expect(empty.name, isEmpty);
    expect(empty.type, 'single');
  });

  test('template output DTO parses generated path', () {
    final dto = WebsiteTemplateOutputDto.fromJson({
      'id': 9,
      'name': 'site',
      'templateID': 3,
      'templateName': 'landing',
      'outputPath': '/opt/1panel/www/sites/site',
    });

    expect(dto.id, 9);
    expect(dto.templateID, 3);
    expect(dto.outputPath, '/opt/1panel/www/sites/site');
  });
}
