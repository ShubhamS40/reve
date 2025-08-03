class UserProfile {
  final Step1? step1;
  final Step2? step2;
  final Step3? step3;
  final Step4? step4;
  final Step5? step5;
  final int profileProgress;

  UserProfile({
    this.step1,
    this.step2,
    this.step3,
    this.step4,
    this.step5,
    this.profileProgress = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      step1: json['step1'] != null ? Step1.fromJson(json['step1']) : null,
      step2: json['step2'] != null ? Step2.fromJson(json['step2']) : null,
      step3: json['step3'] != null ? Step3.fromJson(json['step3']) : null,
      step4: json['step4'] != null ? Step4.fromJson(json['step4']) : null,
      step5: json['step5'] != null ? Step5.fromJson(json['step5']) : null,
      profileProgress: json['profileProgress'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'step1': step1?.toJson(),
        'step2': step2?.toJson(),
        'step3': step3?.toJson(),
        'step4': step4?.toJson(),
        'step5': step5?.toJson(),
        'profileProgress': profileProgress,
      };
}

class Step1 {
  final String username;
  final String dateOfBirth;
  final String designation;
  final String location;
  final String realEstateExperience;
  final String mobileNumber;

  Step1({
    required this.username,
    required this.dateOfBirth,
    required this.designation,
    required this.location,
    required this.realEstateExperience,
    required this.mobileNumber,
  });

  factory Step1.fromJson(Map<String, dynamic> json) => Step1(
        username: json['username'],
        dateOfBirth: json['dateOfBirth'],
        designation: json['designation'],
        location: json['location'],
        realEstateExperience: json['realEstateExperience'],
        mobileNumber: json['mobileNumber'],
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'dateOfBirth': dateOfBirth,
        'designation': designation,
        'location': location,
        'realEstateExperience': realEstateExperience,
        'mobileNumber': mobileNumber,
      };
}

class Step2 {
  final String companyName;
  final bool registeredCompany;
  final String incorporationDate;
  final String companyType;
  final String? gstin;
  final String mobileNumber;

  Step2({
    required this.companyName,
    required this.registeredCompany,
    required this.incorporationDate,
    required this.companyType,
    this.gstin,
    required this.mobileNumber,
  });

  factory Step2.fromJson(Map<String, dynamic> json) => Step2(
        companyName: json['companyName'],
        registeredCompany: json['registeredCompany'],
        incorporationDate: json['incorporationDate'],
        companyType: json['companyType'],
        gstin: json['GSTIN'],
        mobileNumber: json['mobileNumber'],
      );

  Map<String, dynamic> toJson() => {
        'companyName': companyName,
        'registeredCompany': registeredCompany,
        'incorporationDate': incorporationDate,
        'companyType': companyType,
        'GSTIN': gstin,
        'mobileNumber': mobileNumber,
      };
}

class Step3 {
  final bool aadharVerified;
  final String primaryMobileNumber;
  final String primaryEmail;
  final String website;
  final String socialMediaLink;
  final String alternateMobile;
  final String mobileNumber;

  Step3({
    required this.aadharVerified,
    required this.primaryMobileNumber,
    required this.primaryEmail,
    required this.website,
    required this.socialMediaLink,
    required this.alternateMobile,
    required this.mobileNumber,
  });

  factory Step3.fromJson(Map<String, dynamic> json) => Step3(
        aadharVerified: json['aadharVerified'],
        primaryMobileNumber: json['primaryMobileNumber'],
        primaryEmail: json['primaryEmail'],
        website: json['website'],
        socialMediaLink: json['socialMediaLink'],
        alternateMobile: json['alternateMobile'],
        mobileNumber: json['mobileNumber'],
      );

  Map<String, dynamic> toJson() => {
        'aadharVerified': aadharVerified,
        'primaryMobileNumber': primaryMobileNumber,
        'primaryEmail': primaryEmail,
        'website': website,
        'socialMediaLink': socialMediaLink,
        'alternateMobile': alternateMobile,
        'mobileNumber': mobileNumber,
      };
}

class Step4 {
  final String operatingLocation;
  final String interest;
  final String propertyType;
  final String networkPreference;
  final String targetClient;
  final String mobileNumber;

  Step4({
    required this.operatingLocation,
    required this.interest,
    required this.propertyType,
    required this.networkPreference,
    required this.targetClient,
    required this.mobileNumber,
  });

  factory Step4.fromJson(Map<String, dynamic> json) => Step4(
        operatingLocation: json['operatingLocation'],
        interest: json['interest'],
        propertyType: json['propertyType'],
        networkPreference: json['networkPreference'],
        targetClient: json['targetClient'],
        mobileNumber: json['mobileNumber'],
      );

  Map<String, dynamic> toJson() => {
        'operatingLocation': operatingLocation,
        'interest': interest,
        'propertyType': propertyType,
        'networkPreference': networkPreference,
        'targetClient': targetClient,
        'mobileNumber': mobileNumber,
      };
}

class Step5 {
  final bool reraRegistration;
  final String reraNumber;
  final String? networkingMember;
  final String? realEstateWebsite;
  final String? associatedBuilder;
  final String mobileNumber;

  Step5({
    required this.reraRegistration,
    required this.reraNumber,
    this.networkingMember,
    this.realEstateWebsite,
    this.associatedBuilder,
    required this.mobileNumber,
  });

  factory Step5.fromJson(Map<String, dynamic> json) => Step5(
        reraRegistration: json['reraRegistration'],
        reraNumber: json['reraNumber'],
        networkingMember: json['networkingMember'],
        realEstateWebsite: json['realEstateWebsite'],
        associatedBuilder: json['associatedBuilder'],
        mobileNumber: json['mobileNumber'],
      );

  Map<String, dynamic> toJson() => {
        'reraRegistration': reraRegistration,
        'reraNumber': reraNumber,
        'networkingMember': networkingMember,
        'realEstateWebsite': realEstateWebsite,
        'associatedBuilder': associatedBuilder,
        'mobileNumber': mobileNumber,
      };
}
