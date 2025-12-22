import 'api_service.dart';
import '../models/trade_model.dart'; // Reuse Signal from trade_model if available

class AiPredictionService {
  final ApiService _apiService;

  AiPredictionService(this._apiService);

  Future<Map<String, dynamic>?> predictSymbol(String symbol) async {
    try {
      final response = await _apiService.dio.post(
        '/ai/predict/',
        data: {'symbol': symbol},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print("Error triggering AI prediction for $symbol: $e");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> batchPredict() async {
    try {
      final response = await _apiService.dio.get('/ai/predict/batch/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      print("Error triggering batch AI prediction: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>?> refreshAll() async {
    try {
      final response = await _apiService.dio.post('/ai/refresh/');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print("Error triggering AI refresh: $e");
    }
    return null;
  }
}
