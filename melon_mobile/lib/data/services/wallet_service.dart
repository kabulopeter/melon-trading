import 'api_service.dart';
import '../models/wallet_model.dart';

class WalletService {
  final ApiService _apiService;

  WalletService(this._apiService);

  Future<UserWallet?> getBalance() async {
    try {
      final response = await _apiService.dio.get('/wallet/balance/');
      if (response.statusCode == 200) {
        return UserWallet.fromJson(response.data);
      }
    } catch (e) {
      print("Error fetching balance: $e");
    }
    return null;
  }

  Future<List<WalletTransaction>> getTransactions() async {
    try {
      final response = await _apiService.dio.get('/wallet/transactions/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => WalletTransaction.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching transactions: $e");
    }
    return [];
  }

  Future<WalletTransaction?> initiateDeposit({
    required String amount,
    required String method,
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/wallet/deposit/',
        data: {
          'amount': amount,
          'payment_method': method,
          'phone_number': phoneNumber,
        },
      );
      if (response.statusCode == 201) {
        return WalletTransaction.fromJson(response.data);
      }
    } catch (e) {
      print("Error initiating deposit: $e");
    }
    return null;
  }

  Future<WalletTransaction?> initiateWithdrawal({
    required String amount,
    required String method,
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/wallet/withdraw/',
        data: {
          'amount': amount,
          'payment_method': method,
          'phone_number': phoneNumber,
        },
      );
      if (response.statusCode == 201) {
        return WalletTransaction.fromJson(response.data);
      }
    } catch (e) {
      print("Error initiating withdrawal: $e");
    }
    return null;
  }
}
