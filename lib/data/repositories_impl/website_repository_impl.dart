import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/website_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/file_api.dart';
import '../api/group_api.dart';
import '../api/website_api.dart';
import '../dto/common/page_result.dart';
import '../dto/cronjob/cronjob_form_data_dto.dart';
import '../dto/website/website_acme_account_dto.dart';
import '../dto/website/website_create_metadata.dart';
import '../dto/website/website_create_req.dart';
import '../dto/website/website_config_file_dto.dart';
import '../dto/website/website_detail_dto.dart';
import '../dto/website/website_dir_dto.dart';
import '../dto/website/website_index_config_dto.dart';
import '../dto/website/website_limit_config_dto.dart';
import '../dto/website/website_load_balance_dto.dart';
import '../dto/website/website_log_dto.dart';
import '../dto/website/website_proxy_dto.dart';
import '../dto/website/website_auth_dto.dart';
import '../dto/website/website_auth_req.dart';
import '../dto/website/website_domain_req.dart';
import '../dto/website/website_dto.dart';
import '../dto/website/website_group_dto.dart';
import '../dto/website/website_search_req.dart';
import '../dto/website/website_ssl_dto.dart';
import '../dto/website/website_template_dto.dart';
import '../dto/website/website_leech_dto.dart';
import '../dto/website/website_real_ip_dto.dart';
import '../dto/website/website_cors_dto.dart';
import '../dto/website/website_redirect_dto.dart';
import '../dto/website/website_https_dto.dart';
import '../dto/website/website_update_req.dart';
import '../dto/website/website_resource_dto.dart';
import '../dto/website/openresty_performance_dto.dart';
import '../dto/website/openresty_status_dto.dart';
import '../dto/website/ssl_manage_dtos.dart';

part 'website_repository_impl.g.dart';

/// [WebsiteRepository] 的默认实现。
class WebsiteRepositoryImpl implements WebsiteRepository {
  WebsiteRepositoryImpl(this._websiteApi, this._fileApi, this._groupApi);

  final WebsiteApi _websiteApi;
  final FileApi _fileApi;
  final GroupApi _groupApi;

  @override
  Future<PageResult<WebsiteDto>> searchWebsites(WebsiteSearchReq req) =>
      _websiteApi.searchWebsites(req);

  @override
  Future<WebsiteDetailDto> getWebsite(int id) => _websiteApi.getWebsite(id);

  @override
  Future<List<WebsiteOptionDto>> getWebsiteOptions() =>
      _websiteApi.getWebsiteOptions();

  @override
  Future<OpenRestyStatusDto> getOpenRestyStatus() =>
      _websiteApi.getOpenRestyStatus();

  @override
  Future<List<OpenRestyPerformanceItemDto>> getOpenRestyPerformance() =>
      _websiteApi.getOpenRestyPerformance();

  @override
  Future<void> updateOpenRestyPerformance(Map<String, String> params) =>
      _websiteApi.updateOpenRestyPerformance(params);

  @override
  Future<WebsiteConfigFileDto> getOpenRestyConfig() =>
      _websiteApi.getOpenRestyConfig();

  @override
  Future<void> updateOpenRestyConfig(String content) =>
      _websiteApi.updateOpenRestyConfig(content);

  @override
  Future<List<WebsiteGroupDto>> searchWebsiteGroups() =>
      _groupApi.searchGroups(type: 'website');

  @override
  Future<void> createWebsiteGroup(WebsiteGroupDto group) =>
      _groupApi.createGroup(group);

  @override
  Future<void> updateWebsiteGroup(WebsiteGroupDto group) =>
      _groupApi.updateGroup(group);

  @override
  Future<void> deleteWebsiteGroup(int id) => _groupApi.deleteGroup(id);

  @override
  Future<WebsiteCreateMetadata> getCreateMetadata() async {
    final rootDir = await _fileApi.getWebsiteRootDir();
    final groups = await _groupApi.searchGroups(type: 'website');
    return WebsiteCreateMetadata(websiteRootDir: rootDir, groups: groups);
  }

  @override
  Future<List<WebsiteAcmeAccountDto>> searchAcmeAccounts() async {
    final accounts = await _websiteApi.searchAcmeAccounts();
    return [const WebsiteAcmeAccountDto.manual(), ...accounts];
  }

  @override
  Future<List<WebsiteSslDto>> listWebsiteSsl(int acmeAccountId) =>
      _websiteApi.listWebsiteSsl(acmeAccountId);

  @override
  Future<void> createWebsite(WebsiteCreateReq req) =>
      _websiteApi.createWebsite(req);

  @override
  Future<void> operateWebsite(int id, String operate) =>
      _websiteApi.operateWebsite(id, operate);

  @override
  Future<void> deleteWebsite(
    int id, {
    bool deleteApp = false,
    bool deleteBackup = false,
    bool forceDelete = false,
    bool deleteDB = false,
  }) => _websiteApi.deleteWebsite(
    id,
    deleteApp: deleteApp,
    deleteBackup: deleteBackup,
    forceDelete: forceDelete,
    deleteDB: deleteDB,
  );

  @override
  Future<List<WebsiteDomainDto>> listDomains(int websiteId) =>
      _websiteApi.listDomains(websiteId);

  @override
  Future<void> addDomains(int websiteId, List<WebsiteDomainReq> domains) =>
      _websiteApi.addDomains(websiteId, domains);

  @override
  Future<void> updateDomainSsl(int domainId, bool ssl) =>
      _websiteApi.updateDomainSsl(domainId, ssl);

  @override
  Future<void> deleteDomain(int domainId) => _websiteApi.deleteDomain(domainId);

  @override
  Future<WebsiteDirDto> getWebsiteDir(int websiteId) =>
      _websiteApi.getWebsiteDir(websiteId);

  @override
  Future<void> updateWebsiteSiteDir(int websiteId, String siteDir) =>
      _websiteApi.updateWebsiteSiteDir(websiteId, siteDir);

  @override
  Future<void> updateWebsiteDirPermission(
    int websiteId, {
    required String user,
    required String group,
  }) => _websiteApi.updateWebsiteDirPermission(
    websiteId,
    user: user,
    group: group,
  );

  @override
  Future<WebsiteIndexConfigDto> getWebsiteIndexConfig(int websiteId) =>
      _websiteApi.getWebsiteIndexConfig(websiteId);

  @override
  Future<void> updateWebsiteIndexConfig(
    int websiteId,
    List<String> indexFiles,
  ) => _websiteApi.updateWebsiteIndexConfig(websiteId, indexFiles);

  @override
  Future<WebsiteLimitConfigDto> getWebsiteLimitConfig(int websiteId) =>
      _websiteApi.getWebsiteLimitConfig(websiteId);

  @override
  Future<void> updateWebsiteLimitConfig(
    int websiteId, {
    required bool enable,
    required int perServerLimit,
    required int perIpLimit,
    required int rateKb,
  }) => _websiteApi.updateWebsiteLimitConfig(
    websiteId,
    enable: enable,
    perServerLimit: perServerLimit,
    perIpLimit: perIpLimit,
    rateKb: rateKb,
  );

  @override
  Future<List<WebsiteProxyDto>> listWebsiteProxies(int websiteId) =>
      _websiteApi.listWebsiteProxies(websiteId);

  @override
  Future<void> updateWebsiteProxy(Map<String, dynamic> payload) =>
      _websiteApi.updateWebsiteProxy(payload);

  @override
  Future<void> deleteWebsiteProxy(int websiteId, String name) =>
      _websiteApi.deleteWebsiteProxy(websiteId, name);

  @override
  Future<void> updateWebsiteProxyStatus(
    int websiteId,
    String name,
    String status,
  ) => _websiteApi.updateWebsiteProxyStatus(websiteId, name, status);

  @override
  Future<void> updateWebsiteProxyFile(
    int websiteId,
    String name,
    String content,
  ) => _websiteApi.updateWebsiteProxyFile(websiteId, name, content);

  @override
  Future<PageResult<WebsiteTemplateDto>> searchTemplates({
    int page = 1,
    int pageSize = 100,
    String name = '',
    String type = '',
  }) => _websiteApi.searchTemplates(
    page: page,
    pageSize: pageSize,
    name: name,
    type: type,
  );

  @override
  Future<WebsiteTemplateDto> getTemplate(int id) => _websiteApi.getTemplate(id);

  @override
  Future<void> createTemplate(WebsiteTemplateReq req) =>
      _websiteApi.createTemplate(req);

  @override
  Future<void> updateTemplate(WebsiteTemplateReq req) =>
      _websiteApi.updateTemplate(req);

  @override
  Future<void> deleteTemplate(int id) => _websiteApi.deleteTemplate(id);

  @override
  Future<Map<String, dynamic>> uploadTemplateZip({
    required String fileName,
    required List<int> bytes,
  }) => _websiteApi.uploadTemplateZip(fileName: fileName, bytes: bytes);

  @override
  Future<PageResult<WebsiteTemplateOutputDto>> searchTemplateOutputs({
    int page = 1,
    int pageSize = 100,
    int templateID = 0,
  }) => _websiteApi.searchTemplateOutputs(
    page: page,
    pageSize: pageSize,
    templateID: templateID,
  );

  @override
  Future<void> createTemplateOutput({
    required int templateID,
    required String name,
    required Map<String, String> variableValues,
  }) => _websiteApi.createTemplateOutput(
    templateID: templateID,
    name: name,
    variableValues: variableValues,
  );

  @override
  Future<void> deleteTemplateOutput(int id) =>
      _websiteApi.deleteTemplateOutput(id);

  @override
  Future<List<WebsiteLoadBalanceDto>> listLoadBalances(int websiteId) =>
      _websiteApi.listLoadBalances(websiteId);

  @override
  Future<void> createLoadBalance(WebsiteLoadBalanceReq req) =>
      _websiteApi.createLoadBalance(req);

  @override
  Future<void> updateLoadBalance(WebsiteLoadBalanceReq req) =>
      _websiteApi.updateLoadBalance(req);

  @override
  Future<void> deleteLoadBalance(int websiteId, String name) =>
      _websiteApi.deleteLoadBalance(websiteId, name);

  @override
  Future<WebsiteAuthDto> getWebsiteAuth(int websiteId) =>
      _websiteApi.getWebsiteAuth(websiteId);

  @override
  Future<List<WebsitePathAuthItemDto>> listWebsitePathAuths(int websiteId) =>
      _websiteApi.listWebsitePathAuths(websiteId);

  @override
  Future<void> updateWebsiteAuth(WebsiteAuthUpdateReq req) =>
      _websiteApi.updateWebsiteAuth(req);

  @override
  Future<void> updateWebsitePathAuth(WebsitePathAuthUpdateReq req) =>
      _websiteApi.updateWebsitePathAuth(req);

  @override
  Future<WebsiteConfigFileDto> getWebsiteConfig(int websiteId) =>
      _websiteApi.getWebsiteConfig(websiteId);

  @override
  Future<void> updateWebsiteConfig(int websiteId, String content) =>
      _websiteApi.updateWebsiteConfig(websiteId, content);

  @override
  Future<void> updateWebsite(WebsiteUpdateReq req) =>
      _websiteApi.updateWebsite(req);

  @override
  Future<WebsiteLogFileDto> readWebsiteLog(
    int websiteId,
    WebsiteLogType type,
  ) => _fileApi.readFile<WebsiteLogFileDto>(
    id: websiteId,
    type: 'website',
    name: type.fileName,
    fromJson: WebsiteLogFileDto.fromJson,
  );

  @override
  Future<void> operateWebsiteLog(
    int websiteId, {
    required WebsiteLogType type,
    required String operate,
  }) => _websiteApi.operateWebsiteLog(websiteId, type: type, operate: operate);

  @override
  Future<WebsiteLeechDto> getWebsiteLeech(int websiteId) =>
      _websiteApi.getWebsiteLeech(websiteId);

  @override
  Future<void> updateWebsiteLeech(WebsiteLeechUpdateReq req) =>
      _websiteApi.updateWebsiteLeech(req);

  @override
  Future<WebsiteRealIpDto> getWebsiteRealIp(int websiteId) =>
      _websiteApi.getWebsiteRealIp(websiteId);

  @override
  Future<void> updateWebsiteRealIp(WebsiteRealIpDto req) =>
      _websiteApi.updateWebsiteRealIp(req);

  @override
  Future<WebsiteCorsDto> getWebsiteCors(int websiteId) =>
      _websiteApi.getWebsiteCors(websiteId);

  @override
  Future<void> updateWebsiteCors(WebsiteCorsDto req) =>
      _websiteApi.updateWebsiteCors(req);

  @override
  Future<String> getRewriteContent(int websiteId, String name) =>
      _websiteApi.getRewriteContent(websiteId, name);

  @override
  Future<List<String>> getCustomRewriteTemplates() =>
      _websiteApi.getCustomRewriteTemplates();

  @override
  Future<void> updateRewrite(int websiteId, String name, String content) =>
      _websiteApi.updateRewrite(websiteId, name, content);

  @override
  Future<void> manageCustomRewrite({
    required String name,
    required String operate,
    String? content,
  }) => _websiteApi.manageCustomRewrite(
    name: name,
    operate: operate,
    content: content,
  );

  @override
  Future<List<WebsiteRedirectDto>> getWebsiteRedirects(int websiteId) =>
      _websiteApi.getWebsiteRedirects(websiteId);

  @override
  Future<void> updateWebsiteRedirect(Map<String, dynamic> req) =>
      _websiteApi.updateWebsiteRedirect(req);

  @override
  Future<void> saveWebsiteRedirectFile(
    int websiteId,
    String name,
    String content,
  ) => _websiteApi.saveWebsiteRedirectFile(websiteId, name, content);

  @override
  Future<WebsiteHttpsDto> getWebsiteHttps(int websiteId) =>
      _websiteApi.getWebsiteHttps(websiteId);

  @override
  Future<void> updateWebsiteHttps(int websiteId, Map<String, dynamic> req) =>
      _websiteApi.updateWebsiteHttps(websiteId, req);

  // ===========================================================================
  // SSL 证书管理
  // ===========================================================================

  @override
  Future<PageResult<SslManageDto>> searchSsl(Map<String, dynamic> req) =>
      _websiteApi.searchSsl(req);

  @override
  Future<SslManageDto> getSsl(int id) => _websiteApi.getSsl(id);

  @override
  Future<void> createSsl(SslCreateReq req) => _websiteApi.createSsl(req);

  @override
  Future<void> updateSsl(SslUpdateReq req) => _websiteApi.updateSsl(req);

  @override
  Future<void> deleteSsl(List<int> ids) => _websiteApi.deleteSsl(ids);

  @override
  Future<void> obtainSsl(int id) => _websiteApi.obtainSsl(id);

  @override
  Future<List<SslResolveDto>> resolveSsl(int acmeId, int sslId) =>
      _websiteApi.resolveSsl(acmeId, sslId);

  @override
  Future<void> uploadSsl({
    required String type,
    String? certificate,
    String? privateKey,
    String? certificatePath,
    String? privateKeyPath,
    String? description,
    int? domainId,
    int? websiteSSLId,
  }) => _websiteApi.uploadSsl(
    type: type,
    certificate: certificate,
    privateKey: privateKey,
    certificatePath: certificatePath,
    privateKeyPath: privateKeyPath,
    description: description,
    domainId: domainId,
    websiteSSLId: websiteSSLId,
  );

  @override
  Future<void> uploadSslByFile({
    required String certificatePath,
    required String privateKeyPath,
    String? description,
    int? websiteSSLId,
  }) => _websiteApi.uploadSslByFile(
    certificatePath: certificatePath,
    privateKeyPath: privateKeyPath,
    description: description,
    websiteSSLId: websiteSSLId,
  );

  @override
  Future<Response<dynamic>> downloadSsl(int id) => _websiteApi.downloadSsl(id);

  // ===========================================================================
  // ACME 账号管理
  // ===========================================================================

  @override
  Future<PageResult<WebsiteAcmeAccountDto>> searchAcmeAccountsPaged(
    Map<String, dynamic> req,
  ) => _websiteApi.searchAcmeAccountsPaged(req);

  @override
  Future<void> createAcmeAccount(AcmeAccountCreateReq req) =>
      _websiteApi.createAcmeAccount(req);

  @override
  Future<void> updateAcmeAccount(Map<String, dynamic> req) =>
      _websiteApi.updateAcmeAccount(req);

  @override
  Future<void> deleteAcmeAccount(int id) => _websiteApi.deleteAcmeAccount(id);

  // ===========================================================================
  // DNS 账号管理
  // ===========================================================================

  @override
  Future<PageResult<DnsAccountDto>> searchDnsAccounts(
    Map<String, dynamic> req,
  ) => _websiteApi.searchDnsAccounts(req);

  @override
  Future<void> createDnsAccount(DnsAccountCreateReq req) =>
      _websiteApi.createDnsAccount(req);

  @override
  Future<void> updateDnsAccount(Map<String, dynamic> req) =>
      _websiteApi.updateDnsAccount(req);

  @override
  Future<void> deleteDnsAccount(int id) => _websiteApi.deleteDnsAccount(id);

  // ===========================================================================
  // 自签 CA 管理
  // ===========================================================================

  @override
  Future<PageResult<CaDto>> searchCaAccounts(Map<String, dynamic> req) =>
      _websiteApi.searchCaAccounts(req);

  @override
  Future<CaDto> getCaDetail(int id) => _websiteApi.getCaDetail(id);

  @override
  Future<void> createCa(CaCreateReq req) => _websiteApi.createCa(req);

  @override
  Future<void> obtainCa(CaObtainReq req) => _websiteApi.obtainCa(req);

  @override
  Future<void> renewCa(int sslId) => _websiteApi.renewCa(sslId);

  @override
  Future<void> deleteCa(int id) => _websiteApi.deleteCa(id);

  @override
  Future<Response<dynamic>> downloadCa(int id) => _websiteApi.downloadCa(id);

  @override
  Future<void> switchPhpVersion(int websiteId, int runtimeId) =>
      _websiteApi.switchPhpVersion(websiteId, runtimeId);

  @override
  Future<List<WebsiteResourceDto>> getWebsiteResources(int websiteId) =>
      _websiteApi.getWebsiteResources(websiteId);

  @override
  Future<List<WebsiteDatabaseDto>> getWebsiteDatabases() =>
      _websiteApi.getWebsiteDatabases();

  @override
  Future<void> changeWebsiteDatabase(WebsiteChangeDatabaseReq req) =>
      _websiteApi.changeWebsiteDatabase(req);
}

/// 基于当前激活服务器的仓库 Provider。
@Riverpod()
Future<WebsiteRepository> websiteRepository(Ref ref) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return WebsiteRepositoryImpl(
    WebsiteApi(client),
    FileApi(client),
    GroupApi(client),
  );
}
