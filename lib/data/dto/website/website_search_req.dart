/// 网站搜索请求参数
class WebsiteSearchReq {
  const WebsiteSearchReq({
    this.name = '',
    this.order = 'descending',
    this.orderBy = 'createdAt',
    this.page = 1,
    this.pageSize = 20,
    this.type = '',
    this.websiteGroupId = 0,
  });

  final String name;
  final String order;
  final String orderBy;
  final int page;
  final int pageSize;
  final String type;
  final int websiteGroupId;

  Map<String, dynamic> toJson() {
    return {
      if (name.isNotEmpty) 'name': name,
      'order': order,
      'orderBy': orderBy,
      'page': page,
      'pageSize': pageSize,
      if (type.isNotEmpty) 'type': type,
      if (websiteGroupId > 0) 'websiteGroupId': websiteGroupId,
    };
  }
}
