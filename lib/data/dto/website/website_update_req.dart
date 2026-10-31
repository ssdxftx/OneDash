class WebsiteUpdateReq {
  const WebsiteUpdateReq({
    required this.id,
    required this.primaryDomain,
    required this.remark,
    required this.webSiteGroupId,
    required this.ipv6,
    required this.alias,
    required this.favorite,
  });

  final int id;
  final String primaryDomain;
  final String remark;
  final int webSiteGroupId;
  final bool ipv6;
  final String alias;
  final bool favorite;

  Map<String, dynamic> toJson() => {
    'id': id,
    'primaryDomain': primaryDomain,
    'remark': remark,
    'webSiteGroupId': webSiteGroupId,
    'IPV6': ipv6,
    'alias': alias,
    'favorite': favorite,
  };
}
