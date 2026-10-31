import 'package:dio/dio.dart';

import '../../data/dto/common/page_result.dart';
import '../../data/dto/website/website_acme_account_dto.dart';
import '../../data/dto/website/website_create_metadata.dart';
import '../../data/dto/website/website_create_req.dart';
import '../../data/dto/website/website_config_file_dto.dart';
import '../../data/dto/website/website_detail_dto.dart';
import '../../data/dto/website/website_dir_dto.dart';
import '../../data/dto/website/website_index_config_dto.dart';
import '../../data/dto/website/website_limit_config_dto.dart';
import '../../data/dto/website/website_log_dto.dart';
import '../../data/dto/website/website_proxy_dto.dart';
import '../../data/dto/website/website_auth_dto.dart';
import '../../data/dto/website/website_auth_req.dart';
import '../../data/dto/website/website_domain_req.dart';
import '../../data/dto/website/website_dto.dart';
import '../../data/dto/website/website_group_dto.dart';
import '../../data/dto/website/website_search_req.dart';
import '../../data/dto/website/website_ssl_dto.dart';
import '../../data/dto/website/website_leech_dto.dart';
import '../../data/dto/website/website_real_ip_dto.dart';
import '../../data/dto/website/website_cors_dto.dart';
import '../../data/dto/website/website_redirect_dto.dart';
import '../../data/dto/website/website_https_dto.dart';
import '../../data/dto/website/website_update_req.dart';
import '../../data/dto/website/website_resource_dto.dart';
import '../../data/dto/website/openresty_performance_dto.dart';
import '../../data/dto/website/openresty_status_dto.dart';
import '../../data/dto/website/ssl_manage_dtos.dart';

/// 网站管理数据仓库接口。
abstract interface class WebsiteRepository {
  /// 分页查询网站列表
  Future<PageResult<WebsiteDto>> searchWebsites(WebsiteSearchReq req);

  /// 查询网站详情
  Future<WebsiteDetailDto> getWebsite(int id);

  /// 查询 OpenResty 运行状态。
  Future<OpenRestyStatusDto> getOpenRestyStatus();

  /// 获取 OpenResty 性能调整参数
  Future<List<OpenRestyPerformanceItemDto>> getOpenRestyPerformance();

  /// 更新 OpenResty 性能调整参数
  Future<void> updateOpenRestyPerformance(Map<String, String> params);

  /// 查询 OpenResty 主配置文件内容
  Future<WebsiteConfigFileDto> getOpenRestyConfig();

  /// 更新 OpenResty 主配置文件内容
  Future<void> updateOpenRestyConfig(String content);

  /// 查询网站分组
  Future<List<WebsiteGroupDto>> searchWebsiteGroups();

  /// 创建网站分组
  Future<void> createWebsiteGroup(WebsiteGroupDto group);

  /// 更新网站分组（含设为默认）
  Future<void> updateWebsiteGroup(WebsiteGroupDto group);

  /// 删除网站分组
  Future<void> deleteWebsiteGroup(int id);

  /// 查询创建网站所需元数据
  Future<WebsiteCreateMetadata> getCreateMetadata();

  /// 查询 ACME 账号
  Future<List<WebsiteAcmeAccountDto>> searchAcmeAccounts();

  /// 查询指定 ACME 账号下的 SSL 证书
  Future<List<WebsiteSslDto>> listWebsiteSsl(int acmeAccountId);

  /// 创建网站
  Future<void> createWebsite(WebsiteCreateReq req);

  /// 查询网站域名列表
  Future<List<WebsiteDomainDto>> listDomains(int websiteId);

  /// 新增网站域名
  Future<void> addDomains(int websiteId, List<WebsiteDomainReq> domains);

  /// 更新域名 SSL 状态
  Future<void> updateDomainSsl(int domainId, bool ssl);

  /// 删除网站域名
  Future<void> deleteDomain(int domainId);

  /// 查询网站目录配置
  Future<WebsiteDirDto> getWebsiteDir(int websiteId);

  /// 更新运行目录并重载
  Future<void> updateWebsiteSiteDir(int websiteId, String siteDir);

  /// 更新网站运行用户/组权限
  Future<void> updateWebsiteDirPermission(
    int websiteId, {
    required String user,
    required String group,
  });

  /// 查询默认文档配置
  Future<WebsiteIndexConfigDto> getWebsiteIndexConfig(int websiteId);

  /// 更新默认文档列表
  Future<void> updateWebsiteIndexConfig(int websiteId, List<String> indexFiles);

  /// 查询流量限制配置
  Future<WebsiteLimitConfigDto> getWebsiteLimitConfig(int websiteId);

  /// 保存流量限制配置
  Future<void> updateWebsiteLimitConfig(
    int websiteId, {
    required bool enable,
    required int perServerLimit,
    required int perIpLimit,
    required int rateKb,
  });

  /// 查询反向代理配置列表
  Future<List<WebsiteProxyDto>> listWebsiteProxies(int websiteId);

  /// 创建/编辑反向代理配置
  Future<void> updateWebsiteProxy(Map<String, dynamic> payload);

  /// 删除反向代理配置
  Future<void> deleteWebsiteProxy(int websiteId, String name);

  /// 启用/停用反向代理配置
  Future<void> updateWebsiteProxyStatus(
    int websiteId,
    String name,
    String status,
  );

  /// 直接保存反向代理源文内容
  Future<void> updateWebsiteProxyFile(
    int websiteId,
    String name,
    String content,
  );

  /// 查询网站密码访问配置 (全局)
  Future<WebsiteAuthDto> getWebsiteAuth(int websiteId);

  /// 查询网站路径密码访问列表
  Future<List<WebsitePathAuthItemDto>> listWebsitePathAuths(int websiteId);

  /// 更新网站密码访问配置 (全局: 创建、修改、删除、启用、禁用)
  Future<void> updateWebsiteAuth(WebsiteAuthUpdateReq req);

  /// 更新网站路径密码访问配置 (创建、修改、删除)
  Future<void> updateWebsitePathAuth(WebsitePathAuthUpdateReq req);

  /// 查询网站 OpenResty 配置文件内容
  Future<WebsiteConfigFileDto> getWebsiteConfig(int websiteId);

  /// 更新网站 Nginx 配置文件内容并重载
  Future<void> updateWebsiteConfig(int websiteId, String content);

  /// 更新网站基础信息
  Future<void> updateWebsite(WebsiteUpdateReq req);

  /// 读取网站访问/错误日志
  Future<WebsiteLogFileDto> readWebsiteLog(int websiteId, WebsiteLogType type);

  /// 启用、禁用或清空网站日志
  Future<void> operateWebsiteLog(
    int websiteId, {
    required WebsiteLogType type,
    required String operate,
  });

  /// 查询网站防盗链配置
  Future<WebsiteLeechDto> getWebsiteLeech(int websiteId);

  /// 更新网站防盗链配置
  Future<void> updateWebsiteLeech(WebsiteLeechUpdateReq req);

  /// 查询网站真实 IP 配置
  Future<WebsiteRealIpDto> getWebsiteRealIp(int websiteId);

  /// 更新网站真实 IP 配置
  Future<void> updateWebsiteRealIp(WebsiteRealIpDto req);

  /// 查询网站跨域配置
  Future<WebsiteCorsDto> getWebsiteCors(int websiteId);

  /// 更新网站跨域配置
  Future<void> updateWebsiteCors(WebsiteCorsDto req);

  /// 获取伪静态内容
  Future<String> getRewriteContent(int websiteId, String name);

  /// 获取自定义伪静态模板列表
  Future<List<String>> getCustomRewriteTemplates();

  /// 更新伪静态配置
  Future<void> updateRewrite(int websiteId, String name, String content);

  /// 管理自定义伪静态模板
  Future<void> manageCustomRewrite({
    required String name,
    required String operate,
    String? content,
  });

  /// 获取网站重定向规则列表
  Future<List<WebsiteRedirectDto>> getWebsiteRedirects(int websiteId);

  /// 更新网站重定向规则（创建/编辑/开关/删除）
  Future<void> updateWebsiteRedirect(Map<String, dynamic> req);

  /// 保存重定向规则源文件
  Future<void> saveWebsiteRedirectFile(
    int websiteId,
    String name,
    String content,
  );

  /// 获取网站域名列表
  /// 获取网站 HTTPS 配置
  Future<WebsiteHttpsDto> getWebsiteHttps(int websiteId);

  /// 更新网站 HTTPS 配置
  Future<void> updateWebsiteHttps(int websiteId, Map<String, dynamic> req);

  // ===========================================================================
  // SSL 证书管理
  // ===========================================================================

  /// 搜索 SSL 证书
  Future<PageResult<SslManageDto>> searchSsl(Map<String, dynamic> req);

  /// 查询 SSL 证书详情
  Future<SslManageDto> getSsl(int id);

  /// 创建 SSL 证书
  Future<void> createSsl(SslCreateReq req);

  /// 更新 SSL 证书
  Future<void> updateSsl(SslUpdateReq req);

  /// 删除 SSL 证书
  Future<void> deleteSsl(List<int> ids);

  /// 申请/续签 SSL 证书
  Future<void> obtainSsl(int id);

  /// 查询 SSL DNS 解析记录
  Future<List<SslResolveDto>> resolveSsl(int acmeId, int sslId);

  /// 上传 SSL 证书。
  ///
  /// [type] 为 `paste` 时需传 [certificate] 和 [privateKey]；
  /// [type] 为 `local` 时需传 [certificatePath] 和 [privateKeyPath]。
  Future<void> uploadSsl({
    required String type,
    String? certificate,
    String? privateKey,
    String? certificatePath,
    String? privateKeyPath,
    String? description,
    int? domainId,
    int? websiteSSLId,
  });

  /// 通过本地文件上传 SSL 证书（multipart）
  Future<void> uploadSslByFile({
    required String certificatePath,
    required String privateKeyPath,
    String? description,
    int? websiteSSLId,
  });

  /// 下载 SSL 证书
  Future<Response<dynamic>> downloadSsl(int id);

  // ===========================================================================
  // ACME 账号管理
  // ===========================================================================

  /// 搜索 ACME 账号（分页）
  Future<PageResult<WebsiteAcmeAccountDto>> searchAcmeAccountsPaged(
    Map<String, dynamic> req,
  );

  /// 创建 ACME 账号
  Future<void> createAcmeAccount(AcmeAccountCreateReq req);

  /// 更新 ACME 账号
  Future<void> updateAcmeAccount(Map<String, dynamic> req);

  /// 删除 ACME 账号
  Future<void> deleteAcmeAccount(int id);

  // ===========================================================================
  // DNS 账号管理
  // ===========================================================================

  /// 搜索 DNS 账号（分页）
  Future<PageResult<DnsAccountDto>> searchDnsAccounts(Map<String, dynamic> req);

  /// 创建 DNS 账号
  Future<void> createDnsAccount(DnsAccountCreateReq req);

  /// 更新 DNS 账号
  Future<void> updateDnsAccount(Map<String, dynamic> req);

  /// 删除 DNS 账号
  Future<void> deleteDnsAccount(int id);

  // ===========================================================================
  // 自签 CA 管理
  // ===========================================================================

  /// 搜索自签 CA（分页）
  Future<PageResult<CaDto>> searchCaAccounts(Map<String, dynamic> req);

  /// 查询自签 CA 详情
  Future<CaDto> getCaDetail(int id);

  /// 创建自签 CA
  Future<void> createCa(CaCreateReq req);

  /// 用 CA 签发证书
  Future<void> obtainCa(CaObtainReq req);

  /// 续签 CA 证书
  Future<void> renewCa(int sslId);

  /// 删除自签 CA
  Future<void> deleteCa(int id);

  /// 下载 CA 证书
  Future<Response<dynamic>> downloadCa(int id);

  /// 切换网站 PHP 版本（或切换为静态网站）。
  ///
  /// [runtimeID] 为 0 时表示切换为静态网站，其他值表示切换到对应的 PHP 运行环境。
  Future<void> switchPhpVersion(int websiteId, int runtimeId);

  /// 获取网站关联的资源列表。
  Future<List<WebsiteResourceDto>> getWebsiteResources(int websiteId);

  /// 获取可关联的数据库列表。
  Future<List<WebsiteDatabaseDto>> getWebsiteDatabases();

  /// 更换网站关联的数据库。
  Future<void> changeWebsiteDatabase(WebsiteChangeDatabaseReq req);
}
