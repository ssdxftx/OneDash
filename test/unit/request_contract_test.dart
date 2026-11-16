import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/data/dto/app/app_installed_search_req.dart';
import 'package:onedash/data/dto/website/ssl_manage_dtos.dart';
import 'package:onedash/data/dto/website/website_create_req.dart';
import 'package:onedash/data/dto/website/website_update_req.dart';
import 'package:onedash/data/dto/website/website_domain_req.dart';
import 'package:onedash/data/dto/website/website_https_dto.dart';
import 'package:onedash/data/dto/website/website_redirect_dto.dart';
import 'package:onedash/data/dto/alert/alert_dto.dart';
import 'package:onedash/data/dto/backup/backup_record_dto.dart';
import 'package:onedash/data/dto/container/container_info_dto.dart';

void main() {
  test('website update uses the 1Panel webSiteGroupID field', () {
    const req = WebsiteUpdateReq(
      id: 7,
      primaryDomain: 'example.com',
      remark: '',
      webSiteGroupId: 42,
      ipv6: false,
      favorite: false,
    );

    final json = req.toJson();
    expect(json['webSiteGroupID'], 42);
    expect(json.containsKey('webSiteGroupId'), isFalse);
    expect(json.containsKey('alias'), isFalse);
  });

  test('website redirect always sends operate', () {
    const redirect = WebsiteRedirectDto(
      websiteID: 7,
      name: 'redirect',
      operate: 'edit',
      target: 'https://example.com',
    );
    expect(redirect.toJson()['operate'], 'edit');
    expect(
      const WebsiteRedirectDto(
        websiteID: 7,
        name: 'redirect',
      ).toJson()['operate'],
      'create',
    );
  });

  test('https binding uses a valid 1Panel type and default http config', () {
    final payload = buildWebsiteHttpsPayload(
      websiteId: 7,
      sslId: 9,
      acmeAccountId: 0,
      type: 'existed',
      https: const WebsiteHttpsDto(
        enable: false,
        httpConfig: '',
        algorithm: '',
        hsts: false,
        hstsIncludeSubDomains: false,
        httpsPort: '',
        http3: false,
      ),
    );
    expect(payload['type'], 'existed');
    expect(payload['httpConfig'], 'HTTPToHTTPS');
    expect(payload['websiteSSLId'], 9);
    expect(payload['httpsPorts'], const [443]);
  });

  test('https binding keeps custom ports from the panel response', () {
    final https = WebsiteHttpsDto.fromJson({
      'httpsPorts': [8443, 9443],
      'httpsPort': '8443,9443',
    });
    expect(https.httpsPorts, const [8443, 9443]);
    final payload = buildWebsiteHttpsPayload(
      websiteId: 7,
      sslId: 9,
      acmeAccountId: 0,
      type: 'existed',
      https: https,
    );
    expect(payload['httpsPorts'], const [8443, 9443]);
  });

  test('alert search sends the required order value', () {
    const req = AlertSearchReq(page: 1, pageSize: 20);
    expect(req.toJson()['order'], 'null');
  });

  test('backup record file path includes its directory', () {
    final record = BackupRecordDto.fromJson({
      'id': 1,
      'fileDir': 'database/mysql/app',
      'fileName': 'app.sql.gz',
    });
    expect(record.filePath, 'database/mysql/app/app.sql.gz');
  });

  test('container extra hosts parse object payloads', () {
    final host = ContainerExtraHostDto.fromJson({
      'hostname': 'db.local',
      'ip': '10.0.0.2',
    });
    expect(host.hostname, 'db.local');
    expect(host.toJson()['ip'], '10.0.0.2');
  });

  test('installed app search skips expensive upstream sync by default', () {
    const req = AppInstalledSearchReq(page: 1, pageSize: 100);
    expect(req.toJson()['sync'], isFalse);
    expect(req.toJson()['update'], isFalse);
  });

  test('website create uses the 1Panel appInstall and group keys', () {
    const req = WebsiteCreateReq(
      alias: 'example',
      type: 'static',
      domains: [WebsiteDomainReq(domain: 'example.com')],
      webSiteGroupID: 3,
    );
    final json = req.toJson();
    expect(json['appInstall'], isA<Map<String, dynamic>>());
    expect(json.containsKey('appinstall'), isFalse);
    expect(json['webSiteGroupID'], 3);
  });

  test('CA create uses organizationUint and a valid key type', () {
    const req = CaCreateReq(
      name: 'ca',
      commonName: 'ca.local',
      country: 'CN',
      organization: 'OneDash',
      organizationUnit: 'Ops',
      province: '',
      city: '',
      keyType: 'EC256',
    );
    final json = req.toJson();
    expect(json['organizationUint'], 'Ops');
    expect(json.containsKey('organizationUnit'), isFalse);
    expect(json['keyType'], 'EC256');
  });

  test('SSL create sends the 1Panel isIp key', () {
    const req = SslCreateReq(
      primaryDomain: 'example.com',
      otherDomains: '',
      provider: 'http',
      keyType: 'EC256',
      description: '',
      dir: '',
      shell: '',
      nodes: '',
      acmeAccountId: 1,
      dnsAccountId: 0,
      autoRenew: false,
      pushDir: false,
      execShell: false,
      pushNode: false,
      isIp: false,
      disableCNAME: false,
      skipDNS: false,
      nameserver1: '',
      nameserver2: '',
    );
    expect(req.toJson()['isIp'], isFalse);
    expect(req.toJson().containsKey('isIP'), isFalse);
  });

  test('installed app search can explicitly request sync', () {
    const req = AppInstalledSearchReq(page: 1, pageSize: 100, sync: true);
    expect(req.toJson()['sync'], isTrue);
  });
}
