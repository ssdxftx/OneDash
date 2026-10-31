class BackupRecordSearchReq {
  const BackupRecordSearchReq({
    required this.page,
    required this.pageSize,
    required this.type,
    required this.name,
    required this.detailName,
  });

  final int page;
  final int pageSize;
  final String type;
  final String name;
  final String detailName;

  Map<String, dynamic> toJson() => {
    'page': page,
    'pageSize': pageSize,
    'type': type,
    'name': name,
    'detailName': detailName,
  };
}
