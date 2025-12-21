import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/alert_model.dart';

class AlertService {
  final ApiService _apiService;

  AlertService(this._apiService);

  Future<List<MarketAlert>> getAlerts() async {
    try {
      final response = await _apiService.dio.get('/alerts/');
      if (response.statusCode == 200) {
        List data = response.data is List ? response.data : response.data['results'] ?? [];
        return data.map((json) => MarketAlert.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching alerts: $e");
    }
    return [];
  }

  Future<MarketAlert?> createAlert(int assetId, double targetPrice, String condition) async {
    try {
      final response = await _apiService.dio.post('/alerts/', data: {
        'asset': assetId,
        'target_price': targetPrice,
        'condition': condition,
      });
      if (response.statusCode == 201) {
        return MarketAlert.fromJson(response.data);
      }
    } catch (e) {
       if (e is DioException) {
         print("Create alert failed: ${e.response?.data}");
       } else {
         print("Error creating alert: $e");
       }
    }
    return null;
  }

  Future<bool> deleteAlert(int id) async {
    try {
      final response = await _apiService.dio.delete('/alerts/$id/');
      return response.statusCode == 204;
    } catch (e) {
      print("Error deleting alert: $e");
    }
    return false;
  }
}
