class BrokerAccount {
  final int id;
  final String name;
  final String brokerType;
  final String accountId;
  final bool isActive;
  final bool isTestAccount;
  final double balance;

  BrokerAccount({
    required this.id,
    required this.name,
    required this.brokerType,
    required this.accountId,
    required this.isActive,
    required this.isTestAccount,
    required this.balance,
  });

  factory BrokerAccount.fromJson(Map<String, dynamic> json) {
    return BrokerAccount(
      id: json['id'],
      name: json['name'],
      brokerType: json['broker_type'],
      accountId: json['account_id'],
      isActive: json['is_active'] ?? false,
      isTestAccount: json['is_test_account'] ?? true,
      balance: double.parse((json['balance'] ?? '0.00').toString()),
    );
  }
}
