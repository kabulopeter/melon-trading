import 'api_service.dart';
import '../models/performance_model.dart';

class AnalyticsService {
  final ApiService _apiService;

  AnalyticsService(this._apiService);

  Future<PerformanceStats?> getStats() async {
    try {
      final response = await _apiService.dio.get('/analytics/stats/');
      if (response.statusCode == 200) {
        return PerformanceStats.fromJson(response.data);
      }
    } catch (e) {
      print("Error fetching analytics: $e");
    }
    return null;
  }
}
