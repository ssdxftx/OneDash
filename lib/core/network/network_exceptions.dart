/// 网络层自定义异常体系。
///
/// 拦截器与 `DioClient` 统一把底层 `DioException` 转换为这里的子类，
/// 上层 Repository / UI 只需关心这些语义化异常。
library;

/// 所有网络异常的基类。
sealed class AppNetworkException implements Exception {
  const AppNetworkException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

/// 网络层错误码，供 UI 层翻译为本地文案。
enum NetworkErrorCode { wsPreflightFailed, wsPreflightTimeout }

/// 网络不可达 / 超时 / DNS 失败等连接层错误。
class NetworkConnectionException extends AppNetworkException {
  const NetworkConnectionException(super.message, {this.code});

  final NetworkErrorCode? code;
}

/// 401 或 MD5 鉴权失败。
class AuthException extends AppNetworkException {
  const AuthException(super.message, {super.statusCode});
}

/// 5xx 服务端错误。
class ServerException extends AppNetworkException {
  const ServerException(super.message, {super.statusCode});
}

/// 4xx 客户端错误（非 401）。
class HttpException extends AppNetworkException {
  const HttpException(super.message, {super.statusCode});
}

/// HTTP 200 但业务层返回 `code != 200`。
class ApiBusinessException extends AppNetworkException {
  const ApiBusinessException(int code, super.message, {this.errorCode})
    : super(statusCode: code);

  final String? errorCode;
}

/// 响应体格式不符合预期（缺少 data 字段等）。
class ApiFormatException extends AppNetworkException {
  const ApiFormatException(super.message);
}

/// 1Panel 后台任务执行失败或等待超时。
class TaskFailedException implements Exception {
  const TaskFailedException({
    required this.subject,
    this.detail = '',
    this.timedOut = false,
  });

  final String subject;
  final String detail;
  final bool timedOut;

  @override
  String toString() =>
      'TaskFailedException(subject: $subject, timedOut: $timedOut): $detail';
}

/// 请求的记录在远端列表中不存在。
class RecordNotFoundException implements Exception {
  const RecordNotFoundException();

  @override
  String toString() => 'RecordNotFoundException';
}

/// 本地保存的服务器记录已不存在。
class ServerNotFoundException implements Exception {
  const ServerNotFoundException();

  @override
  String toString() => 'ServerNotFoundException';
}
