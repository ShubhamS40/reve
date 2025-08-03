class Users {
  final String id;
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String mpin;
  final bool otpVerified;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;

  Users(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.mobileNumber,
      required this.mpin,
      required this.otpVerified,
      required this.refreshToken,
      required this.refreshTokenExpiresAt});

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['_id']??'',
      firstName: json['firstName']??'',
      lastName: json['lastName']??'',
      mobileNumber: json['mobileNumber']??'',
      mpin: json['mpin']??'',
      otpVerified: json['otpVerified'] ?? false,
      refreshToken: json['refreshToken'] ?? '',
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'] != null
          ? DateTime.parse(json['refreshTokenExpiresAt'])
          : DateTime.now(), // or any fallback default
    );
  }

  Map<String, dynamic> tojson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
      'mpin': mpin,
      'otpVerified': otpVerified,
      'refreshToken': refreshToken,
      'refreshTokenExpiresAt': refreshTokenExpiresAt,
    };
  }
}
