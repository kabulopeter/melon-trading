import 'api_service.dart';

class AssetSummary {
  final int id;
  final String symbol;
  final String name;

  AssetSummary({required this.id, required this.symbol, required this.name});

  factory AssetSummary.fromJson(Map<String, dynamic> json) {
    return AssetSummary(
      id: json['id'],
      symbol: json['symbol'],
      name: json['name'] ?? '',
    );
  }
}

class AssetService {
  final ApiService _apiService;

  AssetService(this._apiService);

  Future<List<AssetSummary>> getAssets() async {
    try {
      final response = await _apiService.dio.get('/assets/');
      if (response.statusCode == 200) {
        List data = response.data is List ? response.data : response.data['results'] ?? [];
        return data.map((json) => AssetSummary.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching assets: $e");
    }
    return [];
  }
}
