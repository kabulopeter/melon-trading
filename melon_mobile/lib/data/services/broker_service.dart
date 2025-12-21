import 'api_service.dart';
import '../models/broker_model.dart';

class BrokerService {
  final ApiService _apiService;

  BrokerService(this._apiService);

  Future<List<BrokerAccount>> getBrokers() async {
    try {
      final response = await _apiService.dio.get('/brokers/');
      if (response.statusCode == 200) {
        List data = response.data is List ? response.data : response.data['results'] ?? [];
        return data.map((json) => BrokerAccount.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching brokers: $e");
    }
    return [];
  }

  Future<bool> createBroker(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.post('/brokers/', data: data);
      return response.statusCode == 201;
    } catch (e) {
      print("Error creating broker: $e");
    }
    return false;
  }

  Future<BrokerAccount?> updateBroker(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.patch('/brokers/$id/', data: data);
      if (response.statusCode == 200) {
        return BrokerAccount.fromJson(response.data);
      }
    } catch (e) {
      print("Error updating broker: $e");
    }
    return null;
  }
}
