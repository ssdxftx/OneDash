import 'package:dio/dio.dart';

import 'network_exceptions.dart';

/// 1Panel API 响应解析工具。
///
/// 响应体形如：`{ "code": 200, "message": "...", "data": ... }`
/// 这里统一剥离 `data` 字段并反序列化。
class ApiResponseParser {
  const ApiResponseParser._();

  /// 从响应体中提取对象。
  static T object<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final data = _extractData(response);
    if (data is! Map<String, dynamic>) {
      throw const ApiFormatException('The data field is not an object.');
    }
    return fromJson(data);
  }

  /// 从响应体中提取列表。
  static List<T> list<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final data = _extractData(response);
    if (data == null) return const [];
    if (data is! List) {
      throw const ApiFormatException('The data field is not an array.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }

  /// 从响应体中提取基础类型列表（如 `List<String>`）。
  static List<T> primitiveList<T>(Response<dynamic> response) {
    final data = _extractData(response);
    if (data is! List) {
      throw const ApiFormatException('The data field is not an array.');
    }
    return data.whereType<T>().toList(growable: false);
  }

  /// 从响应体中提取基础类型（如 String, int, bool）。
  static T primitive<T>(Response<dynamic> response) {
    final data = _extractData(response);
    if (data is! T) {
      throw ApiFormatException(
        'The data field type does not match the expected $T.',
      );
    }
    return data;
  }

  /// 不反序列化，直接拿 Map。
  static Map<String, dynamic> map(Response<dynamic> response) {
    final data = _extractData(response);
    if (data is Map<String, dynamic>) return data;
    throw const ApiFormatException('The data field is not an object.');
  }

  /// 纯"成功/失败"语义，不关心 data 内容。
  static void ok(Response<dynamic> response) {
    _extractData(response);
  }

  static dynamic _extractData(Response<dynamic> response) {
    final body = response.data;
    if (body is! Map) {
      throw const ApiFormatException('The response body is not a JSON object.');
    }
    if (!body.containsKey('data')) {
      throw const ApiFormatException('The response is missing the data field.');
    }
    return body['data'];
  }
}
