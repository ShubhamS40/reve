import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/signup/preferencesScreen.dart';
import 'package:reva/models/profile/profileModel.dart';
import 'package:reva/services/profile/ProfileService.dart';

import '../components/mytextfield.dart';

class ContactDetailsScreen extends StatefulWidget {
  const ContactDetailsScreen({super.key});

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  final UserProfileService _profileService = UserProfileService();
  final FlutterSecureStorage _flutterSecureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  TextEditingController primaryMobileNumber = TextEditingController();
  TextEditingController primaryEmailId = TextEditingController();
  TextEditingController websitePortfolio = TextEditingController();
  TextEditingController socialMediaLinks = TextEditingController();
  TextEditingController alternateMobileNumbers = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.07),
                const Center(
                  child: Text(
                    "Contact Details",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      "60%   ",
                      style: GoogleFonts.dmSans(
                        color: Color(0xFFD8D8DD),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "Completed..",
                      style: GoogleFonts.dmSans(
                        color: Color(0xFF6F6F6F),
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: width * 0.6,
                    child: const LinearProgressIndicator(
                      value: 0.6,
                      minHeight: 6,
                      backgroundColor: Colors.white,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF0262AB)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: "Primary Mobile Number",
                  hint: "00000 00000",
                  controller: primaryMobileNumber,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Primary EmailId",
                  hint: "xyz@gmail.com",
                  controller: primaryEmailId,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Website / Portfolio",
                  hint: "www.xyz.com",
                  controller: websitePortfolio,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Social Media Links",
                  hint: "instagram",
                  controller: socialMediaLinks,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Alternate Mobile Number",
                  hint: "00000 00000",
                  controller: alternateMobileNumbers,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      String primaryMobile = primaryMobileNumber.text.trim();
                      String primaryEmail = primaryEmailId.text.trim();
                      String website = websitePortfolio.text.trim();
                      String socialMedia = socialMediaLinks.text.trim();
                      String alternateMobile =
                          alternateMobileNumbers.text.trim();
                      String? mobileNumber1 =
                          await _flutterSecureStorage.read(key: 'mobileNumber');
                      if (mobileNumber1 == null || mobileNumber1.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'No mobile number found. Please sign up first.')),
                        );
                        return;
                      }
                      final data3 = Step3(
                          aadharVerified: true,
                          primaryMobileNumber: primaryMobile,
                          primaryEmail: primaryEmail,
                          website: website,
                          socialMediaLink: socialMedia,
                          alternateMobile: alternateMobile,
                          mobileNumber: mobileNumber1);
                      bool success = await _profileService.submitStep3(data3);
                      if (success) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PreferencesScreen()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Failed to save data. Please try again.")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0262AB), Color(0xFF01345A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
