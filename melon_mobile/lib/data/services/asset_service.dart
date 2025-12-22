import 'api_service.dart';
import '../models/asset_model.dart';

class AssetService {
  final ApiService _apiService;

  AssetService(this._apiService);

  Future<List<Asset>> getAssets() async {
    try {
      final response = await _apiService.dio.get('/assets/');
      if (response.statusCode == 200) {
        List data = response.data is List ? response.data : response.data['results'] ?? [];
        return data.map((json) => Asset.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching assets: $e");
    }
    return [];
  }
}
