import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/app_constants.dart';
import '../utils/app_config.dart';
import 'api_exceptions.dart';

/// Auth interceptor to add Bearer token to requests
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth for login/register endpoints
    if (options.path.contains('/auth/login') || 
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh')) {
      handler.next(options);
      return;
    }

    // Add Bearer token if available
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 errors - attempt token refresh
    if (err.response?.statusCode == 401) {
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the original request with new token
          final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          
          final dio = Dio();
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        // Refresh failed, proceed with original error
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final dio = Dio();
      dio.options.baseUrl = AppConfig.apiUrl;
      
      final response = await dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        await _secureStorage.write(
          key: AppConstants.accessTokenKey,
          value: data['accessToken'],
        );
        if (data['refreshToken'] != null) {
          await _secureStorage.write(
            key: AppConstants.refreshTokenKey,
            value: data['refreshToken'],
          );
        }
        return true;
      }
    } catch (e) {
      // Clear tokens on refresh failure
      await _secureStorage.delete(key: AppConstants.accessTokenKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    }
    
    return false;
  }
}

/// Certificate pinning interceptor for security (DISABLED for development)
class CertificatePinningInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Validate endpoint is in allowed hosts
    final uri = Uri.parse(options.baseUrl + options.path);
    final host = '${uri.host}:${uri.port}';
    
    if (!AppConfig.allowedHosts.contains(host) && !AppConfig.allowedHosts.contains(uri.host)) {
      throw SecurityException(
        message: 'Unauthorized API endpoint: $host',
        code: 'INVALID_ENDPOINT',
      );
    }

    // TODO: Certificate pinning is disabled for development
    // In production, implement actual certificate validation here
    if (AppConfig.isProd && AppConfig.certificateFingerprint != null) {
      // Future implementation: validate certificate fingerprint
      // Currently disabled as specified in requirements
    }

    handler.next(options);
  }
}

/// Error handling interceptor for standardized error processing
class ErrorHandlingInterceptor extends Interceptor {
  static const int maxRetries = 3;
  static const int baseDelayMs = 1000;
  final Connectivity _connectivity = Connectivity();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check network connectivity for network-related errors
    if (_isNetworkError(err)) {
      final connectivityResults = await _connectivity.checkConnectivity();
      if (connectivityResults.contains(ConnectivityResult.none)) {
        if (AppConfig.isDebugMode) {
          print('📶 No network connectivity detected');
        }
        // Convert to a more specific network error
        final networkError = DioException(
          requestOptions: err.requestOptions,
          type: DioExceptionType.connectionError,
          message: 'No internet connection available',
        );
        handler.next(networkError);
        return;
      }
    }
    // Add retry logic for network errors
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < maxRetries) {
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        // Exponential backoff with jitter
        final delay = _calculateRetryDelay(retryCount);
        
        if (AppConfig.isDebugMode) {
          print('🔄 Retrying request ${err.requestOptions.path} (attempt ${retryCount + 1}/$maxRetries) after ${delay.inMilliseconds}ms');
        }
        
        await Future.delayed(delay);
        
        try {
          final dio = Dio();
          dio.options.baseUrl = err.requestOptions.baseUrl;
          dio.options.headers = err.requestOptions.headers;
          dio.options.connectTimeout = err.requestOptions.connectTimeout;
          dio.options.receiveTimeout = err.requestOptions.receiveTimeout;
          dio.options.sendTimeout = err.requestOptions.sendTimeout;
          
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // If this was the last retry, proceed with original error
          if (retryCount + 1 >= maxRetries) {
            handler.next(err);
            return;
          }
          // Otherwise, let it try again
        }
        return;
      }
    }

    // Handle rate limiting
    if (err.response?.statusCode == 429) {
      final retryAfter = err.response?.headers.value('retry-after');
      if (retryAfter != null) {
        final delaySeconds = int.tryParse(retryAfter) ?? 60;
        final delay = Duration(seconds: delaySeconds);
        
        if (AppConfig.isDebugMode) {
          print('⏰ Rate limited. Retrying after ${delay.inSeconds} seconds');
        }
        
        await Future.delayed(delay);
        
        try {
          final dio = Dio();
          dio.options = err.requestOptions as BaseOptions;
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Rate limit retry failed, proceed with original error
        }
      }
    }

    handler.next(err);
  }

  bool _isNetworkError(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.connectionError ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout;
  }

  bool _shouldRetry(DioException err) {
    // Retry on network-related errors
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        // Retry on server errors (5xx) but not client errors (4xx)
        final statusCode = err.response?.statusCode;
        return statusCode != null && statusCode >= 500;
      default:
        return false;
    }
  }

  Duration _calculateRetryDelay(int retryCount) {
    // Exponential backoff: 1s, 2s, 4s, 8s...
    final exponentialDelay = baseDelayMs * (1 << retryCount);
    
    // Add jitter to prevent thundering herd
    final jitter = (exponentialDelay * 0.1).round();
    final actualDelay = exponentialDelay + (jitter * (0.5 - DateTime.now().millisecond / 1000));
    
    return Duration(milliseconds: actualDelay.round());
  }
}

/// Performance monitoring interceptor
class PerformanceInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['startTime'] as int?;
    if (startTime != null) {
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      
      // Log slow requests in debug mode
      if (AppConfig.isDebugMode && duration > 2000) {
        print('⚠️ Slow API request: ${response.requestOptions.path} took ${duration}ms');
      }
      
      // Store duration for potential analytics
      response.extra['duration'] = duration;
    }
    
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = err.requestOptions.extra['startTime'] as int?;
    if (startTime != null) {
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      
      if (AppConfig.isDebugMode) {
        print('❌ Failed API request: ${err.requestOptions.path} failed after ${duration}ms');
      }
    }
    
    handler.next(err);
  }
}