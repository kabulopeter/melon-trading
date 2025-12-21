import 'api_service.dart';
import '../models/profile_model.dart';

class ProfileService {
  final ApiService _apiService;

  ProfileService(this._apiService);

  Future<UserProfile?> getProfile() async {
    try {
      final response = await _apiService.dio.get('/profile/me/');
      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data);
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
    return null;
  }

  Future<UserProfile?> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.patch('/profile/me/', data: data);
      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data);
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
    return null;
  }
}
