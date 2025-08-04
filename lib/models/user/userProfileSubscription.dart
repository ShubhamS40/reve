class UserProfileWithSubscription {
  final UserBasicInfo user;
  final SubscriptionInfo? subscription;

  UserProfileWithSubscription({
    required this.user,
    this.subscription,
  });

  factory UserProfileWithSubscription.fromJson(Map<String, dynamic> json) {
    return UserProfileWithSubscription(
      user: UserBasicInfo.fromJson(json['user']),
      subscription: json['subscription'] != null
          ? SubscriptionInfo.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'subscription': subscription?.toJson(),
      };
}

class UserBasicInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final bool otpVerified;

  UserBasicInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.otpVerified,
  });

  factory UserBasicInfo.fromJson(Map<String, dynamic> json) {
    return UserBasicInfo(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      otpVerified: json['otpVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'mobileNumber': mobileNumber,
        'otpVerified': otpVerified,
      };
}

class SubscriptionInfo {
  final String planType;
  final DateTime startDate;
  final DateTime endDate;
  final double price;

  SubscriptionInfo({
    required this.planType,
    required this.startDate,
    required this.endDate,
    required this.price,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      planType: json['planType'] ?? 'BASIC',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(const Duration(days: 30)),
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'planType': planType,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'price': price,
      };
}
