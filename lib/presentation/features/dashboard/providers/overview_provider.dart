import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/repository_providers.dart';
import '../../../../domain/entities/dashboard.dart';

class SpeedSample {
  const SpeedSample({required this.time, required this.up, required this.down});

  final DateTime time;
  final double up;
  final double down;
}

class OverviewState {
  const OverviewState({
    required this.dashboard,
    required this.cpuHistory,
    required this.memoryHistory,
    required this.netUpHistory,
    required this.netDownHistory,
    required this.speedHistory,
    required this.lastUpdated,
    this.readBytesPerSecond = 0,
    this.writeBytesPerSecond = 0,
    this.latencyMs = 0,
    this.stale = false,
  });

  final Dashboard dashboard;
  final List<double> cpuHistory;
  final List<double> memoryHistory;
  final List<double> netUpHistory;
  final List<double> netDownHistory;
  final List<SpeedSample> speedHistory;
  final DateTime lastUpdated;
  final double readBytesPerSecond;
  final double writeBytesPerSecond;
  final double latencyMs;
  final bool stale;

  OverviewState copyWith({
    Dashboard? dashboard,
    List<double>? cpuHistory,
    List<double>? memoryHistory,
    List<double>? netUpHistory,
    List<double>? netDownHistory,
    List<SpeedSample>? speedHistory,
    DateTime? lastUpdated,
    double? readBytesPerSecond,
    double? writeBytesPerSecond,
    double? latencyMs,
    bool? stale,
  }) {
    return OverviewState(
      dashboard: dashboard ?? this.dashboard,
      cpuHistory: cpuHistory ?? this.cpuHistory,
      memoryHistory: memoryHistory ?? this.memoryHistory,
      netUpHistory: netUpHistory ?? this.netUpHistory,
      netDownHistory: netDownHistory ?? this.netDownHistory,
      speedHistory: speedHistory ?? this.speedHistory,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      readBytesPerSecond: readBytesPerSecond ?? this.readBytesPerSecond,
      writeBytesPerSecond: writeBytesPerSecond ?? this.writeBytesPerSecond,
      latencyMs: latencyMs ?? this.latencyMs,
      stale: stale ?? this.stale,
    );
  }
}

typedef MonitorSelection = ({String io, String net});

final overviewSelectionProvider = StateProvider.autoDispose
    .family<MonitorSelection, int>(
      (ref, serverId) => (io: 'all', net: 'all'),
      name: 'overviewSelectionProvider',
    );

final overviewIoOptionsProvider = FutureProvider.autoDispose
    .family<List<String>, int>((ref, serverId) async {
      final repository = await ref.watch(
        dashboardRepositoryForServerProvider(serverId).future,
      );
      return repository.getMonitorIoOptions();
    }, name: 'overviewIoOptionsProvider');

final overviewNetOptionsProvider = FutureProvider.autoDispose
    .family<List<String>, int>((ref, serverId) async {
      final repository = await ref.watch(
        dashboardRepositoryForServerProvider(serverId).future,
      );
      return repository.getMonitorNetOptions();
    }, name: 'overviewNetOptionsProvider');

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
  int? _lastRead;
  int? _lastWrite;
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
    final selection = ref.watch(overviewSelectionProvider(serverId));
    final dashboard = await repository.getDashboardSnapshot(
      ioOption: selection.io,
      netOption: selection.net,
    );
    _lastSent = dashboard.current.netBytesSent;
    _lastRecv = dashboard.current.netBytesRecv;
    _lastRead = dashboard.current.ioReadBytes;
    _lastWrite = dashboard.current.ioWriteBytes;
    final now = DateTime.now();
    _lastTickAt = now;
    return OverviewState(
      dashboard: dashboard,
      cpuHistory: [dashboard.current.cpuUsedPercent],
      memoryHistory: [dashboard.current.memoryUsedPercent],
      netUpHistory: const [0],
      netDownHistory: const [0],
      speedHistory: [
        for (var second = 60; second >= 1; second--)
          SpeedSample(
            time: now.subtract(Duration(seconds: second)),
            up: 0,
            down: 0,
          ),
      ],
      lastUpdated: now,
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
      final selection = ref.read(overviewSelectionProvider(arg));
      final latest = await repository.getDashboardCurrent(
        ioOption: selection.io,
        netOption: selection.net,
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
      final read = latest.ioReadBytes;
      final write = latest.ioWriteBytes;
      final readRate = _lastRead == null || elapsed <= 0
          ? 0.0
          : ((read - _lastRead!).clamp(0, 1 << 62) / elapsed);
      final writeRate = _lastWrite == null || elapsed <= 0
          ? 0.0
          : ((write - _lastWrite!).clamp(0, 1 << 62) / elapsed);
      final latency = latest.ioCount <= 0
          ? 0.0
          : (latest.ioReadTime + latest.ioWriteTime) / latest.ioCount;
      _lastSent = sent;
      _lastRecv = recv;
      _lastRead = read;
      _lastWrite = write;
      _lastTickAt = now;
      _failureCount = 0;

      final cpu = _append(current.cpuHistory, latest.cpuUsedPercent);
      final memory = _append(current.memoryHistory, latest.memoryUsedPercent);
      final netUp = _append(current.netUpHistory, upRate);
      final netDown = _append(current.netDownHistory, downRate);
      final speed = _appendSpeed(
        current.speedHistory,
        SpeedSample(time: now, up: upRate, down: downRate),
      );
      state = AsyncData(
        current.copyWith(
          dashboard: Dashboard(base: current.dashboard.base, current: latest),
          cpuHistory: cpu,
          memoryHistory: memory,
          netUpHistory: netUp,
          netDownHistory: netDown,
          speedHistory: speed,
          readBytesPerSecond: readRate,
          writeBytesPerSecond: writeRate,
          latencyMs: latency,
          lastUpdated: now,
          stale: false,
        ),
      );
      _schedule(const Duration(seconds: 3));
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
        state = AsyncData(latest.copyWith(stale: true));
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

  List<SpeedSample> _appendSpeed(List<SpeedSample> source, SpeedSample sample) {
    final next = List<SpeedSample>.of(source)..add(sample);
    final cutoff = sample.time.subtract(const Duration(seconds: 65));
    next.removeWhere((item) => item.time.isBefore(cutoff));
    return next;
  }
}
