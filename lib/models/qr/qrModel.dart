class ReferralQRCodeModel {
  final String id;
  final String codeData;
  final String userId;
  final String purpose;
  final String? imageUrl;
  final int scannedCount;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReferralQRCodeModel({
    required this.id,
    required this.codeData,
    required this.userId,
    required this.purpose,
    this.imageUrl,
    required this.scannedCount,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReferralQRCodeModel.fromJson(Map<String, dynamic> json) {
    return ReferralQRCodeModel(
      id: json['_id'] as String,
      codeData: json['codeData'] as String,
      userId: json['userId'] as String,
      purpose: json['purpose'] as String,
      imageUrl: json['imageUrl'],
      scannedCount: json['scannedCount'] ?? 0,
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'codeData': codeData,
      'userId': userId,
      'purpose': purpose,
      'imageUrl': imageUrl,
      'scannedCount': scannedCount,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
