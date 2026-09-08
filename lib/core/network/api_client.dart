import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/app_errors.dart';

abstract class ApiClient {
  Future<dynamic> get(String endpoint, {Map<String, String>? headers, Map<String, dynamic>? queryParameters});
  Future<dynamic> post(String endpoint, {Map<String, String>? headers, dynamic body});
  Future<dynamic> put(String endpoint, {Map<String, String>? headers, dynamic body});
  Future<dynamic> delete(String endpoint, {Map<String, String>? headers});
}

class HttpApiClient implements ApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  HttpApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?customHeaders,
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = '$baseUrl$normalizedEndpoint';
    return Uri.parse(fullUrl).replace(queryParameters: queryParameters?.map((k, v) => MapEntry(k, v.toString())));
  }

  @override
  Future<dynamic> get(String endpoint, {Map<String, String>? headers, Map<String, dynamic>? queryParameters}) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final response = await _client.get(uri, headers: _buildHeaders(headers));
      return _handleResponse(response);
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw ServerFailure('Network request failed: $e');
    }
  }

  @override
  Future<dynamic> post(String endpoint, {Map<String, String>? headers, dynamic body}) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.post(
        uri,
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw ServerFailure('Network request failed: $e');
    }
  }

  @override
  Future<dynamic> put(String endpoint, {Map<String, String>? headers, dynamic body}) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.put(
        uri,
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw ServerFailure('Network request failed: $e');
    }
  }

  @override
  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.delete(uri, headers: _buildHeaders(headers));
      return _handleResponse(response);
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw ServerFailure('Network request failed: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AuthFailure('Session expired or unauthorized');
    } else if (response.statusCode == 404) {
      throw const NotFoundFailure('Requested resource not found');
    } else {
      throw ServerFailure('Server returned status code ${response.statusCode}: ${response.body}');
    }
  }
}
