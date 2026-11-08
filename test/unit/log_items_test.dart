import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/data/dto/log/operation_log_dto.dart';
import 'package:onedash/presentation/features/log/models/login_log_item.dart';
import 'package:onedash/presentation/features/log/models/operation_log_item.dart';

void main() {
  OperationLogDto operation({String zh = '', String en = ''}) =>
      OperationLogDto(
        id: 1,
        source: 'websites',
        method: 'post',
        path: '/websites/php/version',
        status: 'Success',
        detailZH: zh,
        detailEN: en,
        createdAt: DateTime(2026, 11, 8, 15, 31, 1),
      );

  test('操作日志标题优先 detailZH', () {
    expect(
      OperationLogItem.fromDto(operation(zh: 'php 版本变更')).title,
      'php 版本变更',
    );
  });

  test('detailZH 为空时回退 detailEN', () {
    expect(
      OperationLogItem.fromDto(operation(en: 'Change PHP version')).title,
      'Change PHP version',
    );
  });

  test('两个 detail 都为空时回退 METHOD PATH', () {
    expect(
      OperationLogItem.fromDto(operation()).title,
      'POST /websites/php/version',
    );
  });

  test('设备名格式化保持 Mono 五个分支并兜底 Linux', () {
    expect(
      LoginLogItem.formatAgent('Mozilla/5.0 (Macintosh; Intel Mac OS X)'),
      'macOS',
    );
    expect(
      LoginLogItem.formatAgent('Mozilla/5.0 (Windows NT 10.0)'),
      'Windows',
    );
    expect(
      LoginLogItem.formatAgent('Mozilla/5.0 (iPhone; CPU iPhone OS)'),
      'iPhone',
    );
    expect(
      LoginLogItem.formatAgent('Mozilla/5.0 (Linux; Android 14)'),
      'Android',
    );
    expect(LoginLogItem.formatAgent('PostmanRuntime/7.36'), 'Postman');
    expect(
      LoginLogItem.formatAgent('Mozilla/5.0 (X11; Linux x86_64)'),
      'Linux',
    );
    expect(LoginLogItem.formatAgent('Mozilla/5.0 (X11; FreeBSD)'), 'X11');
  });
}
