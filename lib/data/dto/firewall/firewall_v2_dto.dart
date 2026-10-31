class FirewallTaskResult {
  const FirewallTaskResult({required this.taskID, required this.queued});

  final String taskID;
  final bool queued;

  factory FirewallTaskResult.fromJson(Map<String, dynamic> json) {
    return FirewallTaskResult(
      taskID: '${json['taskID'] ?? ''}',
      queued: json['queued'] == true,
    );
  }
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

Map<String, dynamic> _asMap(Map<dynamic, dynamic> value) =>
    Map<String, dynamic>.from(value);

List<Map<String, dynamic>> _maps(Object? value) => (value as List? ?? const [])
    .whereType<Map>()
    .map(_asMap)
    .toList(growable: false);

class FirewallScopeInfo {
  const FirewallScopeInfo(this.json);

  final Map<String, dynamic> json;

  String get provider => '${json['provider'] ?? ''}';
  String get family => '${json['family'] ?? ''}';
  String get table => '${json['table'] ?? ''}';
  String get chain => '${json['chain'] ?? ''}';
  String get zone => '${json['zone'] ?? ''}';
  String get direction => '${json['direction'] ?? ''}';

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(json);
}

class FirewallRuleInfo {
  const FirewallRuleInfo(this.json);

  final Map<String, dynamic> json;

  FirewallScopeInfo get scope => FirewallScopeInfo(_map(json['scope']));
  String get uuid => '${json['uuid'] ?? ''}';
  String get nativeKind => '${json['nativeKind'] ?? ''}';
  String get protocol => '${json['protocol'] ?? ''}';
  String get sourceAddress => '${json['sourceAddress'] ?? ''}';
  String get sourcePort => '${json['sourcePort'] ?? ''}';
  String get destinationAddress => '${json['destinationAddress'] ?? ''}';
  String get destinationPort => '${json['destinationPort'] ?? ''}';
  String get interface => '${json['interface'] ?? ''}';
  String get action => '${json['action'] ?? ''}';
  String get description => '${json['description'] ?? ''}';
  int? get priority => (json['priority'] as num?)?.toInt();
  int? get orderIndex => (json['orderIndex'] as num?)?.toInt();

  bool get isAccept => action == 'accept';
  bool get isDeny => action == 'drop' || action == 'reject';
  bool get hasPort => destinationPort.isNotEmpty || sourcePort.isNotEmpty;
  String get displayPort {
    if (destinationPort.isNotEmpty) return destinationPort;
    return sourcePort;
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(json);
}

class FirewallRuleItem {
  const FirewallRuleItem(this.json);

  final Map<String, dynamic> json;

  FirewallRuleInfo get rule => FirewallRuleInfo(_map(json['rule']));
  Map<String, dynamic> get observed => _map(json['observed']);
  FirewallRuleInfo get observedRule => FirewallRuleInfo(_map(observed['rule']));
  Map<String, dynamic> get locator => _map(observed['locator']);

  String get instanceKey => '${observed['instanceKey'] ?? ''}';
  int? get position => (locator['position'] as num?)?.toInt();
  bool get protected =>
      observed['protected'] == true || rule.json['protected'] == true;
  bool get isWhitelist => json['isWhitelist'] == true;
  bool get canDelete => !protected && !isWhitelist && instanceKey.isNotEmpty;
  bool get canReorder =>
      !protected && position != null && rule.nativeKind == 'rule';

  Map<String, dynamic> deleteTarget() => {
    'scope': rule.scope.toJson(),
    'instanceKey': instanceKey,
    'observed': observed,
  };
}

class FirewallInventory {
  const FirewallInventory({
    required this.total,
    required this.items,
    required this.notices,
  });

  final int total;
  final List<FirewallRuleItem> items;
  final List<String> notices;

  factory FirewallInventory.fromJson(Map<String, dynamic> json) {
    return FirewallInventory(
      total: (json['total'] as num?)?.toInt() ?? 0,
      items: _maps(
        json['items'],
      ).map(FirewallRuleItem.new).toList(growable: false),
      notices: _maps(json['notices'])
          .map((notice) => '${notice['code'] ?? ''}')
          .where((code) => code.isNotEmpty)
          .toList(growable: false),
    );
  }
}

class FirewallBackendOption {
  const FirewallBackendOption(this.json);

  final Map<String, dynamic> json;

  String get name => '${json['name'] ?? ''}';
  bool get installed => json['installed'] == true;
  bool get active => json['active'] == true;
  bool get initialized => json['initialized'] == true;
  bool get bound => json['bound'] == true;
  bool get supported => json['supported'] == true;
  String get implementation => '${json['implementation'] ?? ''}';
}

class FirewallBackendGroup {
  const FirewallBackendGroup(this.json);

  final Map<String, dynamic> json;

  String get selected => '${json['selected'] ?? ''}';
  String get current => '${json['current'] ?? ''}';
  List<FirewallBackendOption> get options => _maps(
    json['options'],
  ).map(FirewallBackendOption.new).toList(growable: false);
}

class FirewallWhitelistRule {
  const FirewallWhitelistRule(this.json);

  final Map<String, dynamic> json;

  String get port => '${json['port'] ?? ''}';
  String get protocol => '${json['protocol'] ?? ''}';
  String get type => '${json['type'] ?? ''}';
  List<String> get sources =>
      (json['sources'] as List? ?? const []).map((e) => '$e').toList();

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(json);
}

class FirewallSettingsInfo {
  const FirewallSettingsInfo(this.json);

  final Map<String, dynamic> json;

  bool get ipv6Enabled => json['ipv6Enabled'] == true;
  FirewallBackendGroup get system => FirewallBackendGroup(_map(json['system']));
  FirewallBackendGroup get forwarding =>
      FirewallBackendGroup(_map(json['forwarding']));
  FirewallBackendGroup get docker => FirewallBackendGroup(_map(json['docker']));
  String get pingStatus => '${json['pingStatus'] ?? ''}';
  String get panelPort => '${json['panelPort'] ?? ''}';
  String get sshPort => '${json['sshPort'] ?? ''}';
  List<FirewallWhitelistRule> get whitelist => _maps(
    json['portWhiteList'],
  ).map(FirewallWhitelistRule.new).toList(growable: false);
}

class FirewallForwardRule {
  const FirewallForwardRule(this.json);

  final Map<String, dynamic> json;

  String get family => '${json['family'] ?? ''}';
  String get protocol => '${json['protocol'] ?? ''}';
  String get port => '${json['port'] ?? ''}';
  String get targetIP => '${json['targetIP'] ?? ''}';
  String get targetPort => '${json['targetPort'] ?? ''}';
  String get interface => '${json['interface'] ?? ''}';

  Map<String, dynamic> toJson({String? operation}) => {
    if (operation != null) 'operation': operation,
    'family': family,
    'protocol': protocol,
    'port': port,
    'targetIP': targetIP,
    'targetPort': targetPort,
    'interface': interface,
  };
}

class FirewallForwardPage {
  const FirewallForwardPage({required this.total, required this.items});

  final int total;
  final List<FirewallForwardRule> items;

  factory FirewallForwardPage.fromJson(Map<String, dynamic> json) {
    return FirewallForwardPage(
      total: (json['total'] as num?)?.toInt() ?? 0,
      items: _maps(
        json['items'],
      ).map(FirewallForwardRule.new).toList(growable: false),
    );
  }
}

class DockerGuardFamilyStatus {
  const DockerGuardFamilyStatus(this.json);

  final Map<String, dynamic> json;

  String get state => '${json['state'] ?? ''}';
  bool get effective => json['effective'] == true;
  bool get initialized => json['initialized'] == true;
  bool get bound => json['bound'] == true;
}

class DockerGuardEndpoint {
  const DockerGuardEndpoint(this.json);

  final Map<String, dynamic> json;

  String get family => '${json['family'] ?? ''}';
  String get hostIP => '${json['hostIP'] ?? ''}';
  int get hostPort => (json['hostPort'] as num?)?.toInt() ?? 0;
  String get protocol => '${json['protocol'] ?? ''}';
  String get containerName => '${json['containerName'] ?? ''}';
  int get containerPort => (json['containerPort'] as num?)?.toInt() ?? 0;
  bool get effective => json['effective'] == true;
}

class DockerGuardInfo {
  const DockerGuardInfo(this.json);

  final Map<String, dynamic> json;

  Map<String, dynamic> get base => _map(json['base']);
  String get name => '${base['name'] ?? ''}';
  String get version => '${base['version'] ?? ''}';
  bool get isExist => base['isExist'] == true;
  bool get initialized => base['initialized'] == true;
  bool get bound => base['bound'] == true;
  String get backend => '${base['backend'] ?? ''}';
  DockerGuardFamilyStatus get ipv4 =>
      DockerGuardFamilyStatus(_map(base['ipv4']));
  DockerGuardFamilyStatus get ipv6 =>
      DockerGuardFamilyStatus(_map(base['ipv6']));

  List<DockerGuardEndpoint> get endpoints => _maps(json['containers'])
      .expand((container) => _maps(container['endpoints']))
      .map(DockerGuardEndpoint.new)
      .toList(growable: false);

  bool get isEffective => ipv4.effective || ipv6.effective;
}
