import 'api_service.dart';
import '../models/trade_model.dart';

class TradeService {
  final ApiService _apiService;

  TradeService(this._apiService);

  Future<List<Trade>> getTrades() async {
    try {
      final response = await _apiService.dio.get('/trades/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : response.data['results'] ?? [];
        return data.map((json) => Trade.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching trades: $e");
    }
    return [];
  }

  Future<Trade?> createTrade(Map<String, dynamic> tradeData) async {
    try {
      final response = await _apiService.dio.post('/trades/', data: tradeData);
      if (response.statusCode == 201) {
        return Trade.fromJson(response.data);
      }
    } catch (e) {
      print("Error creating trade: $e");
    }
    return null;
  }
}
