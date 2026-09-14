import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, [this.statusCode = 500]);

  @override
  String toString() => message;
}

class ApiService {
  static Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static dynamic _processResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      body = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    String errorMsg = 'Request failed with status: ${response.statusCode}';
    if (body is Map && body.containsKey('detail')) {
      errorMsg = body['detail'].toString();
    } else if (body is String && body.isNotEmpty) {
      errorMsg = body;
    }

    throw ApiException(errorMsg, response.statusCode);
  }

  // GET
  static Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams, bool requireAuth = true}) async {
    try {
      String urlStr = '${ApiConfig.baseUrl}$endpoint';
      if (queryParams != null && queryParams.isNotEmpty) {
        final queryStr = Uri(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString()))).query;
        urlStr += '?$queryStr';
      }

      final uri = Uri.parse(urlStr);
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.get(uri, headers: headers);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network connection error: $e');
    }
  }

  // POST
  static Future<dynamic> post(String endpoint, {dynamic body, bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network connection error: $e');
    }
  }

  // PUT
  static Future<dynamic> put(String endpoint, {dynamic body, bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network connection error: $e');
    }
  }

  // DELETE
  static Future<dynamic> delete(String endpoint, {bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.delete(uri, headers: headers);
      if (response.statusCode == 204) return null;
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network connection error: $e');
    }
  }
}
