import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/login.dart';
import 'package:reva/authentication/signup/preferencesScreen.dart';
import 'package:reva/bottomnavigation/bottomnavigation.dart';
import 'package:reva/models/profile/profileModel.dart';
import 'package:reva/services/profile/ProfileService.dart';

import '../components/mytextfield.dart';

class SpecializationAndRecognition extends StatefulWidget {
  const SpecializationAndRecognition({super.key});

  @override
  State<SpecializationAndRecognition> createState() =>
      _SpecializationAndRecognitionState();
}

class _SpecializationAndRecognitionState
    extends State<SpecializationAndRecognition> {
  final UserProfileService _profileService = UserProfileService();
  bool reraRegestration = false;
  final FlutterSecureStorage _flutterSecureStorage =const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  TextEditingController reraNUmber = TextEditingController();
  TextEditingController networkingMember = TextEditingController();
  TextEditingController realEstateWebsite = TextEditingController();
  TextEditingController associatedBuilders = TextEditingController();
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
                    "Specialisation & Recognition",
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
                      "100%   ",
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFFD8D8DD),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "Completed..",
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFF6F6F6F),
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
                      value: 1,
                      minHeight: 6,
                      backgroundColor: Colors.white,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF0262AB)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'RERA Regestration',
                  style: TextStyle(
                    color: Color(0xFFDFDFDF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F3237),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'yes or no',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Switch(
                        value: reraRegestration,
                        onChanged: (val) {
                          setState(() => reraRegestration = val);
                        },
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "RERA NUMBER",
                  hint: "0000 0000 00",
                  controller: reraNUmber,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Networking Member (Optional)",
                  hint: "ibrddg,bere,enhs",
                  controller: networkingMember,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Real Estate Websites (Optional)",
                  hint: "waofsavbf",
                  controller: realEstateWebsite,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Associated Builders (Optional)",
                  hint: "esgopesg,gsgeg,drhhr",
                  controller: associatedBuilders,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      bool reraRegis = reraRegestration;
                      String rerano = reraNUmber.text.trim();
                      String networkmemeber = networkingMember.text.trim();
                      String realEstateWeb = realEstateWebsite.text.trim();
                      String associteBuilder = associatedBuilders.text.trim();
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
                      final data5 = Step5(
                          reraRegistration: reraRegis,
                          reraNumber: rerano,
                          networkingMember: networkmemeber,
                          realEstateWebsite: realEstateWeb,
                          associatedBuilder: associteBuilder,
                          mobileNumber: mobileNumber1
                          );
                      bool success = await _profileService.submitStep5(data5);
                      if (success) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LoginScreen ()));
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
