import '../../../../data/dto/log/task_log_dto.dart';

/// 任务日志列表的视图模型，保留 taskID 供详情弹层读取日志全文。
class TaskLogItem {
  const TaskLogItem({
    required this.id,
    required this.name,
    required this.operate,
    required this.status,
    required this.errorMsg,
    required this.currentStep,
    required this.createdAt,
    required this.endAt,
  });

  final String id;
  final String name;
  final String operate;
  final String status;
  final String errorMsg;
  final String currentStep;
  final DateTime createdAt;
  final DateTime endAt;

  factory TaskLogItem.fromDto(TaskLogDto dto) => TaskLogItem(
    id: dto.id,
    name: dto.name,
    operate: dto.operate,
    status: dto.status,
    errorMsg: dto.errorMsg,
    currentStep: dto.currentStep,
    createdAt: dto.createdAt,
    endAt: dto.endAt,
  );

  bool get isSuccess => status.toLowerCase() == 'success';
  bool get isExecuting => status.toLowerCase() == 'executing';

  String get subtitle =>
      isExecuting && currentStep.trim().isNotEmpty ? currentStep : operate;
}
