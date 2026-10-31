class BackupRecordDto {
  const BackupRecordDto({
    required this.id,
    required this.createdAt,
    required this.accountType,
    required this.accountName,
    required this.downloadAccountID,
    required this.fileDir,
    required this.fileName,
    required this.taskID,
    required this.status,
    required this.message,
    required this.description,
    required this.size,
  });

  final int id;
  final DateTime? createdAt;
  final String accountType;
  final String accountName;
  final int downloadAccountID;
  final String fileDir;
  final String fileName;
  final String taskID;
  final String status;
  final String message;
  final String description;
  final int size;

  String get filePath {
    final dir = fileDir.replaceAll(RegExp(r'/+$'), '');
    if (dir.isEmpty) return fileName;
    return '$dir/$fileName';
  }

  BackupRecordDto copyWith({int? size}) {
    return BackupRecordDto(
      id: id,
      createdAt: createdAt,
      accountType: accountType,
      accountName: accountName,
      downloadAccountID: downloadAccountID,
      fileDir: fileDir,
      fileName: fileName,
      taskID: taskID,
      status: status,
      message: message,
      description: description,
      size: size ?? this.size,
    );
  }

  factory BackupRecordDto.fromJson(Map<String, dynamic> json) {
    return BackupRecordDto(
      id: json['id'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      accountType: json['accountType'] as String? ?? '',
      accountName: json['accountName'] as String? ?? '',
      downloadAccountID: json['downloadAccountID'] as int? ?? 0,
      fileDir: json['fileDir'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      taskID: json['taskID'] as String? ?? '',
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      description: json['description'] as String? ?? '',
      size: 0,
    );
  }
}

class BackupRecordSizeDto {
  const BackupRecordSizeDto({required this.id, required this.size});

  final int id;
  final int size;

  factory BackupRecordSizeDto.fromJson(Map<String, dynamic> json) {
    return BackupRecordSizeDto(
      id: json['id'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
    );
  }
}
