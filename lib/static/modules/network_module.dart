import '../../models/module.dart';

/// A reusable Dio-based networking layer: a request abstraction, typed
/// exceptions, an endpoints registry, a thin API client, and a repository base.
final Module networkModule = Module(
  key: 'network',
  title: 'Networking (Dio client, endpoints, repository base)',
  description:
      'APIProvider (Dio: get/post/put/patch/delete/multipart, bearer auth, typed errors), APIRequestRepresentable, ApiEndPoints, app exceptions, and a BaseRepository + sample.',
  packages: ['dio'],
  dependsOn: ['config'],
  folders: ['lib/data/provider/network', 'lib/data/repositories'],
  files: {
    'lib/data/provider/network/api_request_representable.dart': r'''
enum HTTPMethod { get, post, delete, put, patch }

extension HTTPMethodString on HTTPMethod {
  String get string {
    switch (this) {
      case HTTPMethod.get:
        return 'GET';
      case HTTPMethod.post:
        return 'POST';
      case HTTPMethod.delete:
        return 'DELETE';
      case HTTPMethod.patch:
        return 'PATCH';
      case HTTPMethod.put:
        return 'PUT';
    }
  }
}

/// Describes a single API request. Implement per endpoint for a typed,
/// self-documenting request layer.
abstract class APIRequestRepresentable {
  String get url;
  String get endpoint;
  String get path;
  HTTPMethod get method;
  Map<String, String>? get headers;
  Map<String, String>? get query;
  dynamic get body;
  Future<dynamic> request();
}
''',
    'lib/data/provider/network/app_exceptions.dart': r'''
/// Base class for all network/data exceptions.
class AppException implements Exception {
  final String message;
  final String prefix;

  AppException(this.message, this.prefix);

  @override
  String toString() => '$prefix$message';
}

class FetchDataException extends AppException {
  FetchDataException(String message) : super(message, 'Network error: ');
}

class BadRequestException extends AppException {
  BadRequestException(String message) : super(message, 'Invalid request: ');
}

class UnauthorisedException extends AppException {
  UnauthorisedException(String message) : super(message, 'Unauthorised: ');
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, 'Not found: ');
}

class ServerException extends AppException {
  ServerException(String message) : super(message, 'Server error: ');
}

class TimeOutException extends AppException {
  TimeOutException(String message) : super(message, 'Timeout: ');
}
''',
    'lib/data/provider/network/api_endpoints.dart': r'''
import '../../../app/config/global_vars.dart';

/// Central registry of API paths. [baseUrl] comes from [Globals] (loaded from
/// the environment). Replace the samples below with your endpoints.
class ApiEndPoints {
  ApiEndPoints._();

  static String get baseUrl => Globals.baseUrl;

  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String profile = 'user/profile';
}
''',
    'lib/data/provider/network/api_provider.dart': r'''
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../app/config/global_vars.dart';
import 'api_endpoints.dart';
import 'app_exceptions.dart';

/// A thin wrapper around [Dio] that injects the bearer token, applies sensible
/// timeouts, and maps responses to data or typed [AppException]s.
class APIProvider {
  static const Duration _timeout = Duration(seconds: 30);

  final Dio _client = Dio(BaseOptions(
    connectTimeout: _timeout,
    receiveTimeout: _timeout,
    receiveDataWhenStatusError: true,
    followRedirects: true,
    maxRedirects: 3,
  ));

  APIProvider() {
    if (kDebugMode) {
      _client.interceptors.add(
        LogInterceptor(responseBody: true, requestBody: true),
      );
    }
  }

  Map<String, String> _headers({bool auth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (auth && Globals.authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${Globals.authToken}';
    }
    return headers;
  }

  String _resolve(String endpoint, String? fullUrl) =>
      fullUrl ?? (ApiEndPoints.baseUrl + endpoint);

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? query,
    bool auth = true,
    String? fullUrl,
  }) {
    return _send(() => _client.get(
          _resolve(endpoint, fullUrl),
          queryParameters: query,
          options: Options(headers: _headers(auth: auth)),
        ));
  }

  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    bool auth = true,
    String? fullUrl,
  }) {
    return _send(() => _client.post(
          _resolve(endpoint, fullUrl),
          data: body,
          options: Options(headers: _headers(auth: auth)),
        ));
  }

  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    bool auth = true,
    String? fullUrl,
  }) {
    return _send(() => _client.put(
          _resolve(endpoint, fullUrl),
          data: body,
          options: Options(headers: _headers(auth: auth)),
        ));
  }

  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    bool auth = true,
    String? fullUrl,
  }) {
    return _send(() => _client.patch(
          _resolve(endpoint, fullUrl),
          data: body,
          options: Options(headers: _headers(auth: auth)),
        ));
  }

  Future<dynamic> delete(
    String endpoint, {
    dynamic body,
    bool auth = true,
    String? fullUrl,
  }) {
    return _send(() => _client.delete(
          _resolve(endpoint, fullUrl),
          data: body,
          options: Options(headers: _headers(auth: auth)),
        ));
  }

  Future<dynamic> multipart(
    String endpoint, {
    required FormData formData,
    bool auth = true,
    String? fullUrl,
  }) {
    return _send(() => _client.post(
          _resolve(endpoint, fullUrl),
          data: formData,
          options: Options(headers: _headers(auth: auth)),
        ));
  }

  Future<dynamic> _send(Future<Response> Function() request) async {
    try {
      return _returnResponse(await request());
    } on TimeoutException {
      throw TimeOutException('Request timed out');
    } on SocketException {
      throw FetchDataException('No internet connection');
    } on DioException catch (e) {
      if (e.response != null) return _returnResponse(e.response!);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw TimeOutException('Request timed out');
      }
      throw FetchDataException('No internet connection');
    }
  }

  dynamic _returnResponse(Response response) {
    final code = response.statusCode ?? 0;
    if (code >= 200 && code < 300) {
      return response.data;
    } else if (code == 400) {
      throw BadRequestException(_message(response));
    } else if (code == 401 || code == 403) {
      throw UnauthorisedException(_message(response));
    } else if (code == 404) {
      throw NotFoundException(_message(response));
    } else if (code >= 500) {
      throw ServerException(_message(response));
    }
    throw FetchDataException('Error ($code): ${_message(response)}');
  }

  String _message(Response response) {
    final data = response.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is String && data.isNotEmpty) return data;
    return 'Unexpected error';
  }
}
''',
    'lib/data/repositories/repository.dart': r'''
import '../provider/network/api_endpoints.dart';
import '../provider/network/api_provider.dart';

/// Base class for repositories: holds a shared [APIProvider] instance.
abstract class BaseRepository {
  final APIProvider api = APIProvider();
}

/// Example repository demonstrating the request pattern. Delete or replace.
class AuthRepository extends BaseRepository {
  Future<dynamic> login({
    required String email,
    required String password,
  }) {
    return api.post(
      ApiEndPoints.login,
      auth: false,
      body: {'email': email, 'password': password},
    );
  }

  Future<dynamic> profile() => api.get(ApiEndPoints.profile);
}
''',
  },
);
