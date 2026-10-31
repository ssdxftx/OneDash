class AppInstalledCheckReq {
  const AppInstalledCheckReq({required this.key, this.name = ''});

  final String key;
  final String name;

  Map<String, dynamic> toJson() {
    return {'key': key, 'name': name};
  }
}
