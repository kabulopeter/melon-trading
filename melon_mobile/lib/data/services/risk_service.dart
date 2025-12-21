import 'api_service.dart';
import '../models/risk_config_model.dart';

class RiskService {
  final ApiService _apiService;

  RiskService(this._apiService);

  Future<RiskConfig?> getRiskConfig() async {
    try {
      final response = await _apiService.dio.get('/risk-config/current/');
      if (response.statusCode == 200) {
        return RiskConfig.fromJson(response.data);
      }
    } catch (e) {
      print("Error fetching risk config: $e");
    }
    return null;
  }

  Future<RiskConfig?> updateRiskConfig(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.patch('/risk-config/current/', data: data);
      if (response.statusCode == 200) {
        return RiskConfig.fromJson(response.data);
      }
    } catch (e) {
      print("Error updating risk config: $e");
    }
    return null;
  }
}
