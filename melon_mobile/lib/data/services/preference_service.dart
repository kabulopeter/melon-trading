import 'api_service.dart';
import '../models/preference_model.dart';

class PreferenceService {
  final ApiService _apiService;

  PreferenceService(this._apiService);

  Future<UserPreference?> getPreferences() async {
    try {
      final response = await _apiService.dio.get('/preferences/settings/');
      if (response.statusCode == 200) {
        return UserPreference.fromJson(response.data);
      }
    } catch (e) {
      print("Error fetching preferences: $e");
    }
    return null;
  }

  Future<UserPreference?> updatePreferences(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.patch('/preferences/settings/', data: data);
      if (response.statusCode == 200) {
        return UserPreference.fromJson(response.data);
      }
    } catch (e) {
      print("Error updating preferences: $e");
    }
    return null;
  }
}
