import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class ApiService {
  late final Dio _dio;
  Dio get dio => _dio;

  ApiService() {
    String baseUrl = 'http://127.0.0.1:8000/api/v1'; // Default (Web/Windows)

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        // Use 10.0.2.2 for Emulator, or local IP (192.168.43.209) for physical device
        // Since user is on a physical device, we use the specific IP.
        baseUrl = 'http://192.168.43.209:8000/api/v1';
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
