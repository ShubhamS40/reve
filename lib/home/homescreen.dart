import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/home/browncard.dart';
import 'package:reva/home/components/silverCard.dart';
import 'package:reva/home/qrcode.dart';
import 'package:reva/models/user/userProfileSubscription.dart';
import 'package:reva/services/qr/qrService.dart';
import 'package:reva/services/signup/AuthenticationService.dart';
import 'package:reva/services/user/userProfileService.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Authenticationservice _authenticationservice = Authenticationservice();
  final ReferralQRService _referralQRService = ReferralQRService();
  final UserProfileService _userProfileService = UserProfileService();

  String? userName;
  UserProfileWithSubscription? userProfileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    loadUserProfileWithSubscription();
  }

  Future<void> loadUserInfo() async {
    final userData = await _authenticationservice.getUserInfo();
    if (userData != null && userData.containsKey('firstName')) {
      setState(() {
        userName = userData['firstName'];
        print("userName${userName}");
      });
    }
  }

  Future<void> loadUserProfileWithSubscription() async {
    try {
      final profileData = await _userProfileService
          .getUserProfileWithSubscriptionWithContext(context);
      setState(() {
        userProfileData = profileData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user profile with subscription: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context)
        .size
        .height; // Fixed: changed from width to height
    return Scaffold(
      backgroundColor: Color(0xFF22252A),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh both user info and profile data
          await loadUserInfo();
          await loadUserProfileWithSubscription();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(width * 0.05),
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.06, // Adjusted for proper spacing
                ),
                Row(
                  children: [
                    Image.asset(
                      "assets/logo.png",
                      height: 40,
                    ),
                    SizedBox(
                      width: width * 0.02,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello!",
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 14, // Fixed size
                              color: Colors.white),
                        ),
                        Text(
                          "${userName ?? 'User'},",
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 18, // Fixed size
                              color: Colors.white),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Image.asset("assets/bellicon.png"),
                  ],
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48, // Fixed height
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2F34),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                        child: Row(
                          children: [
                            const Icon(Icons.search,
                                color: Colors.white70, size: 22),
                            SizedBox(width: width * 0.02),
                            const Expanded(
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                cursorColor: Colors.white54,
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  hintStyle: TextStyle(color: Colors.white54),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                    // Filter Button
                    InkWell(
                      onTap: () {
                        // TODO: Add filter action
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 48, // Fixed height to match search bar
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0262AB), Color(0xFF01345A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.filter_list,
                                color: Colors.white, size: 20),
                            SizedBox(width: 6),
                            Text(
                              'Filters',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ProfileCard(
                        name:
                            "${userProfileData?.user.firstName ?? "User"} ${userProfileData?.user.lastName ?? ''}",
                        location:
                            "Delhi NCR", // This would come from profile data in a real implementation
                        experience:
                            "2+ years", // This would come from profile data in a real implementation
                        languages: [
                          "Hindi",
                          "English"
                        ], // This would come from profile data in a real implementation
                        categories: [
                          "Commercial",
                          "Plots",
                          "Rental"
                        ], // This would come from profile data in a real implementation
                        isKycApproved:
                            userProfileData?.user.otpVerified ?? false,
                        planType:
                            userProfileData?.subscription?.planType ?? "BASIC",
                      ),
                SizedBox(
                  height: height * 0.02,
                ),
                // QR Button
                InkWell(
                  onTap: () async {
                    // Handle tap
                    final qrUrl = await _referralQRService.generateQRCode(
                        "profile"); // This returns the image URL
                    print(qrUrl);

                    if (qrUrl != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowQrScreen(
                              qrUrl: qrUrl.imageUrl!), // imageUrl is a String
                        ),
                      );
                    } else {
                      // Handle the error - maybe show a snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to generate QR code")),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 56, // Fixed height
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0262AB), Color(0xFF01345A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF01345A).withOpacity(0.45),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "View my Profile QR",
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 80, // Fixed height
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2D33),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: const Color(0xFF5C7A99),
                              size: 28,
                            ),
                            Spacer(),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '028',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFE1E1E1),
                                  ),
                                ),
                                Text(
                                  'Total no. of connections',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFB4B4B4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 80, // Fixed height to match
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F3238),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "4 new",
                                style: GoogleFonts.dmSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF5F5F5),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Want to connect",
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xFFB2B2B2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
