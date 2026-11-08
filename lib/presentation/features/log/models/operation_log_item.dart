import '../../../../data/dto/log/operation_log_dto.dart';

/// 操作日志的视图模型，保留 DTO 全字段。
class OperationLogItem {
  const OperationLogItem({
    required this.id,
    required this.source,
    required this.method,
    required this.path,
    required this.status,
    required this.message,
    required this.detailZH,
    required this.detailEN,
    required this.createdAt,
  });

  final int id;
  final String source;
  final String method;
  final String path;
  final String status;
  final String message;
  final String detailZH;
  final String detailEN;
  final DateTime createdAt;

  factory OperationLogItem.fromDto(OperationLogDto dto) => OperationLogItem(
    id: dto.id,
    source: dto.source,
    method: dto.method,
    path: dto.path,
    status: dto.status,
    message: dto.message,
    detailZH: dto.detailZH,
    detailEN: dto.detailEN,
    createdAt: dto.createdAt,
  );

  /// 标题三级回退：中文动作名 → 英文动作名 → HTTP 方法 + 路径。
  String get title => '${method.toUpperCase()} $path';

  bool get isSuccess => status.toLowerCase() == 'success';
}
