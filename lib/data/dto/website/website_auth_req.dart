class WebsiteAuthUpdateReq {
  const WebsiteAuthUpdateReq({
    required this.websiteId,
    required this.operate,
    this.username = '',
    this.password = '',
    this.remark = '',
    this.scope = 'root',
  });

  final int websiteId;
  final String operate; // create, edit, delete, enable, disable
  final String username;
  final String password;
  final String remark;
  final String scope;

  Map<String, dynamic> toJson() => {
    'websiteID': websiteId,
    'operate': operate,
    'username': username,
    'password': password,
    'remark': remark,
    'scope': scope,
  };
}

class WebsitePathAuthUpdateReq {
  const WebsitePathAuthUpdateReq({
    required this.websiteId,
    required this.path,
    required this.name,
    required this.username,
    required this.password,
    required this.operate,
    this.remark = '',
  });

  final int websiteId;
  final String path;
  final String name;
  final String username;
  final String password;
  final String operate; // create, edit, delete
  final String remark;

  Map<String, dynamic> toJson() => {
    'websiteID': websiteId,
    'path': path,
    'name': name,
    'username': username,
    'password': password,
    'operate': operate,
    'remark': remark,
  };
}
