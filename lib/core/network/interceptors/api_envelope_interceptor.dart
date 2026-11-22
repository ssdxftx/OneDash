import 'dart:convert';

import 'package:dio/dio.dart';

import '../network_exceptions.dart';

/// 识别 1Panel API envelope 中的业务失败，并转交给统一异常流程。
class ApiEnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final failure = _failureFrom(response);
    if (failure == null) {
      handler.next(response);
      return;
    }

    handler.reject(
      DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: ApiBusinessException(
          failure.code,
          failure.message,
          errorCode: failure.errorCode,
        ),
      ),
    );
  }

  _ApiEnvelopeFailure? _failureFrom(Response response) {
    final payload = _jsonPayload(response);
    if (payload is! Map) return null;

    final code = _codeOf(payload['code']);
    if (code == null || code == 200) return null;

    return _ApiEnvelopeFailure(
      code,
      _messageOf(payload),
      payload['errorCode']?.toString(),
    );
  }

  Object? _jsonPayload(Response response) {
    final data = response.data;
    if (data is Map) return data;
    if (data is String) {
      final disposition =
          response.headers.value('content-disposition')?.toLowerCase() ?? '';
      if (disposition.contains('attachment')) return null;
      final text = data.trim();
      if (!text.startsWith('{') && !text.startsWith('[')) return null;
      return _tryDecode(text);
    }
    if (data is List<int>) {
      final contentType =
          response.headers.value(Headers.contentTypeHeader)?.toLowerCase() ??
          '';
      final disposition =
          response.headers.value('content-disposition')?.toLowerCase() ?? '';
      if (!contentType.contains('json') || disposition.contains('attachment')) {
        return null;
      }
      return _tryDecode(utf8.decode(data, allowMalformed: true));
    }
    return null;
  }

  Object? _tryDecode(String text) {
    try {
      return jsonDecode(text);
    } catch (_) {
      return null;
    }
  }

  int? _codeOf(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _messageOf(Map<dynamic, dynamic> payload) {
    final message = payload['message'] ?? payload['msg'];
    final text = message?.toString().trim();
    return text ?? '';
  }
}

class _ApiEnvelopeFailure {
  const _ApiEnvelopeFailure(this.code, this.message, this.errorCode);

  final int code;
  final String message;
  final String? errorCode;
}
