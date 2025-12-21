class UserProfile {
  final String fullName;
  final String kycStatus; // NOT_SUBMITTED, PENDING, VERIFIED, REJECTED
  final String? kycDocumentId;
  final String? country;
  final String? avatarUrl;
  final int xp;
  final int level;

  UserProfile({
    required this.fullName,
    required this.kycStatus,
    this.kycDocumentId,
    this.country,
    this.avatarUrl,
    this.xp = 0,
    this.level = 1,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['full_name'] ?? '',
      kycStatus: json['kyc_status'] ?? 'NOT_SUBMITTED',
      kycDocumentId: json['kyc_document_id'],
      country: json['country'],
      avatarUrl: json['avatar_url'],
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'kyc_document_id': kycDocumentId,
      'country': country,
      'avatar_url': avatarUrl,
    };
  }
}
