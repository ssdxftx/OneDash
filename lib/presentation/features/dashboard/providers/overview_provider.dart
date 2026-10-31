import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/repository_providers.dart';
import '../../../../domain/entities/dashboard.dart';

class OverviewState {
  const OverviewState({
    required this.dashboard,
    required this.cpuHistory,
    required this.memoryHistory,
    required this.netUpHistory,
    required this.netDownHistory,
    required this.lastUpdated,
    this.stale = false,
    this.lastError,
  });

  final Dashboard dashboard;
  final List<double> cpuHistory;
  final List<double> memoryHistory;
  final List<double> netUpHistory;
  final List<double> netDownHistory;
  final DateTime lastUpdated;
  final bool stale;
  final String? lastError;

  OverviewState copyWith({
    Dashboard? dashboard,
    List<double>? cpuHistory,
    List<double>? memoryHistory,
    List<double>? netUpHistory,
    List<double>? netDownHistory,
    DateTime? lastUpdated,
    bool? stale,
    String? lastError,
  }) {
    return OverviewState(
      dashboard: dashboard ?? this.dashboard,
      cpuHistory: cpuHistory ?? this.cpuHistory,
      memoryHistory: memoryHistory ?? this.memoryHistory,
      netUpHistory: netUpHistory ?? this.netUpHistory,
      netDownHistory: netDownHistory ?? this.netDownHistory,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      stale: stale ?? this.stale,
      lastError: lastError ?? this.lastError,
    );
  }
}

final overviewProvider = AsyncNotifierProvider.autoDispose
    .family<OverviewController, OverviewState, int>(
      OverviewController.new,
      name: 'overviewProvider',
    );

class OverviewController
    extends AutoDisposeFamilyAsyncNotifier<OverviewState, int> {
  Timer? _timer;
  bool _visible = false;
  bool _disposed = false;
  bool _tickInFlight = false;
  int _failureCount = 0;
  int? _lastSent;
  int? _lastRecv;
  DateTime? _lastTickAt;

  @override
  Future<OverviewState> build(int serverId) async {
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
    });
    final repository = await ref.watch(
      dashboardRepositoryForServerProvider(serverId).future,
    );
    final dashboard = await repository.getDashboard(
      ioOption: 'all',
      netOption: 'all',
    );
    _lastSent = dashboard.current.netBytesSent;
    _lastRecv = dashboard.current.netBytesRecv;
    _lastTickAt = DateTime.now();
    return OverviewState(
      dashboard: dashboard,
      cpuHistory: [dashboard.current.cpuUsedPercent],
      memoryHistory: [dashboard.current.memoryUsedPercent],
      netUpHistory: const [0],
      netDownHistory: const [0],
      lastUpdated: DateTime.now(),
    );
  }

  void setVisible(bool visible) {
    if (_visible == visible) return;
    _visible = visible;
    if (visible) {
      _schedule(Duration.zero);
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> refresh() async {
    await _tick(manual: true);
  }

  void _schedule(Duration delay) {
    _timer?.cancel();
    if (_disposed || !_visible) return;
    _timer = Timer(delay, () => unawaited(_tick()));
  }

  Future<void> _tick({bool manual = false}) async {
    if (_disposed || (!_visible && !manual) || _tickInFlight) return;
    final current = state.valueOrNull;
    if (current == null) return;
    _tickInFlight = true;
    try {
      final repository = await ref.read(
        dashboardRepositoryForServerProvider(arg).future,
      );
      final latest = await repository.getDashboardCurrent(
        ioOption: 'all',
        netOption: 'all',
      );
      if (_disposed) return;
      final now = DateTime.now();
      final elapsed = _lastTickAt == null
          ? 1.0
          : now.difference(_lastTickAt!).inMilliseconds / 1000.0;
      final sent = latest.netBytesSent;
      final recv = latest.netBytesRecv;
      final upRate = _lastSent == null || elapsed <= 0
          ? 0.0
          : ((sent - _lastSent!).clamp(0, 1 << 62) / elapsed);
      final downRate = _lastRecv == null || elapsed <= 0
          ? 0.0
          : ((recv - _lastRecv!).clamp(0, 1 << 62) / elapsed);
      _lastSent = sent;
      _lastRecv = recv;
      _lastTickAt = now;
      _failureCount = 0;

      final cpu = _append(current.cpuHistory, latest.cpuUsedPercent);
      final memory = _append(current.memoryHistory, latest.memoryUsedPercent);
      final netUp = _append(current.netUpHistory, upRate);
      final netDown = _append(current.netDownHistory, downRate);
      state = AsyncData(
        current.copyWith(
          dashboard: Dashboard(base: current.dashboard.base, current: latest),
          cpuHistory: cpu,
          memoryHistory: memory,
          netUpHistory: netUp,
          netDownHistory: netDown,
          lastUpdated: now,
          stale: false,
          lastError: null,
        ),
      );
      _schedule(const Duration(seconds: 2));
    } catch (error) {
      if (_disposed) return;
      _failureCount++;
      final delay = switch (_failureCount) {
        1 => const Duration(seconds: 3),
        2 => const Duration(seconds: 5),
        _ => const Duration(seconds: 10),
      };
      final latest = state.valueOrNull;
      if (latest != null) {
        state = AsyncData(latest.copyWith(stale: true, lastError: '$error'));
      }
      _schedule(delay);
    } finally {
      _tickInFlight = false;
    }
  }

  List<double> _append(List<double> source, double value) {
    final next = List<double>.of(source)..add(value);
    if (next.length > AppTokens.chartHistoryPoints) {
      next.removeRange(0, next.length - AppTokens.chartHistoryPoints);
    }
    return next;
  }
}
