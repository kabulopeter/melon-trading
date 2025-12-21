class UserWallet {
  final int id;
  final String balance;
  final String currency;
  final String updatedAt;

  UserWallet({
    required this.id,
    required this.balance,
    required this.currency,
    required this.updatedAt,
  });

  factory UserWallet.fromJson(Map<String, dynamic> json) {
    return UserWallet(
      id: json['id'],
      balance: json['balance'],
      currency: json['currency'],
      updatedAt: json['updated_at'],
    );
  }
}

class WalletTransaction {
  final int id;
  final String amount;
  final String transactionType;
  final String paymentMethod;
  final String status;
  final String? phoneNumber;
  final String? providerRef;
  final String? description;
  final String createdAt;
  final String? completedAt;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.transactionType,
    required this.paymentMethod,
    required this.status,
    this.phoneNumber,
    this.providerRef,
    this.description,
    required this.createdAt,
    this.completedAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      amount: json['amount'],
      transactionType: json['transaction_type'],
      paymentMethod: json['payment_method'],
      status: json['status'],
      phoneNumber: json['phone_number'],
      providerRef: json['provider_ref'],
      description: json['description'],
      createdAt: json['created_at'],
      completedAt: json['completed_at'],
    );
  }
}
