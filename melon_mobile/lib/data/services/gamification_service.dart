import 'api_service.dart';
import '../models/challenge_model.dart';
import '../models/badge_model.dart';

class GamificationService {
  final ApiService _apiService;

  GamificationService(this._apiService);

  Future<List<UserChallenge>> getMyChallenges() async {
    try {
      final response = await _apiService.dio.get('/challenges/mine/');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => UserChallenge.fromJson(e))
            .toList();
      }
    } catch (e) {
      print("Error fetching challenges: $e");
    }
    return [];
  }

  Future<List<UserBadge>> getMyBadges() async {
    try {
      final response = await _apiService.dio.get('/badges/mine/');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => UserBadge.fromJson(e))
            .toList();
      }
    } catch (e) {
      print("Error fetching badges: $e");
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final response = await _apiService.dio.get('/challenges/leaderboard/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      print("Error fetching leaderboard: $e");
    }
    return [];
  }
}
