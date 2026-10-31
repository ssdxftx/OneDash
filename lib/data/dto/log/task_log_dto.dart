class TaskLogDto {
  const TaskLogDto({
    required this.id,
    required this.name,
    this.type = '',
    this.operate = '',
    this.logFile = '',
    required this.status,
    this.errorMsg = '',
    this.operationLogID = 0,
    this.resourceID = 0,
    this.currentStep = '',
    required this.endAt,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String type;
  final String operate;
  final String logFile;
  final String status;
  final String errorMsg;
  final int operationLogID;
  final int resourceID;
  final String currentStep;
  final DateTime endAt;
  final DateTime createdAt;

  factory TaskLogDto.fromJson(Map<String, dynamic> json) {
    return TaskLogDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      operate: json['operate'] as String? ?? '',
      logFile: json['logFile'] as String? ?? '',
      status: json['status'] as String? ?? '',
      errorMsg: json['errorMsg'] as String? ?? '',
      operationLogID: (json['operationLogID'] as num?)?.toInt() ?? 0,
      resourceID: (json['resourceID'] as num?)?.toInt() ?? 0,
      currentStep: json['currentStep'] as String? ?? '',
      endAt:
          DateTime.tryParse(json['endAt'] as String? ?? '') ?? DateTime.now(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
