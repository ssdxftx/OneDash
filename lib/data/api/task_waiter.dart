import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../dto/common/task_log_dto.dart';

/// 轮询 `/logs/tasks/read`，等待 1Panel 后台任务结束。
class TaskWaiter {
  const TaskWaiter(
    this._client, {
    this.interval = const Duration(milliseconds: 500),
    this.maxAttempts = 60,
  });

  final DioClient _client;
  final Duration interval;
  final int maxAttempts;

  Future<void> waitFor(String taskID, {String subject = '任务'}) async {
    if (taskID.isEmpty) return;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v2/logs/tasks/read',
        data: {'taskID': taskID, 'page': 1, 'pageSize': 200, 'latest': true},
      );
      final log = ApiResponseParser.object(response, TaskLogDto.fromJson);
      final status = log.taskStatus.toLowerCase();
      if (status == 'success') return;
      if (status == 'failed' || status == 'error' || status == 'canceled') {
        final detail = log.lines.isEmpty ? '' : log.lines.last;
        throw StateError('$subject执行失败 $detail'.trim());
      }
      await Future<void>.delayed(interval);
    }
    throw StateError('$subject仍在执行，请稍后刷新');
  }
}
