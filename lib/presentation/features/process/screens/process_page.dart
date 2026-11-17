import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/api/process_api.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_bar_actions.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/search_field.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_mapper.dart';
import '../../../common/states/error_state.dart';
import '../widgets/process_detail_sheet.dart';
import '../widgets/process_list_item.dart';
import '../widgets/process_network_item.dart';

enum _ProcessSortKey { cpu, memory, pid, connections }

class ProcessPage extends ConsumerStatefulWidget {
  const ProcessPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<ProcessPage> createState() => _ProcessPageState();
}

class _ProcessPageState extends ConsumerState<ProcessPage> {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _timer;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _processes = const [];
  List<Map<String, dynamic>> _network = const [];
  bool _connecting = true;
  Object? _error;
  String _pendingType = 'ps';
  int _tab = 0;
  bool _searching = false;
  String _query = '';
  _ProcessSortKey _sortKey = _ProcessSortKey.cpu;
  bool _sortAsc = false;

  bool _bootstrapped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bootstrapped) {
      _bootstrapped = true;
      _connect();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final serverMissing = AppLocalizations.of(context).process_serverMissing;
    await _closeConnection();
    if (!mounted) return;
    setState(() {
      _connecting = true;
      _error = null;
    });
    try {
      final storage = ref.read(storageServiceProvider);
      final server = await storage.getServer(widget.serverId);
      if (server == null) {
        throw StateError(serverMissing);
      }
      final apiKey = await storage.getApiKey(widget.serverId) ?? '';
      final channel = await ProcessApi.connectProcessWebSocket(
        baseUrl: server.baseUrl.toString(),
        apiKey: apiKey,
        allowInsecureConnections: server.allowInsecureConnections,
      );
      if (!mounted) {
        await channel.sink.close();
        return;
      }
      _channel = channel;
      _subscription = channel.stream.listen(
        _handleMessage,
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _error = error;
            _connecting = false;
          });
        },
        onDone: () {
          if (!mounted) return;
          setState(() => _connecting = false);
        },
      );
      await channel.ready.timeout(const Duration(seconds: 15));
      if (!mounted) return;
      _sendCurrent();
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _sendCurrent(),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _connecting = false;
      });
    }
  }

  Future<void> _closeConnection() async {
    _timer?.cancel();
    _timer = null;
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  void _handleMessage(dynamic event) {
    final List<Map<String, dynamic>> items;
    try {
      final decoded = jsonDecode(event.toString());
      items = decoded is List
          ? decoded
                .whereType<Map>()
                .map((item) => item.cast<String, dynamic>())
                .toList(growable: false)
          : const <Map<String, dynamic>>[];
    } catch (_) {
      return;
    }
    if (!mounted) return;
    final isNetwork = items.isNotEmpty && items.first.containsKey('localaddr');
    setState(() {
      if (isNetwork) {
        _network = items;
      } else if (items.isNotEmpty) {
        _processes = items;
      } else if (_pendingType == 'net') {
        _network = const [];
      } else {
        _processes = const [];
      }
      _connecting = false;
      _error = null;
    });
  }

  void _sendPs() {
    _pendingType = 'ps';
    _send({'type': 'ps', 'pid': null, 'username': '', 'name': ''});
  }

  void _sendNet() {
    _pendingType = 'net';
    _send({'type': 'net', 'processID': null, 'processName': '', 'port': null});
  }

  void _send(Map<String, dynamic> message) {
    try {
      _channel?.sink.add(jsonEncode(message));
    } catch (_) {
      // The socket may close between the timer tick and the send.
    }
  }

  void _sendCurrent() {
    if (_tab == 0) {
      _sendPs();
    } else {
      _sendNet();
    }
  }

  Future<void> _refresh() async {
    _sendCurrent();
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  void _switchTab(int index) {
    if (index == _tab) return;
    setState(() {
      _tab = index;
      _query = '';
      _searchController.clear();
      _searching = false;
      _connecting = true;
    });
    _sendCurrent();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _query = '';
        _searchController.clear();
      }
    });
  }

  Future<void> _showSort() async {
    final l10n = AppLocalizations.of(context);
    final selected = await showSelectionMenu<_ProcessSortKey>(
      context,
      title: l10n.process_sort,
      options: [
        _sortOption(l10n.process_sortCpu, TablerIcons.cpu, _ProcessSortKey.cpu),
        _sortOption(
          l10n.process_sortMemory,
          TablerIcons.cpu_2,
          _ProcessSortKey.memory,
        ),
        _sortOption('PID', TablerIcons.hash, _ProcessSortKey.pid),
        _sortOption(
          l10n.process_sortConnections,
          TablerIcons.plug,
          _ProcessSortKey.connections,
        ),
      ],
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (_sortKey == selected) {
        _sortAsc = !_sortAsc;
      } else {
        _sortKey = selected;
        _sortAsc =
            selected == _ProcessSortKey.pid ||
            selected == _ProcessSortKey.connections;
      }
    });
  }

  SelectionOption<_ProcessSortKey> _sortOption(
    String label,
    IconData icon,
    _ProcessSortKey key,
  ) {
    return SelectionOption(
      label: label,
      value: key,
      icon: _sortKey == key ? TablerIcons.check : icon,
    );
  }

  List<Map<String, dynamic>> _filteredItems() {
    final source = _tab == 0 ? _processes : _network;
    final query = _query.trim().toLowerCase();
    final items = query.isEmpty
        ? source.toList(growable: false)
        : source
              .where((item) => _searchText(item).contains(query))
              .toList(growable: false);
    final sorted = items.toList();
    final key =
        _tab == 1 &&
            (_sortKey == _ProcessSortKey.cpu ||
                _sortKey == _ProcessSortKey.memory)
        ? _ProcessSortKey.connections
        : _sortKey;
    sorted.sort((a, b) {
      final left = _sortValue(a, key);
      final right = _sortValue(b, key);
      final result = left.compareTo(right);
      return _sortAsc ? result : -result;
    });
    return sorted;
  }

  double _sortValue(Map<String, dynamic> item, _ProcessSortKey key) {
    return switch (key) {
      _ProcessSortKey.cpu => processDouble(item['cpuValue']),
      _ProcessSortKey.memory => processDouble(item['rssValue']),
      _ProcessSortKey.pid => processDouble(item['PID'] ?? item['pid']),
      _ProcessSortKey.connections => processDouble(item['numConnections']),
    };
  }

  String _searchText(Map<String, dynamic> item) {
    final values = _tab == 0
        ? [
            item['name'],
            item['Name'],
            item['cmdLine'],
            item['username'],
            item['status'],
            item['PID'] ?? item['pid'],
          ]
        : [
            item['name'],
            item['Name'],
            item['type'],
            item['status'],
            item['PID'] ?? item['pid'],
            _addressText(item['localaddr']),
            _addressText(item['remoteaddr']),
          ];
    return values.map((value) => '${value ?? ''}').join(' ').toLowerCase();
  }

  static String _addressText(Object? address) {
    if (address is Map) {
      return '${address['ip'] ?? ''}:${address['port'] ?? ''}';
    }
    return '${address ?? ''}';
  }

  Future<void> _openDetail(Map<String, dynamic> item) async {
    final pid = processInt(item['PID'] ?? item['pid']);
    if (pid <= 0) return;
    await showProcessDetailSheet(
      context,
      serverId: widget.serverId,
      pid: pid,
      summary: item,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = _filteredItems();
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.process_title,
        actions: [
          AppBarActions(
            actions: [
              AppBarAction(
                icon: _searching ? TablerIcons.x : TablerIcons.search,
                tooltip: _searching ? l10n.action_close : l10n.common_search,
                onPressed: _toggleSearch,
              ),
              AppBarAction(
                icon: _sortAsc
                    ? TablerIcons.sort_ascending
                    : TablerIcons.sort_descending,
                tooltip: l10n.process_sort,
                onPressed: _showSort,
              ),
              AppBarAction(
                icon: TablerIcons.refresh,
                tooltip: l10n.action_refresh,
                onPressed: _refresh,
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SegmentedTabs(
            labels: [l10n.more_process, l10n.nav_network],
            selectedIndex: _tab,
            onChanged: _switchTab,
            padding: EdgeInsets.fromLTRB(
              context.pagePadding,
              AppTokens.s8,
              AppTokens.s16,
              AppTokens.s4,
            ),
          ),
          if (_searching)
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.pagePadding,
                AppTokens.s4,
                context.pagePadding,
                AppTokens.s8,
              ),
              child: SearchField(
                controller: _searchController,
                autofocus: true,
                hint: _tab == 0
                    ? l10n.process_searchNamePlaceholder
                    : l10n.process_searchNameOrPortPlaceholder,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
          Expanded(child: _buildBody(l10n, items)),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, List<Map<String, dynamic>> items) {
    final hasData = _tab == 0 ? _processes.isNotEmpty : _network.isNotEmpty;
    if (_connecting && !hasData) {
      return const SkeletonList(itemCount: 8, itemHeight: 104);
    }
    if (_error != null && !hasData) {
      return ErrorState(data: mapError(_error!, l10n), onRetry: _connect);
    }
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            context.pagePadding,
            AppTokens.s40,
            context.pagePadding,
            AppTokens.bottomNavClearance + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            EmptyState(
              icon: _tab == 0 ? TablerIcons.cpu : TablerIcons.network,
              title: _query.isNotEmpty
                  ? l10n.process_noResults
                  : l10n.process_noData,
              message: _query.isNotEmpty
                  ? l10n.process_noResultsSubtitle
                  : l10n.process_waitingData,
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.pagePadding,
          AppTokens.s8,
          context.pagePadding,
          AppTokens.bottomNavClearance + MediaQuery.paddingOf(context).bottom,
        ),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
        itemBuilder: (context, index) {
          final item = items[index];
          if (_tab == 0) {
            return ProcessListItem(item: item, onTap: () => _openDetail(item));
          }
          return ProcessNetworkItem(
            item: item,
            detailLabel: l10n.process_networkConnections,
            onTap: processInt(item['PID'] ?? item['pid']) > 0
                ? () => _openDetail(item)
                : null,
          );
        },
      ),
    );
  }
}
