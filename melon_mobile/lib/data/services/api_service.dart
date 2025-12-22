import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class ApiService {
  late final Dio _dio;
  Dio get dio => _dio;

  ApiService() {
    String baseUrl = 'https://melon-trading.fly.dev/api/v1'; 

    if (kDebugMode) {
      baseUrl = 'http://127.0.0.1:8000/api/v1'; 
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          baseUrl = 'http://10.0.2.2:8000/api/v1';
        }
      }
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Interceptor pour logger les erreurs
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<Response> getTrades() async {
    return await _dio.get('/trades/');
  }

  Future<Response> getAssets() async {
    return await _dio.get('/assets/');
  }

  Future<Response> getPrices(int assetId) async {
    return await _dio.get('/prices/', queryParameters: {'asset': assetId});
  }
}
