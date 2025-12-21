import 'api_service.dart';
import '../models/strategy_profile_model.dart';

class StrategyService {
  final ApiService _apiService;

  StrategyService(this._apiService);

  Future<List<StrategyProfile>> getStrategies() async {
    try {
      final response = await _apiService.dio.get('/strategies/');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => StrategyProfile.fromJson(e))
            .toList();
      }
    } catch (e) {
      print("Error fetching strategies: $e");
    }
    return [];
  }

  Future<StrategyProfile?> createStrategy(StrategyProfile strategy) async {
    try {
      final response = await _apiService.dio.post('/strategies/', data: strategy.toJson());
      if (response.statusCode == 201) {
        return StrategyProfile.fromJson(response.data);
      }
    } catch (e) {
      print("Error creating strategy: $e");
    }
    return null;
  }

  Future<StrategyProfile?> updateStrategy(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.patch('/strategies/$id/', data: data);
      if (response.statusCode == 200) {
        return StrategyProfile.fromJson(response.data);
      }
    } catch (e) {
      print("Error updating strategy: $e");
    }
    return null;
  }

  Future<bool> deleteStrategy(int id) async {
    try {
      final response = await _apiService.dio.delete('/strategies/$id/');
      return response.statusCode == 204;
    } catch (e) {
      print("Error deleting strategy: $e");
      return false;
    }
  }
}
